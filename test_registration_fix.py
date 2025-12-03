#!/usr/bin/env python3
"""
Test script to verify the registration endpoint fixes
"""

import requests
import json
from datetime import datetime

# Test configuration
BASE_URL = "https://e-commerce-app-1-islr.onrender.com"
REGISTER_ENDPOINT = f"{BASE_URL}/customer/register"

# Test data that matches the fixed frontend form
test_data = {
    "email": f"testuser_{datetime.now().strftime('%Y%m%d%H%M%S')}@example.com",
    "name": "Test User",
    "password": "testpassword123",
    "contact": "+1234567890",
    "address": "123 Test Street",
    "role": "user"  # Fixed to match backend expectations
}

def test_registration():
    """Test the registration endpoint with the fixed data format"""
    print("🧪 Testing registration endpoint with fixed data...")

    try:
        # Test the registration endpoint
        response = requests.post(
            REGISTER_ENDPOINT,
            json=test_data,
            headers={
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            timeout=30
        )

        print(f"📡 Response Status: {response.status_code}")
        print(f"📝 Response Headers: {dict(response.headers)}")

        try:
            response_data = response.json()
            print(f"📋 Response Data: {json.dumps(response_data, indent=2)}")
        except ValueError:
            print(f"📄 Raw Response: {response.text}")

        # Check if registration was successful
        if response.status_code == 201:
            print("✅ Registration successful!")
            return True
        elif response.status_code == 400:
            print("❌ Registration failed with bad request")
            if 'error' in response_data:
                print(f"🔍 Error details: {response_data['error']}")
            return False
        else:
            print(f"⚠️ Unexpected status code: {response.status_code}")
            return False

    except requests.exceptions.RequestException as e:
        print(f"🚨 Request failed: {str(e)}")
        return False
    except Exception as e:
        print(f"💥 Unexpected error: {str(e)}")
        return False

def test_cors_headers():
    """Test CORS headers for the registration endpoint"""
    print("\n🔒 Testing CORS headers...")

    try:
        # Make an OPTIONS request to test CORS preflight
        response = requests.options(
            REGISTER_ENDPOINT,
            headers={
                'Origin': 'http://localhost:4200',
                'Access-Control-Request-Method': 'POST',
                'Access-Control-Request-Headers': 'content-type'
            },
            timeout=30
        )

        print(f"📡 CORS Preflight Status: {response.status_code}")
        print(f"📝 CORS Headers: {dict(response.headers)}")

        # Check for important CORS headers
        cors_headers = {
            'Access-Control-Allow-Origin': response.headers.get('Access-Control-Allow-Origin'),
            'Access-Control-Allow-Methods': response.headers.get('Access-Control-Allow-Methods'),
            'Access-Control-Allow-Headers': response.headers.get('Access-Control-Allow-Headers'),
            'Access-Control-Allow-Credentials': response.headers.get('Access-Control-Allow-Credentials')
        }

        print(f"🔐 CORS Configuration: {cors_headers}")

        return response.status_code == 200

    except requests.exceptions.RequestException as e:
        print(f"🚨 CORS test failed: {str(e)}")
        return False

if __name__ == "__main__":
    print("🚀 Starting registration endpoint test...")
    print(f"🎯 Testing endpoint: {REGISTER_ENDPOINT}")
    print(f"📋 Test data: {json.dumps(test_data, indent=2)}")

    # Run tests
    cors_ok = test_cors_headers()
    registration_ok = test_registration()

    print("\n📊 Test Results:")
    print(f"🔒 CORS Configuration: {'✅ PASS' if cors_ok else '❌ FAIL'}")
    print(f"📝 Registration Endpoint: {'✅ PASS' if registration_ok else '❌ FAIL'}")

    if cors_ok and registration_ok:
        print("🎉 All tests passed! Registration endpoint should work now.")
    else:
        print("⚠️ Some tests failed. Check the error messages above.")