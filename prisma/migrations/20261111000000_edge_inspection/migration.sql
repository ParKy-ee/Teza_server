-- CreateTable
CREATE TABLE "DetectionEvent" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "deviceId" TEXT NOT NULL,
    "batchId" TEXT NOT NULL,
    "lotId" TEXT,
    "schemaVersion" TEXT NOT NULL,
    "modelVersion" TEXT NOT NULL,
    "classMapVersion" TEXT NOT NULL,
    "countScope" TEXT NOT NULL,
    "capturedAt" TIMESTAMPTZ(3) NOT NULL,
    "receivedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processingStatus" TEXT NOT NULL DEFAULT 'pending',
    "payloadFingerprint" TEXT,
    "sourceImageWidth" INTEGER,
    "sourceImageHeight" INTEGER,
    "totalCount" INTEGER NOT NULL,
    "normalCount" INTEGER NOT NULL,
    "defectCount" INTEGER NOT NULL,
    "countsByClass" JSONB NOT NULL,

    CONSTRAINT "DetectionEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Detection" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "detectionId" TEXT NOT NULL,
    "className" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "confidence" DOUBLE PRECISION NOT NULL,
    "modelClassId" INTEGER,
    "trackId" TEXT,
    "bboxX1" INTEGER,
    "bboxY1" INTEGER,
    "bboxX2" INTEGER,
    "bboxY2" INTEGER,
    "lengthMm" DOUBLE PRECISION,
    "widthMm" DOUBLE PRECISION,
    "sizeMethod" TEXT,
    "calibrationId" TEXT,
    "cropObjectKey" TEXT NOT NULL,
    "cropMimeType" TEXT NOT NULL,
    "cropWidth" INTEGER NOT NULL,
    "cropHeight" INTEGER NOT NULL,
    "cropBytes" INTEGER,
    "cropSha256" TEXT,

    CONSTRAINT "Detection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Measurement" (
    "id" TEXT NOT NULL,
    "batchId" TEXT NOT NULL,
    "lotId" TEXT,
    "eventId" TEXT,
    "sampleId" TEXT,
    "kind" TEXT NOT NULL,
    "value" DOUBLE PRECISION,
    "unit" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "method" TEXT,
    "sensorId" TEXT,
    "calibrationId" TEXT,
    "measuredAt" TIMESTAMPTZ(3) NOT NULL,
    "receivedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,

    CONSTRAINT "Measurement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InspectionReview" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "detectionId" TEXT,
    "reviewer" TEXT NOT NULL,
    "reviewedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "outcome" TEXT NOT NULL,
    "correctedClassName" TEXT,
    "notes" TEXT,

    CONSTRAINT "InspectionReview_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "DetectionEvent_eventId_key" ON "DetectionEvent"("eventId");

-- CreateIndex
CREATE INDEX "DetectionEvent_batchId_capturedAt_idx" ON "DetectionEvent"("batchId", "capturedAt");

-- CreateIndex
CREATE INDEX "DetectionEvent_lotId_capturedAt_idx" ON "DetectionEvent"("lotId", "capturedAt");

-- CreateIndex
CREATE INDEX "DetectionEvent_deviceId_capturedAt_idx" ON "DetectionEvent"("deviceId", "capturedAt");

-- CreateIndex
CREATE INDEX "Detection_eventId_className_idx" ON "Detection"("eventId", "className");

-- CreateIndex
CREATE UNIQUE INDEX "Detection_eventId_detectionId_key" ON "Detection"("eventId", "detectionId");

-- CreateIndex
CREATE INDEX "Measurement_batchId_measuredAt_idx" ON "Measurement"("batchId", "measuredAt");

-- CreateIndex
CREATE INDEX "Measurement_lotId_measuredAt_idx" ON "Measurement"("lotId", "measuredAt");

-- CreateIndex
CREATE INDEX "Measurement_eventId_idx" ON "Measurement"("eventId");

-- CreateIndex
CREATE INDEX "InspectionReview_eventId_reviewedAt_idx" ON "InspectionReview"("eventId", "reviewedAt");

-- CreateIndex
CREATE INDEX "InspectionReview_detectionId_reviewedAt_idx" ON "InspectionReview"("detectionId", "reviewedAt");

-- AddForeignKey
ALTER TABLE "DetectionEvent" ADD CONSTRAINT "DetectionEvent_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES "Lot"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Detection" ADD CONSTRAINT "Detection_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "DetectionEvent"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Measurement" ADD CONSTRAINT "Measurement_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES "Lot"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Measurement" ADD CONSTRAINT "Measurement_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "DetectionEvent"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InspectionReview" ADD CONSTRAINT "InspectionReview_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "DetectionEvent"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InspectionReview" ADD CONSTRAINT "InspectionReview_detectionId_fkey" FOREIGN KEY ("detectionId") REFERENCES "Detection"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
