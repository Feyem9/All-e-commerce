#!/usr/bin/env python3
"""
Debug script to understand exactly what the backend expects
and test different scenarios to fix the 400 error
"""

import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "https://e-commerce-app-1-islr.onrender.com"
REGISTER_ENDPOINT = f"{BASE_URL}/customer/register"

def test_different_scenarios():
    """Test different registration scenarios to identify the exact issue"""

    test_cases = [
        {
            "name": "Basic valid registration (fixed role)",
            "data": {
                "email": f"test_{datetime.now().strftime('%Y%m%d%H%M%S')}@example.com",
                "name": "Test User",
                "password": "testpassword123",
                "contact": "+1234567890",
                "address": "123 Test Street",
                "role": "user"  # Fixed role
            }
        },
        {
            "name": "Registration with admin role",
            "data": {
                "email": f"admin_{datetime.now().strftime('%Y%m%d%H%M%S')}@example.com",
                "name": "Admin User",
                "password": "adminpassword123",
                "contact": "+1234567890",
                "address": "456 Admin Street",
                "role": "admin"
            }
        },
        {
            "name": "Registration without role (should default to user)",
            "data": {
                "email": f"default_{datetime.now().strftime('%Y%m%d%H%M%S')}@example.com",
                "name": "Default User",
                "password": "defaultpassword123",
                "contact": "+1234567890",
                "address": "789 Default Street"
                # No role field - should default to 'user'
            }
        }
    ]

    for i, test_case in enumerate(test_cases, 1):
        print(f"\n🧪 Test Case {i}: {test_case['name']}")
        print(f"📋 Data: {json.dumps(test_case['data'], indent=2)}")

        try:
            response = requests.post(
                REGISTER_ENDPOINT,
                json=test_case['data'],
                headers={'Content-Type': 'application/json'},
                timeout=60  # Increased timeout
            )

            print(f"📡 Status: {response.status_code}")

            try:
                response_data = response.json()
                print(f"📝 Response: {json.dumps(response_data, indent=2)}")
            except ValueError:
                print(f"📄 Raw Response: {response.text[:200]}...")  # First 200 chars

        except requests.exceptions.Timeout:
            print("⏱️ Request timed out - backend may be slow or unavailable")
        except requests.exceptions.RequestException as e:
            print(f"🚨 Request failed: {str(e)}")

def test_backend_validation():
    """Test what happens with invalid data to understand backend validation"""
    print("\n🔍 Testing backend validation rules...")

    invalid_cases = [
        {
            "name": "Missing required fields",
            "data": {
                "email": "test@example.com",
                # Missing name, password, contact, address
                "role": "user"
            }
        },
        {
            "name": "Invalid email format",
            "data": {
                "email": "not-an-email",
                "name": "Test User",
                "password": "password123",
                "contact": "+1234567890",
                "address": "123 Street",
                "role": "user"
            }
        },
        {
            "name": "Short password",
            "data": {
                "email": "test@example.com",
                "name": "Test User",
                "password": "short",  # Less than 6 characters
                "contact": "+1234567890",
                "address": "123 Street",
                "role": "user"
            }
        }
    ]

    for case in invalid_cases:
        print(f"\n📌 Testing: {case['name']}")
        try:
            response = requests.post(
                REGISTER_ENDPOINT,
                json=case['data'],
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            print(f"📡 Status: {response.status_code}")
            print(f"📝 Response: {response.json()}")
        except Exception as e:
            print(f"🚨 Error: {str(e)}")

if __name__ == "__main__":
    print("🚀 Starting comprehensive registration debugging...")
    print(f"🎯 Endpoint: {REGISTER_ENDPOINT}")

    test_different_scenarios()
    test_backend_validation()

    print("\n🎯 Recommendations:")
    print("1. If you see timeout errors, the backend server may need to be restarted or optimized")
    print("2. If you see validation errors, check the specific error messages")
    print("3. Make sure to rebuild your Angular app: ng build --configuration production")
    print("4. Clear browser cache or use incognito mode to test")