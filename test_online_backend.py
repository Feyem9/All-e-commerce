#!/usr/bin/env python3
"""
Test script to verify the online backend CORS configuration
"""

import requests
import json

def test_online_backend():
    """Test the online backend CORS configuration"""
    base_url = "https://e-commerce-app-1-islr.onrender.com"

    print("🔍 Testing Online Backend Configuration...")
    print(f"🌐 Testing URL: {base_url}")

    # Test 1: Check if server is reachable
    print("\n1️⃣ Testing server reachability...")
    try:
        response = requests.get(f"{base_url}/check-session", timeout=10)
        print(f"✅ Server is reachable - Status: {response.status_code}")
        print(f"✅ Response: {response.text}")
    except Exception as e:
        print(f"❌ Server unreachable: {e}")
        return

    # Test 2: Test CORS headers on OPTIONS request
    print("\n2️⃣ Testing CORS OPTIONS request...")
    try:
        headers = {
            'Origin': 'http://localhost:4200',
            'Access-Control-Request-Method': 'POST',
            'Access-Control-Request-Headers': 'Content-Type,Authorization'
        }
        response = requests.options(f"{base_url}/customer/register", headers=headers, timeout=10)

        print(f"✅ OPTIONS Status Code: {response.status_code}")
        print(f"✅ Response Headers:")
        for header, value in response.headers.items():
            if 'access-control' in header.lower() or 'allow' in header.lower():
                print(f"   {header}: {value}")

        # Check required CORS headers
        required_headers = [
            'Access-Control-Allow-Origin',
            'Access-Control-Allow-Methods',
            'Access-Control-Allow-Headers',
            'Access-Control-Allow-Credentials'
        ]

        missing_headers = []
        for header in required_headers:
            if header not in response.headers:
                missing_headers.append(header)

        if missing_headers:
            print(f"❌ Missing CORS headers: {missing_headers}")
        else:
            print("✅ All required CORS headers present in OPTIONS response")

    except Exception as e:
        print(f"❌ Error testing OPTIONS request: {e}")

    # Test 3: Test actual POST request with CORS
    print("\n3️⃣ Testing POST request with CORS...")
    try:
        test_data = {
            "email": "test@example.com",
            "name": "Test User",
            "password": "testpassword123",
            "contact": "1234567890",
            "address": "Test Address",
            "role": "customer"
        }

        headers = {
            'Origin': 'http://localhost:4200',
            'Content-Type': 'application/json'
        }

        response = requests.post(
            f"{base_url}/customer/register",
            json=test_data,
            headers=headers,
            timeout=15
        )

        print(f"✅ POST Status Code: {response.status_code}")
        print(f"✅ Response Headers:")
        for header, value in response.headers.items():
            if 'access-control' in header.lower() or 'allow' in header.lower():
                print(f"   {header}: {value}")

        if response.status_code == 201:
            print("✅ Registration successful!")
            print(f"✅ Response: {response.json()}")
        elif response.status_code == 400:
            print(f"❌ Registration failed with validation errors: {response.json()}")
        else:
            print(f"❌ Registration failed with status {response.status_code}")
            print(f"❌ Response: {response.text}")

    except Exception as e:
        print(f"❌ Error testing POST request: {e}")

    # Test 4: Check if CORS is properly configured
    print("\n4️⃣ Checking CORS configuration...")
    try:
        # Test with different origin
        headers = {
            'Origin': 'http://localhost:4200',
            'Access-Control-Request-Method': 'POST'
        }
        response = requests.options(f"{base_url}/customer/register", headers=headers, timeout=10)

        origin_header = response.headers.get('Access-Control-Allow-Origin', '')
        if origin_header:
            print(f"✅ CORS Origin allowed: {origin_header}")
        else:
            print("❌ No CORS origin header found")

        methods_header = response.headers.get('Access-Control-Allow-Methods', '')
        if methods_header:
            print(f"✅ CORS Methods allowed: {methods_header}")
        else:
            print("❌ No CORS methods header found")

    except Exception as e:
        print(f"❌ Error checking CORS configuration: {e}")

if __name__ == "__main__":
    print("🚀 Starting Online Backend Test...")
    test_online_backend()
    print("\n🎯 Online backend test completed!")