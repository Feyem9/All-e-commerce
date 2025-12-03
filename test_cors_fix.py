#!/usr/bin/env python3
"""
Test script to verify CORS configuration is working properly
"""

import requests
import json

def test_cors_headers():
    """Test CORS headers for the register endpoint"""
    url = "https://e-commerce-app-1-islr.onrender.com/customer/register"

    # Test OPTIONS request (CORS preflight)
    print("🔍 Testing CORS preflight (OPTIONS) request...")
    try:
        response = requests.options(url, headers={
            'Origin': 'http://localhost:4200',
            'Access-Control-Request-Method': 'POST',
            'Access-Control-Request-Headers': 'Content-Type,Authorization'
        })

        print(f"✅ OPTIONS Status Code: {response.status_code}")
        print(f"✅ Response Headers:")
        for header, value in response.headers.items():
            if 'access-control' in header.lower():
                print(f"   {header}: {value}")

        # Check if required CORS headers are present
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
            print("✅ All required CORS headers present")

    except Exception as e:
        print(f"❌ Error testing OPTIONS request: {e}")

    # Test POST request with CORS headers
    print("\n🔍 Testing POST request with CORS headers...")
    try:
        test_data = {
            "email": "test@example.com",
            "name": "Test User",
            "password": "testpassword123",
            "contact": "1234567890",
            "address": "Test Address",
            "role": "customer"
        }

        response = requests.post(url, json=test_data, headers={
            'Origin': 'http://localhost:4200',
            'Content-Type': 'application/json'
        })

        print(f"✅ POST Status Code: {response.status_code}")
        print(f"✅ Response Headers:")
        for header, value in response.headers.items():
            if 'access-control' in header.lower():
                print(f"   {header}: {value}")

        if response.status_code == 201:
            print("✅ Registration successful!")
            print(f"✅ Response: {response.json()}")
        else:
            print(f"❌ Registration failed with status {response.status_code}")
            print(f"❌ Response: {response.text}")

    except Exception as e:
        print(f"❌ Error testing POST request: {e}")

if __name__ == "__main__":
    print("🚀 Starting CORS configuration test...")
    test_cors_headers()
    print("\n🎯 Test completed!")