import http from 'k6/http';
import { check, sleep } from 'k6';

// Test de pic soudain (Black Friday simulation)
export let options = {
    stages: [
        { duration: '30s', target: 10 },   // Normal traffic
        { duration: '10s', target: 200 },  // SPIKE! (Black Friday)
        { duration: '1m', target: 200 },   // Maintenir le pic
        { duration: '30s', target: 10 },   // Retour à la normale
        { duration: '30s', target: 0 },    // Cool-down
    ],
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4200';

export default function () {
    const res = http.get(BASE_URL);

    check(res, {
        'Status is 200': (r) => r.status === 200,
        'Response time acceptable': (r) => r.timings.duration < 5000, // Plus tolérant
    });

    sleep(0.5); // Moins de sleep = plus de requêtes
}

export function setup() {
    console.log(`🎯 Starting SPIKE TEST (Black Friday Simulation)`);
    console.log(`📈 Simulating sudden traffic spike from 10 to 200 users`);
}

export function teardown() {
    console.log(`✅ Spike test completed!`);
    console.log(`💡 Did your app survive the Black Friday rush?`);
}
