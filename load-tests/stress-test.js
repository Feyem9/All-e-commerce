import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

// Configuration pour test de stress (trouver les limites)
export let options = {
    stages: [
        { duration: '1m', target: 50 },    // Montée progressive
        { duration: '2m', target: 100 },   // Charge normale
        { duration: '2m', target: 200 },   // Stress test
        { duration: '2m', target: 300 },   // Stress élevé
        { duration: '1m', target: 0 },     // Recovery
    ],
    thresholds: {
        'http_req_duration': ['p(95)<3000'], // Plus tolérant pour stress test
        'errors': ['rate<0.2'],              // Accepter jusqu'à 20% erreurs
    },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4200';

export default function () {
    const res = http.get(BASE_URL);

    const checkResult = check(res, {
        'Status is 200': (r) => r.status === 200,
        'Response time < 3000ms': (r) => r.timings.duration < 3000,
    });

    errorRate.add(!checkResult);

    sleep(1);
}

export function setup() {
    console.log(`⚡ Starting STRESS TEST on ${BASE_URL}`);
    console.log(`⚠️  This test will push the system to its limits!`);
    console.log(`📊 Target: up to 300 concurrent users`);
}

export function teardown() {
    console.log(`✅ Stress test completed!`);
    console.log(`💡 Check the results to find your system's breaking point.`);
}
