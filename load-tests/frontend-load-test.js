import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

// Configuration des étapes de charge
export let options = {
    stages: [
        { duration: '1m', target: 20 },   // Warm-up: monter à 20 users
        { duration: '2m', target: 50 },   // Charge normale: 50 users
        { duration: '2m', target: 100 },  // Charge élevée: 100 users
        { duration: '1m', target: 50 },   // Descente progressive
        { duration: '1m', target: 0 },    // Cool-down
    ],
    thresholds: {
        'http_req_duration': ['p(95)<500'],  // 95% des requêtes < 500ms
        'errors': ['rate<0.1'],               // < 10% d'erreurs
        'http_req_failed': ['rate<0.1'],      // < 10% de failed requests
    },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4200';

export default function () {
    // Test 1: Page d'accueil
    let homeRes = http.get(`${BASE_URL}/`);
    let homeCheck = check(homeRes, {
        'Homepage: status is 200': (r) => r.status === 200,
        'Homepage: response time < 500ms': (r) => r.timings.duration < 500,
        'Homepage: body contains title': (r) => r.body.includes('E-Commerce') || r.body.includes('Market'),
    });
    errorRate.add(!homeCheck);

    sleep(1);

    // Test 2: Page des produits
    let productsRes = http.get(`${BASE_URL}/home`);
    let productsCheck = check(productsRes, {
        'Products page: status is 200': (r) => r.status === 200,
        'Products page: response time < 500ms': (r) => r.timings.duration < 500,
    });
    errorRate.add(!productsCheck);

    sleep(1);

    // Test 3: Page de connexion
    let loginRes = http.get(`${BASE_URL}/login`);
    let loginCheck = check(loginRes, {
        'Login page: status is 200': (r) => r.status === 200,
        'Login page: response time < 500ms': (r) => r.timings.duration < 500,
    });
    errorRate.add(!loginCheck);

    sleep(2);
}

// Setup function (appelée une fois au début)
export function setup() {
    console.log(`🚀 Starting load test on ${BASE_URL}`);
    console.log(`📊 Test configuration:`);
    console.log(`   - Warm-up: 20 users (1 min)`);
    console.log(`   - Normal load: 50 users (2 min)`);
    console.log(`   - Peak load: 100 users (2 min)`);
    console.log(`   - Cool-down: 0 users (2 min)`);
}

// Teardown function (appelée une fois à la fin)
export function teardown(data) {
    console.log('✅ Load test completed!');
}
