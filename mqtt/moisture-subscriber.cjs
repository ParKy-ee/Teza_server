// Run as a long-lived backend worker alongside Next.js, not inside an API route.
require('@next/env').loadEnvConfig(process.cwd());
const mqtt = require('mqtt');

const brokerUrl = process.env.MQTT_URL || 'mqtt://127.0.0.1:1884';
const topic = process.env.MQTT_MOISTURE_TOPIC || 'coffee/moisture/data';
const maxBytes = 64 * 1024;
const client = mqtt.connect(brokerUrl, {
  username: process.env.MQTT_USERNAME || undefined,
  password: process.env.MQTT_PASSWORD || undefined,
  reconnectPeriod: 5000,
});

client.on('connect', () => {
  client.subscribe(topic, { qos: 1 }, (error, granted) => {
    if (error || !granted?.length || granted.some((item) => item.qos === 128)) {
      console.error('Moisture subscription failed:', error?.message || 'broker rejected subscription');
      return;
    }
    console.log(`Moisture subscriber connected; topic: ${topic}`);
  });
});
client.on('error', (error) => console.error('MQTT error:', error.message));
client.on('message', (receivedTopic, payload, packet) => {
  if (payload.length > maxBytes) {
    console.error(`Ignored oversized message on ${receivedTopic} (${payload.length} bytes)`);
    return;
  }
  const text = payload.toString('utf8');
  let message;
  try { message = JSON.parse(text); } catch { message = text; }
  console.log(JSON.stringify({ topic: receivedTopic, receivedAt: new Date().toISOString(), retained: packet.retain, message }));
});
for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => client.end(false, () => process.exit(0)));
