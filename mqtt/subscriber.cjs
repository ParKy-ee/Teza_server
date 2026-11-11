require('@next/env').loadEnvConfig(process.cwd());
const mqtt = require('mqtt');
const { parseEvent } = require('./contract.cjs');

const url = process.env.MQTT_URL;
const topic = process.env.MQTT_TOPIC;
if (!url || !topic) { console.error('Set MQTT_URL and MQTT_TOPIC in .env before starting.'); process.exit(1); }
const numberSetting = (name, fallback) => {
  const value = process.env[name] === undefined ? fallback : Number(process.env[name]);
  if (!Number.isSafeInteger(value) || value <= 0) throw new Error(`${name} must be a positive integer`);
  return value;
};
const limits = { messageBytes: numberSetting('MQTT_MAX_MESSAGE_BYTES', 10 * 1024 * 1024), imageBytes: numberSetting('MQTT_MAX_IMAGE_BYTES', 512 * 1024), imagePixels: numberSetting('MQTT_MAX_IMAGE_PIXELS', 4_000_000) };
const client = mqtt.connect(url, { username: process.env.MQTT_USERNAME || undefined, password: process.env.MQTT_PASSWORD || undefined, reconnectPeriod: 5000 });
client.on('connect', () => { console.log('MQTT connected; subscribing to configured topic'); client.subscribe(topic, { qos: 1 }, (error) => { if (error) console.error('Subscribe failed:', error.message); }); });
client.on('error', (error) => console.error('MQTT error:', error.message));
// Serial processing bounds simultaneous JPEG decoding. This is a validation-only skeleton:
// MQTT transport acknowledgements do not mean the event was persisted.
client.handleMessage = async (packet, done) => {
  try {
    const event = await parseEvent(packet.payload, limits);
    console.log(JSON.stringify({ outcome: 'validated_not_saved', event_id: event.event_id, device_id: event.device_id, batch_id: event.batch_id, total_count: event.summary.total_count }));
  } catch (error) {
    console.error('Rejected message:', error.issues ? JSON.stringify(error.issues.map(({ path, message }) => ({ path, message }))) : error.message);
  } finally { done(); }
};
for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => client.end(false, () => process.exit(0)));
