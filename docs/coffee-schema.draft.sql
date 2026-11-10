-- Coffee AI: PostgreSQL schema proposal, 2026-10-11.
-- REVIEW DRAFT ONLY. This file has not been executed against a database.
-- It must be adapted to the application's existing product/lot key structure.
-- workspaces/actors are provisional ownership/audit references; this is not an auth model.
-- No grading thresholds, defect factors, market prices or official claims are seeded.
-- All rule content must be reviewed and versioned before publication.
-- Application authorization / RLS, finalization locks, audit writers and
-- JSON schema validation are required before production; this draft defines structure.
-- The deployment/migration system must determine ownership and grants.

BEGIN;

CREATE SCHEMA coffee;

-- Integration with the rest of the application.
CREATE TABLE coffee.workspaces (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    external_system text NOT NULL,
    external_organization_ref text NOT NULL,
    timezone text NOT NULL DEFAULT 'Asia/Bangkok',
    default_currency varchar(3) NOT NULL DEFAULT 'THB',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (external_system, external_organization_ref),
    CHECK (default_currency ~ '^[A-Z]{3}$')
);

CREATE TABLE coffee.actors (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    external_system text NOT NULL,
    external_user_ref text NOT NULL,
    display_name text NOT NULL,
    active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, external_system, external_user_ref)
);

CREATE TABLE coffee.producers (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    name text NOT NULL,
    producer_type text NOT NULL CHECK (producer_type IN ('farmer', 'cooperative', 'supplier', 'other')),
    external_supplier_ref text,
    contact_details jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    archived_at timestamptz,
    UNIQUE (workspace_id, id),
    CHECK (jsonb_typeof(contact_details) = 'object')
);

CREATE TABLE coffee.farms (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    producer_id bigint,
    name text NOT NULL,
    country_code varchar(2),
    region text,
    province text,
    district text,
    altitude_min_m numeric(7,2),
    altitude_max_m numeric(7,2),
    traceability jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    archived_at timestamptz,
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, producer_id) REFERENCES coffee.producers(workspace_id, id),
    CHECK (country_code IS NULL OR country_code ~ '^[A-Z]{2}$'),
    CHECK (altitude_min_m IS NULL OR altitude_min_m >= 0),
    CHECK (altitude_max_m IS NULL OR altitude_max_m >= 0),
    CHECK (altitude_min_m IS NULL OR altitude_max_m IS NULL OR altitude_min_m <= altitude_max_m),
    CHECK (jsonb_typeof(traceability) = 'object')
);

CREATE TABLE coffee.lots (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    lot_code text NOT NULL,
    name text NOT NULL,
    producer_id bigint,
    farm_id bigint,
    species text,
    varieties text[],
    process_code text,
    harvest_label text,
    harvest_date date,
    received_at timestamptz,
    material_stage text NOT NULL CHECK (material_stage IN ('cherry', 'dried_cherry', 'dry_parchment', 'green', 'roasted')),
    quantity_kg numeric(16,4),
    asking_price_per_kg numeric(16,4),
    currency varchar(3) NOT NULL DEFAULT 'THB',
    workflow_status text NOT NULL DEFAULT 'draft'
        CHECK (workflow_status IN ('draft', 'received', 'assessed', 'reviewed', 'archived')),
    safety_status text NOT NULL DEFAULT 'unknown'
        CHECK (safety_status IN ('unknown', 'clear', 'hold', 'rejected')),
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_by_actor_id bigint,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    archived_at timestamptz,
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, lot_code),
    FOREIGN KEY (workspace_id, producer_id) REFERENCES coffee.producers(workspace_id, id),
    FOREIGN KEY (workspace_id, farm_id) REFERENCES coffee.farms(workspace_id, id),
    FOREIGN KEY (workspace_id, created_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (quantity_kg IS NULL OR quantity_kg >= 0),
    CHECK (asking_price_per_kg IS NULL OR asking_price_per_kg >= 0),
    CHECK (currency ~ '^[A-Z]{3}$'),
    CHECK (jsonb_typeof(metadata) = 'object')
);

-- Raw data first lands in the review inbox; an operator assigns it to a Lot.
-- Media bytes belong in object storage, not in PostgreSQL.
CREATE TABLE coffee.data_inbox_items (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    capture_kind text NOT NULL CHECK (capture_kind IN ('image', 'sensor', 'device_event', 'manual_record')),
    source_system text NOT NULL,
    source_device_ref text,
    source_event_ref text,
    captured_at timestamptz,
    received_at timestamptz NOT NULL DEFAULT now(),
    review_status text NOT NULL DEFAULT 'unreviewed'
        CHECK (review_status IN ('unreviewed', 'needs_review', 'assigned', 'rejected')),
    lot_id bigint,
    payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    media_storage_key text,
    media_mime_type text,
    media_sha256 varchar(64),
    reviewed_by_actor_id bigint,
    reviewed_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, lot_id) REFERENCES coffee.lots(workspace_id, id),
    FOREIGN KEY (workspace_id, reviewed_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (review_status <> 'assigned' OR lot_id IS NOT NULL),
    CHECK ((reviewed_by_actor_id IS NULL AND reviewed_at IS NULL)
        OR (reviewed_by_actor_id IS NOT NULL AND reviewed_at IS NOT NULL)),
    CHECK (media_sha256 IS NULL OR media_sha256 ~ '^[0-9a-f]{64}$'),
    CHECK (jsonb_typeof(payload) = 'object')
);

-- Machine-extracted findings remain suggestions until a person confirms them.
CREATE TABLE coffee.data_inbox_observations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    inbox_item_id bigint NOT NULL,
    observation_kind text NOT NULL
        CHECK (observation_kind IN ('measurement', 'defect', 'breakage', 'classification', 'note')),
    observation_code text NOT NULL,
    label text,
    value_numeric numeric(16,6),
    value_text text,
    unit text,
    confidence numeric(7,6),
    verification_status text NOT NULL DEFAULT 'unverified'
        CHECK (verification_status IN ('unverified', 'machine_suggested', 'human_confirmed', 'rejected')),
    coordinates jsonb,
    model_reference text,
    observation_data jsonb NOT NULL DEFAULT '{}'::jsonb,
    reviewed_by_actor_id bigint,
    reviewed_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, inbox_item_id) REFERENCES coffee.data_inbox_items(workspace_id, id),
    FOREIGN KEY (workspace_id, reviewed_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (confidence IS NULL OR confidence BETWEEN 0 AND 1),
    CHECK ((reviewed_by_actor_id IS NULL AND reviewed_at IS NULL)
        OR (reviewed_by_actor_id IS NOT NULL AND reviewed_at IS NOT NULL)),
    CHECK (coordinates IS NULL OR jsonb_typeof(coordinates) = 'object'),
    CHECK (jsonb_typeof(observation_data) = 'object')
);

CREATE TABLE coffee.process_equipment (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    equipment_code text NOT NULL,
    equipment_kind text NOT NULL CHECK (equipment_kind IN (
        'fermentation_tank', 'hybrid_dryer', 'optical_sorter', 'hot_air_roaster', 'sensor', 'other'
    )),
    name text NOT NULL,
    manufacturer text,
    model text,
    serial_number text,
    equipment_status text NOT NULL DEFAULT 'active'
        CHECK (equipment_status IN ('active', 'maintenance', 'inactive')),
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, equipment_code),
    CHECK (jsonb_typeof(metadata) = 'object')
);

-- Recipe versions are reusable configurations; each run stores an immutable snapshot.
CREATE TABLE coffee.process_recipes (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    process_code text NOT NULL CHECK (process_code IN (
        'controlled_fermentation', 'hybrid_drying', 'optical_sorting', 'hot_air_roasting'
    )),
    recipe_code text NOT NULL,
    version text NOT NULL,
    name text NOT NULL,
    definition jsonb NOT NULL,
    source_references jsonb NOT NULL DEFAULT '[]'::jsonb,
    recipe_status text NOT NULL DEFAULT 'draft' CHECK (recipe_status IN ('draft', 'published', 'retired')),
    created_by_actor_id bigint,
    approved_by_actor_id bigint,
    approved_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, process_code, id),
    UNIQUE (workspace_id, process_code, recipe_code, version),
    FOREIGN KEY (workspace_id, created_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    FOREIGN KEY (workspace_id, approved_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (recipe_status <> 'published' OR (approved_by_actor_id IS NOT NULL AND approved_at IS NOT NULL)),
    CHECK (jsonb_typeof(definition) = 'object'),
    CHECK (jsonb_typeof(source_references) = 'array')
);

CREATE TABLE coffee.sensor_calibrations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    sensor_code text NOT NULL,
    calibration_method text NOT NULL,
    reference_method text NOT NULL,
    calibrated_at timestamptz NOT NULL,
    valid_until timestamptz,
    calibration_status text NOT NULL CHECK (calibration_status IN ('valid', 'expired', 'failed', 'unverified')),
    uncertainty numeric(12,6),
    certificate_storage_key text,
    calibration_data jsonb NOT NULL DEFAULT '{}'::jsonb,
    calibrated_by_actor_id bigint,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, equipment_id, sensor_code, id),
    FOREIGN KEY (workspace_id, equipment_id) REFERENCES coffee.process_equipment(workspace_id, id),
    FOREIGN KEY (workspace_id, calibrated_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (valid_until IS NULL OR valid_until >= calibrated_at),
    CHECK (uncertainty IS NULL OR uncertainty >= 0),
    CHECK (jsonb_typeof(calibration_data) = 'object')
);

CREATE TABLE coffee.process_runs (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    run_code text NOT NULL,
    process_code text NOT NULL CHECK (process_code IN (
        'controlled_fermentation', 'hybrid_drying', 'optical_sorting', 'hot_air_roasting'
    )),
    input_lot_id bigint NOT NULL,
    input_material_stage text NOT NULL
        CHECK (input_material_stage IN ('cherry', 'dried_cherry', 'dry_parchment', 'green', 'roasted')),
    input_weight_kg numeric(16,4) CHECK (input_weight_kg >= 0),
    equipment_id bigint,
    recipe_id bigint,
    run_status text NOT NULL DEFAULT 'planned'
        CHECK (run_status IN ('planned', 'running', 'completed', 'review_required', 'aborted', 'failed')),
    started_at timestamptz,
    finished_at timestamptz,
    recipe_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
    parameter_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
    source_references jsonb NOT NULL DEFAULT '[]'::jsonb,
    notes text,
    recorded_by_actor_id bigint,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, run_code),
    FOREIGN KEY (workspace_id, input_lot_id) REFERENCES coffee.lots(workspace_id, id),
    FOREIGN KEY (workspace_id, equipment_id) REFERENCES coffee.process_equipment(workspace_id, id),
    FOREIGN KEY (workspace_id, process_code, recipe_id)
        REFERENCES coffee.process_recipes(workspace_id, process_code, id),
    FOREIGN KEY (workspace_id, recorded_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (finished_at IS NULL OR started_at IS NULL OR finished_at >= started_at),
    CHECK (jsonb_typeof(recipe_snapshot) = 'object'),
    CHECK (jsonb_typeof(parameter_snapshot) = 'object'),
    CHECK (jsonb_typeof(source_references) = 'array')
);

CREATE TABLE coffee.process_sensor_readings (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    process_run_id bigint NOT NULL,
    equipment_id bigint,
    calibration_id bigint,
    inbox_item_id bigint,
    sensor_code text NOT NULL,
    metric_code text NOT NULL,
    value_numeric numeric(18,8) NOT NULL,
    unit text NOT NULL,
    observed_at timestamptz NOT NULL,
    is_derived boolean NOT NULL DEFAULT false,
    derivation_method text,
    derivation_version text,
    measurement_status text NOT NULL DEFAULT 'unverified'
        CHECK (measurement_status IN ('unverified', 'valid', 'flagged', 'invalid')),
    raw_reading jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, process_run_id) REFERENCES coffee.process_runs(workspace_id, id),
    FOREIGN KEY (workspace_id, equipment_id) REFERENCES coffee.process_equipment(workspace_id, id),
    FOREIGN KEY (workspace_id, calibration_id) REFERENCES coffee.sensor_calibrations(workspace_id, id),
    FOREIGN KEY (workspace_id, inbox_item_id) REFERENCES coffee.data_inbox_items(workspace_id, id),
    CHECK ((is_derived = false AND derivation_method IS NULL)
        OR (is_derived = true AND derivation_method IS NOT NULL)),
    CHECK (jsonb_typeof(raw_reading) = 'object')
);

-- This table records commands/responses; it does not itself execute hardware control.
CREATE TABLE coffee.process_control_events (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    process_run_id bigint NOT NULL,
    control_point text NOT NULL,
    event_kind text NOT NULL CHECK (event_kind IN ('setpoint', 'command', 'response', 'interlock')),
    control_mode text NOT NULL CHECK (control_mode IN ('manual', 'automatic', 'safety_interlock')),
    event_status text NOT NULL CHECK (event_status IN ('requested', 'accepted', 'applied', 'rejected', 'failed')),
    command_value jsonb,
    actual_value jsonb,
    source_device_ref text,
    request_reference text,
    reason text,
    actor_id bigint,
    occurred_at timestamptz NOT NULL,
    acknowledged_at timestamptz,
    event_data jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, process_run_id) REFERENCES coffee.process_runs(workspace_id, id),
    FOREIGN KEY (workspace_id, actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (acknowledged_at IS NULL OR acknowledged_at >= occurred_at),
    CHECK (command_value IS NULL OR jsonb_typeof(command_value) IN ('object', 'array', 'string', 'number', 'boolean')),
    CHECK (actual_value IS NULL OR jsonb_typeof(actual_value) IN ('object', 'array', 'string', 'number', 'boolean')),
    CHECK (jsonb_typeof(event_data) = 'object')
);

CREATE TABLE coffee.process_outputs (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    process_run_id bigint NOT NULL,
    output_code text NOT NULL,
    output_kind text NOT NULL CHECK (output_kind IN ('accepted', 'rejected', 'byproduct', 'sample')),
    material_stage text NOT NULL
        CHECK (material_stage IN ('cherry', 'dried_cherry', 'dry_parchment', 'green', 'roasted')),
    output_weight_kg numeric(16,4) NOT NULL CHECK (output_weight_kg >= 0),
    destination_lot_id bigint,
    output_data jsonb NOT NULL DEFAULT '{}'::jsonb,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, process_run_id, output_code),
    FOREIGN KEY (workspace_id, process_run_id) REFERENCES coffee.process_runs(workspace_id, id),
    FOREIGN KEY (workspace_id, destination_lot_id) REFERENCES coffee.lots(workspace_id, id),
    CHECK (jsonb_typeof(output_data) = 'object')
);

CREATE TABLE coffee.lot_events (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    lot_id bigint NOT NULL,
    event_type text NOT NULL,
    occurred_at timestamptz NOT NULL,
    input_weight_kg numeric(16,4),
    output_weight_kg numeric(16,4),
    actor_id bigint,
    details jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, lot_id) REFERENCES coffee.lots(workspace_id, id),
    FOREIGN KEY (workspace_id, actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (input_weight_kg IS NULL OR input_weight_kg >= 0),
    CHECK (output_weight_kg IS NULL OR output_weight_kg >= 0),
    CHECK (jsonb_typeof(details) = 'object')
);

CREATE TABLE coffee.samples (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    lot_id bigint NOT NULL,
    sample_code text NOT NULL,
    weight_g numeric(12,3) NOT NULL CHECK (weight_g > 0),
    sampled_at timestamptz NOT NULL,
    sampled_by_actor_id bigint,
    sampling_method text NOT NULL,
    sample_purpose text NOT NULL,
    protocol_code text,
    protocol_version text,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, lot_id, id),
    UNIQUE (workspace_id, lot_id, sample_code),
    FOREIGN KEY (workspace_id, lot_id) REFERENCES coffee.lots(workspace_id, id),
    FOREIGN KEY (workspace_id, sampled_by_actor_id) REFERENCES coffee.actors(workspace_id, id)
);

-- Versioned rules: no unverified SCA thresholds are included in this draft.
CREATE TABLE coffee.defect_types (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    code text NOT NULL,
    name_th text NOT NULL,
    name_en text,
    counting_unit text NOT NULL,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, code)
);

CREATE TABLE coffee.rule_sets (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    code text NOT NULL,
    version text NOT NULL,
    name text NOT NULL,
    rule_kind text NOT NULL CHECK (rule_kind IN ('standard_profile', 'business_profile')),
    species_scope text NOT NULL,
    protocol_code text NOT NULL,
    protocol_version text NOT NULL,
    required_sample_weight_g numeric(12,3) CHECK (required_sample_weight_g > 0),
    definition jsonb NOT NULL,
    source_references jsonb NOT NULL,
    status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'retired')),
    approved_by_actor_id bigint,
    approved_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, code, version),
    FOREIGN KEY (workspace_id, approved_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (jsonb_typeof(definition) = 'object'),
    CHECK (jsonb_typeof(source_references) = 'array'),
    CHECK (status <> 'published' OR (approved_by_actor_id IS NOT NULL AND approved_at IS NOT NULL))
);

CREATE TABLE coffee.defect_rules (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    rule_set_id bigint NOT NULL,
    defect_type_id bigint NOT NULL,
    category text NOT NULL CHECK (category IN ('primary', 'secondary')),
    units_per_full_defect numeric(12,4) NOT NULL CHECK (units_per_full_defect > 0),
    rounding_policy text NOT NULL,
    aggregation_policy jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, rule_set_id, defect_type_id),
    FOREIGN KEY (workspace_id, rule_set_id) REFERENCES coffee.rule_sets(workspace_id, id),
    FOREIGN KEY (workspace_id, defect_type_id) REFERENCES coffee.defect_types(workspace_id, id),
    CHECK (jsonb_typeof(aggregation_policy) = 'object')
);

CREATE TABLE coffee.physical_assessments (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    lot_id bigint NOT NULL,
    sample_id bigint NOT NULL,
    assessed_at timestamptz NOT NULL,
    assessed_by_actor_id bigint,
    record_status text NOT NULL DEFAULT 'draft' CHECK (record_status IN ('draft', 'finalized', 'superseded')),
    moisture_pct numeric(7,4),
    water_activity numeric(6,5),
    measurement_method text,
    instrument_reference text,
    sensor_calibration_id bigint,
    source_inbox_observation_id bigint,
    defect_check_complete boolean NOT NULL DEFAULT false,
    screen_check_complete boolean NOT NULL DEFAULT false,
    screened_input_weight_g numeric(12,3),
    safety_observations jsonb NOT NULL DEFAULT '{}'::jsonb,
    source_references jsonb NOT NULL DEFAULT '[]'::jsonb,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, lot_id, id),
    FOREIGN KEY (workspace_id, lot_id, sample_id) REFERENCES coffee.samples(workspace_id, lot_id, id),
    FOREIGN KEY (workspace_id, sensor_calibration_id) REFERENCES coffee.sensor_calibrations(workspace_id, id),
    FOREIGN KEY (workspace_id, source_inbox_observation_id) REFERENCES coffee.data_inbox_observations(workspace_id, id),
    FOREIGN KEY (workspace_id, assessed_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (moisture_pct IS NULL OR moisture_pct BETWEEN 0 AND 100),
    CHECK (water_activity IS NULL OR water_activity BETWEEN 0 AND 1),
    CHECK (screened_input_weight_g IS NULL OR screened_input_weight_g > 0),
    CHECK (jsonb_typeof(safety_observations) = 'object'),
    CHECK (jsonb_typeof(source_references) = 'array')
);

CREATE TABLE coffee.defect_observations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    physical_assessment_id bigint NOT NULL,
    defect_type_id bigint NOT NULL,
    raw_count integer NOT NULL CHECK (raw_count >= 0),
    source_inbox_observation_id bigint,
    observation_notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, physical_assessment_id, defect_type_id),
    FOREIGN KEY (workspace_id, physical_assessment_id) REFERENCES coffee.physical_assessments(workspace_id, id),
    FOREIGN KEY (workspace_id, defect_type_id) REFERENCES coffee.defect_types(workspace_id, id),
    FOREIGN KEY (workspace_id, source_inbox_observation_id) REFERENCES coffee.data_inbox_observations(workspace_id, id)
);

CREATE TABLE coffee.screen_results (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    physical_assessment_id bigint NOT NULL,
    screen_code text NOT NULL,
    screen_number smallint,
    retained_weight_g numeric(12,3) NOT NULL CHECK (retained_weight_g >= 0),
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, physical_assessment_id, screen_code),
    UNIQUE (workspace_id, physical_assessment_id, screen_number),
    FOREIGN KEY (workspace_id, physical_assessment_id) REFERENCES coffee.physical_assessments(workspace_id, id),
    CHECK ((screen_code = 'PAN' AND screen_number IS NULL)
        OR (screen_code <> 'PAN' AND screen_number IS NOT NULL AND screen_number > 0))
);

CREATE TABLE coffee.sensory_assessments (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    lot_id bigint NOT NULL,
    sample_id bigint NOT NULL,
    observed_at timestamptz NOT NULL,
    observer_actor_id bigint,
    method_code text,
    record_status text NOT NULL DEFAULT 'draft' CHECK (record_status IN ('draft', 'finalized', 'superseded')),
    confirmed_by_actor_id bigint,
    confirmed_at timestamptz,
    source_references jsonb NOT NULL DEFAULT '[]'::jsonb,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, lot_id, id),
    FOREIGN KEY (workspace_id, lot_id, sample_id) REFERENCES coffee.samples(workspace_id, lot_id, id),
    FOREIGN KEY (workspace_id, observer_actor_id) REFERENCES coffee.actors(workspace_id, id),
    FOREIGN KEY (workspace_id, confirmed_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK ((confirmed_by_actor_id IS NULL AND confirmed_at IS NULL)
        OR (confirmed_by_actor_id IS NOT NULL AND confirmed_at IS NOT NULL)),
    CHECK (jsonb_typeof(source_references) = 'array')
);

CREATE TABLE coffee.sensory_observations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    sensory_assessment_id bigint NOT NULL,
    descriptor text NOT NULL,
    descriptor_category text,
    observation_source text NOT NULL CHECK (observation_source IN ('human_observation', 'document', 'ai_draft')),
    observation_status text NOT NULL DEFAULT 'unverified'
        CHECK (observation_status IN ('unverified', 'confirmed', 'rejected')),
    language_code text NOT NULL DEFAULT 'th',
    source_reference text,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, sensory_assessment_id) REFERENCES coffee.sensory_assessments(workspace_id, id)
);

-- Store exact inputs and rule outputs. Reassessment inserts another row.
CREATE TABLE coffee.lot_evaluations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    lot_id bigint NOT NULL,
    physical_assessment_id bigint,
    rule_set_id bigint NOT NULL,
    supersedes_evaluation_id bigint,
    request_key text NOT NULL,
    engine_version text NOT NULL,
    evaluation_status text NOT NULL
        CHECK (evaluation_status IN ('provisional', 'complete', 'insufficient_data')),
    physical_grade_code text,
    commercial_label text,
    primary_full_defects numeric(12,4),
    secondary_full_defects numeric(12,4),
    safety_status text NOT NULL DEFAULT 'unknown'
        CHECK (safety_status IN ('unknown', 'clear', 'hold', 'rejected')),
    input_snapshot jsonb NOT NULL,
    checks jsonb NOT NULL,
    missing_fields jsonb NOT NULL DEFAULT '[]'::jsonb,
    screen_distribution jsonb NOT NULL DEFAULT '{}'::jsonb,
    gap_analysis jsonb NOT NULL DEFAULT '{}'::jsonb,
    evaluated_by_actor_id bigint,
    evaluated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, lot_id, id),
    UNIQUE (workspace_id, request_key),
    FOREIGN KEY (workspace_id, lot_id) REFERENCES coffee.lots(workspace_id, id),
    FOREIGN KEY (workspace_id, lot_id, physical_assessment_id) REFERENCES coffee.physical_assessments(workspace_id, lot_id, id),
    FOREIGN KEY (workspace_id, rule_set_id) REFERENCES coffee.rule_sets(workspace_id, id),
    FOREIGN KEY (workspace_id, lot_id, supersedes_evaluation_id) REFERENCES coffee.lot_evaluations(workspace_id, lot_id, id),
    FOREIGN KEY (workspace_id, evaluated_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (supersedes_evaluation_id IS NULL OR supersedes_evaluation_id <> id),
    CHECK (primary_full_defects IS NULL OR primary_full_defects >= 0),
    CHECK (secondary_full_defects IS NULL OR secondary_full_defects >= 0),
    CHECK (jsonb_typeof(input_snapshot) = 'object'),
    CHECK (jsonb_typeof(checks) = 'array'),
    CHECK (jsonb_typeof(missing_fields) = 'array'),
    CHECK (jsonb_typeof(screen_distribution) = 'object'),
    CHECK (jsonb_typeof(gap_analysis) = 'object')
);

CREATE TABLE coffee.market_observations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    observation_kind text NOT NULL CHECK (observation_kind IN ('asking', 'bid', 'transaction')),
    source_name text NOT NULL,
    source_reference text NOT NULL,
    observed_at timestamptz NOT NULL,
    valid_until timestamptz,
    country_code varchar(2),
    region text,
    species text,
    process_code text,
    harvest_label text,
    physical_grade_code text,
    grade_profile_reference text,
    material_stage text NOT NULL CHECK (material_stage IN ('cherry', 'dried_cherry', 'dry_parchment', 'green', 'roasted')),
    price_per_kg numeric(16,4) NOT NULL CHECK (price_per_kg >= 0),
    currency varchar(3) NOT NULL,
    quantity_kg numeric(16,4),
    price_basis jsonb NOT NULL,
    recorded_by_actor_id bigint,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, recorded_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (currency ~ '^[A-Z]{3}$'),
    CHECK (quantity_kg IS NULL OR quantity_kg > 0),
    CHECK (valid_until IS NULL OR valid_until >= observed_at),
    CHECK (jsonb_typeof(price_basis) = 'object')
);

CREATE TABLE coffee.price_estimations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    lot_id bigint NOT NULL,
    evaluation_id bigint NOT NULL,
    method_code text NOT NULL,
    method_version text NOT NULL,
    estimate_status text NOT NULL CHECK (estimate_status IN ('evidence_based', 'scenario', 'insufficient_data')),
    price_low_per_kg numeric(16,4),
    price_high_per_kg numeric(16,4),
    currency varchar(3) NOT NULL,
    material_stage text NOT NULL CHECK (material_stage IN ('cherry', 'dried_cherry', 'dry_parchment', 'green', 'roasted')),
    price_basis jsonb NOT NULL,
    assumptions jsonb NOT NULL,
    input_snapshot jsonb NOT NULL,
    evidence_summary jsonb NOT NULL,
    estimated_by_actor_id bigint,
    estimated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, lot_id, evaluation_id) REFERENCES coffee.lot_evaluations(workspace_id, lot_id, id),
    FOREIGN KEY (workspace_id, estimated_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (currency ~ '^[A-Z]{3}$'),
    CHECK ((price_low_per_kg IS NULL AND price_high_per_kg IS NULL)
        OR (price_low_per_kg IS NOT NULL AND price_high_per_kg IS NOT NULL
            AND price_low_per_kg >= 0 AND price_low_per_kg <= price_high_per_kg)),
    CHECK ((estimate_status = 'insufficient_data' AND price_low_per_kg IS NULL AND price_high_per_kg IS NULL)
        OR (estimate_status <> 'insufficient_data' AND price_low_per_kg IS NOT NULL AND price_high_per_kg IS NOT NULL)),
    CHECK (jsonb_typeof(price_basis) = 'object'),
    CHECK (jsonb_typeof(assumptions) = 'object'),
    CHECK (jsonb_typeof(input_snapshot) = 'object'),
    CHECK (jsonb_typeof(evidence_summary) = 'object')
);

CREATE TABLE coffee.price_estimation_sources (
    workspace_id bigint NOT NULL,
    price_estimation_id bigint NOT NULL,
    market_observation_id bigint NOT NULL,
    applied_weight numeric(12,6) CHECK (applied_weight >= 0),
    normalized_price_per_kg numeric(16,4) CHECK (normalized_price_per_kg >= 0),
    adjustments jsonb NOT NULL DEFAULT '{}'::jsonb,
    PRIMARY KEY (workspace_id, price_estimation_id, market_observation_id),
    FOREIGN KEY (workspace_id, price_estimation_id) REFERENCES coffee.price_estimations(workspace_id, id),
    FOREIGN KEY (workspace_id, market_observation_id) REFERENCES coffee.market_observations(workspace_id, id),
    CHECK (jsonb_typeof(adjustments) = 'object')
);

CREATE TABLE coffee.conversion_scenarios (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    lot_id bigint NOT NULL,
    name text NOT NULL,
    method_version text NOT NULL,
    input_stage text NOT NULL CHECK (input_stage IN ('cherry', 'dried_cherry', 'dry_parchment', 'green')),
    output_stage text NOT NULL CHECK (output_stage IN ('dried_cherry', 'dry_parchment', 'green', 'roasted')),
    input_weight_kg numeric(16,4) NOT NULL CHECK (input_weight_kg > 0),
    raw_material_cost numeric(18,4),
    currency varchar(3) NOT NULL,
    process_steps jsonb NOT NULL,
    output_weight_low_kg numeric(16,4),
    output_weight_high_kg numeric(16,4),
    actual_output_weight_kg numeric(16,4),
    total_cost numeric(18,4),
    break_even_low_per_kg numeric(16,4),
    break_even_high_per_kg numeric(16,4),
    calculation_status text NOT NULL CHECK (calculation_status IN ('complete', 'partial', 'invalid')),
    assumptions jsonb NOT NULL,
    created_by_actor_id bigint,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, lot_id) REFERENCES coffee.lots(workspace_id, id),
    FOREIGN KEY (workspace_id, created_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (currency ~ '^[A-Z]{3}$'),
    CHECK (raw_material_cost IS NULL OR raw_material_cost >= 0),
    CHECK (actual_output_weight_kg IS NULL OR actual_output_weight_kg >= 0),
    CHECK (total_cost IS NULL OR total_cost >= 0),
    CHECK ((output_weight_low_kg IS NULL AND output_weight_high_kg IS NULL)
        OR (output_weight_low_kg IS NOT NULL AND output_weight_high_kg IS NOT NULL
            AND output_weight_low_kg >= 0 AND output_weight_low_kg <= output_weight_high_kg)),
    CHECK ((break_even_low_per_kg IS NULL AND break_even_high_per_kg IS NULL)
        OR (break_even_low_per_kg IS NOT NULL AND break_even_high_per_kg IS NOT NULL
            AND break_even_low_per_kg >= 0 AND break_even_low_per_kg <= break_even_high_per_kg)),
    CHECK (jsonb_typeof(process_steps) = 'array'),
    CHECK (jsonb_typeof(assumptions) = 'object')
);

CREATE TABLE coffee.conversion_cost_items (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    conversion_scenario_id bigint NOT NULL,
    cost_category text NOT NULL,
    description text NOT NULL,
    amount numeric(18,4) NOT NULL CHECK (amount >= 0),
    cost_basis jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, conversion_scenario_id) REFERENCES coffee.conversion_scenarios(workspace_id, id),
    CHECK (jsonb_typeof(cost_basis) = 'object')
);

CREATE TABLE coffee.recommendations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    lot_id bigint NOT NULL,
    evaluation_id bigint NOT NULL,
    recommendation_kind text NOT NULL
        CHECK (recommendation_kind IN ('value_add', 'product_match', 'anti_downgrade', 'quality_action', 'safety_warning')),
    product_code text,
    suggested_roast_level text,
    severity text NOT NULL CHECK (severity IN ('info', 'warning', 'critical')),
    title text NOT NULL,
    rationale text NOT NULL,
    action_details jsonb NOT NULL,
    source_references jsonb NOT NULL,
    policy_version text NOT NULL,
    decision_status text NOT NULL DEFAULT 'suggested'
        CHECK (decision_status IN ('suggested', 'accepted', 'dismissed', 'overridden')),
    decision_reason text,
    decided_by_actor_id bigint,
    decided_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, lot_id, evaluation_id) REFERENCES coffee.lot_evaluations(workspace_id, lot_id, id),
    FOREIGN KEY (workspace_id, decided_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (decision_status <> 'overridden' OR (decision_reason IS NOT NULL AND length(btrim(decision_reason)) > 0)),
    CHECK (jsonb_typeof(action_details) = 'object'),
    CHECK (jsonb_typeof(source_references) = 'array')
);

CREATE TABLE coffee.chat_sessions (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    owner_actor_id bigint NOT NULL,
    lot_id bigint,
    title text,
    context jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    archived_at timestamptz,
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, owner_actor_id) REFERENCES coffee.actors(workspace_id, id),
    FOREIGN KEY (workspace_id, lot_id) REFERENCES coffee.lots(workspace_id, id),
    CHECK (jsonb_typeof(context) = 'object')
);

CREATE TABLE coffee.chat_messages (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    session_id bigint NOT NULL,
    role text NOT NULL CHECK (role IN ('user', 'assistant', 'tool')),
    content text NOT NULL,
    source_references jsonb NOT NULL DEFAULT '[]'::jsonb,
    model_reference text,
    message_status text NOT NULL DEFAULT 'complete' CHECK (message_status IN ('complete', 'failed', 'partial')),
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, session_id) REFERENCES coffee.chat_sessions(workspace_id, id),
    CHECK (jsonb_typeof(source_references) = 'array')
);

CREATE TABLE coffee.chat_tool_runs (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL,
    message_id bigint NOT NULL,
    tool_name text NOT NULL,
    tool_version text NOT NULL,
    arguments jsonb NOT NULL,
    result_references jsonb NOT NULL DEFAULT '[]'::jsonb,
    run_status text NOT NULL CHECK (run_status IN ('succeeded', 'failed', 'denied')),
    error_code text,
    started_at timestamptz NOT NULL,
    finished_at timestamptz,
    UNIQUE (workspace_id, id),
    FOREIGN KEY (workspace_id, message_id) REFERENCES coffee.chat_messages(workspace_id, id),
    CHECK (finished_at IS NULL OR finished_at >= started_at),
    CHECK (jsonb_typeof(arguments) = 'object'),
    CHECK (jsonb_typeof(result_references) = 'array')
);

CREATE TABLE coffee.documents (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    lot_id bigint,
    evaluation_id bigint,
    document_code text NOT NULL,
    version integer NOT NULL CHECK (version > 0),
    document_kind text NOT NULL CHECK (document_kind IN ('executive_summary', 'tasting_card', 'comparison_report')),
    language_code text NOT NULL DEFAULT 'th',
    title text NOT NULL,
    content_text text NOT NULL,
    input_snapshot jsonb NOT NULL,
    source_references jsonb NOT NULL,
    storage_key text,
    mime_type text,
    content_sha256 varchar(64),
    status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'superseded')),
    created_by_actor_id bigint,
    approved_by_actor_id bigint,
    approved_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, id),
    UNIQUE (workspace_id, document_code, version),
    FOREIGN KEY (workspace_id, lot_id) REFERENCES coffee.lots(workspace_id, id),
    FOREIGN KEY (workspace_id, lot_id, evaluation_id) REFERENCES coffee.lot_evaluations(workspace_id, lot_id, id),
    FOREIGN KEY (workspace_id, created_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    FOREIGN KEY (workspace_id, approved_by_actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (evaluation_id IS NULL OR lot_id IS NOT NULL),
    CHECK (status <> 'approved' OR (approved_by_actor_id IS NOT NULL AND approved_at IS NOT NULL)),
    CHECK (content_sha256 IS NULL OR content_sha256 ~ '^[0-9a-f]{64}$'),
    CHECK (jsonb_typeof(input_snapshot) = 'object'),
    CHECK (jsonb_typeof(source_references) = 'array')
);

CREATE TABLE coffee.audit_events (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint NOT NULL REFERENCES coffee.workspaces(id),
    actor_id bigint,
    action text NOT NULL,
    entity_type text NOT NULL,
    entity_id text NOT NULL,
    request_reference text,
    change_summary jsonb NOT NULL,
    occurred_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (workspace_id, actor_id) REFERENCES coffee.actors(workspace_id, id),
    CHECK (jsonb_typeof(change_summary) = 'object')
);

-- Common access patterns. Additional indexes follow actual query workloads.
CREATE INDEX lots_workspace_received_idx ON coffee.lots (workspace_id, received_at DESC);
CREATE INDEX lots_workspace_status_idx ON coffee.lots (workspace_id, workflow_status, safety_status);
CREATE INDEX lots_workspace_farm_idx ON coffee.lots (workspace_id, farm_id);
CREATE INDEX data_inbox_workspace_review_idx ON coffee.data_inbox_items (workspace_id, review_status, captured_at DESC);
CREATE INDEX data_inbox_workspace_lot_idx ON coffee.data_inbox_items (workspace_id, lot_id, captured_at DESC);
CREATE UNIQUE INDEX data_inbox_source_event_idx ON coffee.data_inbox_items
    (workspace_id, source_system, COALESCE(source_device_ref, ''), source_event_ref)
    WHERE source_event_ref IS NOT NULL;
CREATE INDEX inbox_observations_item_kind_idx ON coffee.data_inbox_observations
    (workspace_id, inbox_item_id, observation_kind, verification_status);
CREATE INDEX equipment_workspace_kind_idx ON coffee.process_equipment (workspace_id, equipment_kind, equipment_status);
CREATE INDEX sensor_calibration_validity_idx ON coffee.sensor_calibrations
    (workspace_id, equipment_id, sensor_code, valid_until DESC);
CREATE INDEX process_runs_lot_time_idx ON coffee.process_runs
    (workspace_id, input_lot_id, started_at DESC NULLS LAST);
CREATE INDEX process_runs_equipment_time_idx ON coffee.process_runs
    (workspace_id, equipment_id, started_at DESC NULLS LAST);
CREATE INDEX process_readings_run_metric_time_idx ON coffee.process_sensor_readings
    (workspace_id, process_run_id, metric_code, observed_at);
CREATE INDEX process_control_run_time_idx ON coffee.process_control_events
    (workspace_id, process_run_id, occurred_at);
CREATE INDEX process_outputs_run_idx ON coffee.process_outputs (workspace_id, process_run_id, output_kind);
CREATE INDEX process_outputs_destination_lot_idx ON coffee.process_outputs (workspace_id, destination_lot_id)
    WHERE destination_lot_id IS NOT NULL;
CREATE INDEX lot_events_lot_time_idx ON coffee.lot_events (workspace_id, lot_id, occurred_at DESC);
CREATE INDEX samples_lot_time_idx ON coffee.samples (workspace_id, lot_id, sampled_at DESC);
CREATE INDEX physical_lot_time_idx ON coffee.physical_assessments (workspace_id, lot_id, assessed_at DESC);
CREATE INDEX sensory_lot_time_idx ON coffee.sensory_assessments (workspace_id, lot_id, observed_at DESC);
CREATE INDEX sensory_observation_descriptor_idx ON coffee.sensory_observations
    (workspace_id, sensory_assessment_id, descriptor_category, descriptor);
CREATE INDEX evaluations_lot_time_idx ON coffee.lot_evaluations (workspace_id, lot_id, evaluated_at DESC);
CREATE INDEX evaluations_workspace_grade_idx ON coffee.lot_evaluations (workspace_id, rule_set_id, physical_grade_code, evaluated_at DESC);
CREATE INDEX market_lookup_idx ON coffee.market_observations (workspace_id, material_stage, currency, process_code, observed_at DESC);
CREATE INDEX prices_lot_time_idx ON coffee.price_estimations (workspace_id, lot_id, estimated_at DESC);
CREATE INDEX conversions_lot_time_idx ON coffee.conversion_scenarios (workspace_id, lot_id, created_at DESC);
CREATE INDEX recommendations_lot_time_idx ON coffee.recommendations (workspace_id, lot_id, created_at DESC);
CREATE INDEX sessions_owner_time_idx ON coffee.chat_sessions (workspace_id, owner_actor_id, updated_at DESC);
CREATE INDEX messages_session_time_idx ON coffee.chat_messages (workspace_id, session_id, created_at, id);
CREATE INDEX tool_runs_message_idx ON coffee.chat_tool_runs (workspace_id, message_id);
CREATE INDEX documents_lot_time_idx ON coffee.documents (workspace_id, lot_id, created_at DESC);
CREATE INDEX audit_entity_time_idx ON coffee.audit_events (workspace_id, entity_type, entity_id, occurred_at DESC);

-- Optional numeric fields must remain NULL when not measured; zero is a real observation.
COMMENT ON COLUMN coffee.physical_assessments.defect_check_complete IS
    'No defect rows is not equivalent to zero defects unless the check is explicitly complete and validated.';
COMMENT ON COLUMN coffee.physical_assessments.sensor_calibration_id IS
    'Optional calibration record for the instrument used, including a capacitive moisture meter.';
COMMENT ON COLUMN coffee.screen_results.retained_weight_g IS
    'Non-overlapping retained fraction; cumulative Screen 16+/18+ is derived, not inserted as another fraction.';
COMMENT ON COLUMN coffee.rule_sets.definition IS
    'Versioned grades, eligibility checks, screen/moisture policy and protocol rules; validate against an application JSON schema.';
COMMENT ON COLUMN coffee.conversion_scenarios.process_steps IS
    'Ordered stages with explicit yield ranges and moisture basis; validate stage continuity and yields before calculation.';
COMMENT ON COLUMN coffee.data_inbox_items.review_status IS
    'Incoming records are not part of a Lot until manually reviewed and assigned.';
COMMENT ON COLUMN coffee.data_inbox_observations.verification_status IS
    'Model findings are suggestions until reviewed; do not use unverified detections as confirmed defect counts.';
COMMENT ON COLUMN coffee.process_sensor_readings.is_derived IS
    'Derived metrics such as RoR must retain method/version and are not raw instrument readings.';
COMMENT ON COLUMN coffee.process_control_events.event_status IS
    'Audit record of intended/actual control state; storing an event does not authorize or execute hardware commands.';
COMMENT ON COLUMN coffee.process_outputs.destination_lot_id IS
    'Links a separated or transformed output stream, such as accepted sorted beans or roasted coffee, to its Lot.';
COMMENT ON COLUMN coffee.lot_evaluations.input_snapshot IS
    'Exact lot, sample, measurements, raw defect counts and rule version used for this evaluation.';
COMMENT ON COLUMN coffee.market_observations.price_basis IS
    'Explicit VAT, freight, location, moisture basis, product stage and other comparability conditions.';
COMMENT ON COLUMN coffee.documents.source_references IS
    'Exact evaluation/assessment IDs; comparison documents reference both lots and both evaluation versions.';

-- Before production:
-- 1. Map or remove provisional workspace/actor references against the existing schema;
--    this draft does not define local accounts or authentication.
-- 2. Add tenant row-level policies only after the existing authentication/tenant model is known.
-- 3. Protect finalized assessments and their child observations; published rules,
--    evaluations, market evidence and approved report versions must not be overwritten.
-- 4. Maintain updated_at and append-only audit records through the agreed write path.
-- 5. Require finalized source assessments and a published, applicable rule set for
--    complete evaluations; validate sample weights and missing checks in the engine.
-- 6. Validate source sufficiency for evidence-based prices and snapshot all sources.
-- 7. Validate conversion stage continuity, yield ranges, costs and denominator > 0.
-- 8. Validate process stage continuity, calibration links, run/output weights and
--    keep actuator audit separate from hardware command execution.
-- 9. Confirm media object-storage keys, retention and lot-lineage policies.
-- 10. Apply migrations and verify with the actual PostgreSQL version in an isolated DB.

COMMIT;
