import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const pageLoadTime = new Trend('page_load_time');

// Configuration simple et efficace
export let options = {
    stages: [
        { duration: '10s', target: 10 },   // Warm-up rapide
        { duration: '30s', target: 20 },   // Charge normale
        { duration: '30s', target: 30 },   // Charge élevée
        { duration: '10s', target: 0 },    // Cool-down
    ],
    thresholds: {
        'http_req_duration': ['p(95)<1000'],  // 95% < 1s
        'errors': ['rate<0.05'],               // < 5% erreurs
        'page_load_time': ['p(95)<1000'],
    },
};

const BASE_URL = __ENV.BASE_URL || 'https://market-jet.vercel.app';

export default function () {
    // Test 1: Page d'accueil
    let homeRes = http.get(`${BASE_URL}/`);
    let homeCheck = check(homeRes, {
        'Homepage: status 200': (r) => r.status === 200,
        'Homepage: load time < 1s': (r) => r.timings.duration < 1000,
        'Homepage: has content': (r) => r.body && r.body.length > 0,
    });
    errorRate.add(!homeCheck);
    pageLoadTime.add(homeRes.timings.duration);

    sleep(1);

    // Test 2: Page produits
    let productsRes = http.get(`${BASE_URL}/home`);
    let productsCheck = check(productsRes, {
        'Products: status 200': (r) => r.status === 200,
        'Products: load time < 1s': (r) => r.timings.duration < 1000,
    });
    errorRate.add(!productsCheck);
    pageLoadTime.add(productsRes.timings.duration);

    sleep(2);
}

export function setup() {
    console.log(`🚀 Frontend Load Test - Simple & Fast`);
    console.log(`🌐 URL: ${BASE_URL}`);
    console.log(`👥 Users: 0 → 10 → 20 → 30`);
    console.log(`⏱️  Duration: ~1 minute 20s`);
    console.log(``);
}

export function teardown(data) {
    console.log(``);
    console.log(`✅ Frontend test completed!`);
}
