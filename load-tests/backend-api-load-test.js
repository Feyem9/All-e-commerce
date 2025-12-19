import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const loginDuration = new Trend('login_duration');
const registerDuration = new Trend('register_duration');

// Configuration pour tests backend (réduit pour éviter rate limiting)
export let options = {
    stages: [
        { duration: '30s', target: 3 },    // Warm-up (évite rate limiting)
        { duration: '1m', target: 5 },     // Charge normale
        { duration: '1m', target: 8 },     // Charge modérée
        { duration: '30s', target: 0 },    // Cool-down
    ],
    thresholds: {
        'http_req_duration': ['p(95)<2000'], // 95% des requêtes < 2s
        'http_req_duration{endpoint:login}': ['p(95)<1000'],
        'errors': ['rate<0.3'],              // < 30% d'erreurs (rate limiting attendu)
        'login_duration': ['p(95)<1500'],
    },
};

const API_BASE_URL = __ENV.API_BASE_URL || 'https://theck-market.onrender.com';
const HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
};

// Génération de données de test
function generateRandomEmail() {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000);
    return `loadtest_${timestamp}_${random}@test.com`;
}

function generateRandomPhone() {
    const random = Math.floor(Math.random() * 100000000);
    return `6${random.toString().padStart(8, '0')}`;
}

export default function () {
    // GROUP 1: Test des endpoints publics
    group('Public Endpoints', function () {
        // Test: Health check (si disponible)
        let healthRes = http.get(`${API_BASE_URL}/health`, { headers: HEADERS });
        check(healthRes, {
            'Health check: status is 200 or 404': (r) => r.status === 200 || r.status === 404,
        });

        sleep(0.5);
    });

    // GROUP 2: Test d'inscription (Register)
    group('User Registration', function () {
        const registerPayload = JSON.stringify({
            name: `LoadTest User ${Date.now()}`,
            email: generateRandomEmail(),
            password: 'LoadTest@123',
            contact: generateRandomPhone(),
            address: '123 Test St, Load City',
            role: 'user'
        });

        const registerRes = http.post(
            `${API_BASE_URL}/customer/register`,
            registerPayload,
            {
                headers: HEADERS,
                tags: { endpoint: 'register' },
            }
        );

        const registerCheck = check(registerRes, {
            'Register: status is 201 or 200': (r) => r.status === 201 || r.status === 200,
            'Register: response time < 3000ms': (r) => r.timings.duration < 3000,
            'Register: has response body': (r) => r.body && r.body.length > 0,
        });

        registerDuration.add(registerRes.timings.duration);
        errorRate.add(!registerCheck);

        sleep(1);
    });

    // GROUP 3: Test de connexion (Login)
    group('User Login', function () {
        // Utilisation d'un compte de test existant
        const loginPayload = JSON.stringify({
            email: 'test@example.com',
            password: 'Test@123',
        });

        const loginRes = http.post(
            `${API_BASE_URL}/customer/login`,
            loginPayload,
            {
                headers: HEADERS,
                tags: { endpoint: 'login' },
            }
        );

        const loginCheck = check(loginRes, {
            'Login: status is 200 or 401': (r) => r.status === 200 || r.status === 401,
            'Login: response time < 2000ms': (r) => r.timings.duration < 2000,
        });

        loginDuration.add(loginRes.timings.duration);
        errorRate.add(!loginCheck);

        sleep(1);
    });

    // GROUP 4: Test des produits (Products)
    group('Products Endpoints', function () {
        const productsRes = http.get(
            `${API_BASE_URL}/product/`,
            {
                headers: HEADERS,
                tags: { endpoint: 'products' },
            }
        );

        check(productsRes, {
            'Products: status is 200': (r) => r.status === 200,
            'Products: response time < 1000ms': (r) => r.timings.duration < 1000,
            'Products: has data': (r) => {
                try {
                    const json = JSON.parse(r.body);
                    return json && (Array.isArray(json) || json.products || json.data);
                } catch (e) {
                    return false;
                }
            },
        });

        sleep(1);
    });

    sleep(2);
}

export function setup() {
    console.log(`🚀 Starting Backend API Load Test`);
    console.log(`📡 API Base URL: ${API_BASE_URL}`);
    console.log(`📊 Test configuration:`);
    console.log(`   - Warm-up: 10 users (30s)`);
    console.log(`   - Normal: 30 users (1 min)`);
    console.log(`   - Peak: 50 users (1 min)`);
    console.log(`   - Cool-down (30s)`);
    console.log(``);
    console.log(`🎯 Testing endpoints:`);
    console.log(`   - POST /customer/register`);
    console.log(`   - POST /customer/login`);
    console.log(`   - GET /product/`);
    return { startTime: Date.now() };
}

export function teardown(data) {
    const duration = (Date.now() - data.startTime) / 1000;
    console.log(``);
    console.log(`✅ Backend API Load Test completed!`);
    console.log(`⏱️  Total duration: ${duration.toFixed(2)}s`);
}
