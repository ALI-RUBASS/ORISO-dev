#!/usr/bin/env python3
"""
Comprehensive Group Chat Flow Test
Tests the entire group chat creation and retrieval flow with detailed debugging
"""

import requests
import json
import sys
from datetime import datetime

# Configuration
BASE_URL = "https://api.oriso.site"
SERVICE_URL = f"{BASE_URL}/service"
KEYCLOAK_URL = f"{BASE_URL}/auth/realms/online-beratung/protocol/openid-connect/token"
USERNAME = "orisoconsultant1"
PASSWORD = "@Consultant12345"

# Disable SSL warnings for self-signed certs
requests.packages.urllib3.disable_warnings()

class GroupChatTester:
    def __init__(self):
        self.session = requests.Session()
        self.session.verify = False  # Skip SSL verification
        self.access_token = None
        self.refresh_token = None
        self.user_id = None
        self.rc_token = None
        self.csrf_token = None
        self.created_session_id = None
        self.created_group_id = None
        
    def log(self, message, level="INFO"):
        """Print formatted log message"""
        timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]
        colors = {
            "INFO": "\033[94m",  # Blue
            "SUCCESS": "\033[92m",  # Green
            "ERROR": "\033[91m",  # Red
            "WARN": "\033[93m",  # Yellow
            "DEBUG": "\033[95m"  # Magenta
        }
        reset = "\033[0m"
        print(f"{colors.get(level, '')}{timestamp} [{level}] {message}{reset}")
    
    def print_response(self, response, title="Response"):
        """Print detailed response information"""
        self.log(f"\n{'='*80}", "DEBUG")
        self.log(f"{title}", "DEBUG")
        self.log(f"{'='*80}", "DEBUG")
        self.log(f"Status Code: {response.status_code}", "DEBUG")
        self.log(f"Headers: {dict(response.headers)}", "DEBUG")
        try:
            body = response.json()
            self.log(f"Body: {json.dumps(body, indent=2)}", "DEBUG")
        except:
            self.log(f"Body (text): {response.text[:500]}", "DEBUG")
        self.log(f"{'='*80}\n", "DEBUG")
    
    def step_1_login(self):
        """Step 1: Login via Keycloak and get access token"""
        self.log("STEP 1: Logging in via Keycloak...", "INFO")
        
        # Keycloak expects form-urlencoded data
        # Frontend encodes the password when calling the function, not in the form data
        data = {
            'username': USERNAME,
            'password': PASSWORD,
            'client_id': 'app',
            'grant_type': 'password'
        }
        
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
            'cache-control': 'no-cache'
        }
        
        try:
            response = self.session.post(KEYCLOAK_URL, data=data, headers=headers, verify=False)
            self.print_response(response, "Keycloak Login Response")
            
            if response.status_code == 200:
                data = response.json()
                self.access_token = data.get('access_token')
                self.refresh_token = data.get('refresh_token')
                
                # Set Authorization header for all future requests
                self.session.headers.update({
                    'Authorization': f'Bearer {self.access_token}'
                })
                
                self.log(f"✅ Keycloak login successful!", "SUCCESS")
                self.log(f"Access Token: {self.access_token[:50]}..." if self.access_token else "No access token", "DEBUG")
                return True
            else:
                self.log(f"❌ Keycloak login failed with status {response.status_code}", "ERROR")
                return False
                
        except Exception as e:
            self.log(f"❌ Keycloak login error: {str(e)}", "ERROR")
            import traceback
            self.log(traceback.format_exc(), "ERROR")
            return False
    
    def step_2_get_user_data(self):
        """Step 2: Get current user data and generate CSRF token"""
        self.log("STEP 2: Getting user data and generating CSRF token...", "INFO")
        
        # Generate CSRF token (frontend generates it, not the server!)
        import random
        import string
        possible = string.ascii_letters + string.digits
        self.csrf_token = ''.join(random.choice(possible) for _ in range(18))
        self.log(f"Generated CSRF Token: {self.csrf_token}", "DEBUG")
        
        # Set CSRF token in cookies (mimicking frontend behavior)
        self.session.cookies.set('CSRF-TOKEN', self.csrf_token)
        
        url = f"{SERVICE_URL}/users/data"
        
        try:
            response = self.session.get(url, verify=False)
            self.print_response(response, "User Data Response")
            
            if response.status_code == 200:
                data = response.json()
                self.user_id = data.get('userId')
                
                self.log(f"✅ User data retrieved! User ID: {self.user_id}", "SUCCESS")
                self.log(f"✅ CSRF token generated and stored!", "SUCCESS")
                return True
            else:
                self.log(f"❌ Failed to get user data: {response.status_code}", "ERROR")
                return False
                
        except Exception as e:
            self.log(f"❌ Error getting user data: {str(e)}", "ERROR")
            return False
    
    def step_3_create_group_chat(self):
        """Step 3: Create a new group chat"""
        self.log("STEP 3: Creating group chat...", "INFO")
        
        url = f"{SERVICE_URL}/users/chat/new"
        
        # Create group with orisoconsultant2 and orisoconsultant3
        # Use UUID for guaranteed uniqueness
        import uuid
        unique_id = str(uuid.uuid4())[:8]
        timestamp = datetime.now().strftime('%H:%M:%S.%f')
        payload = {
            "topic": f"Test Group {unique_id} {timestamp}",
            "consultantIds": ["orisoconsultant2", "orisoconsultant3"],
            "agencyId": 147,  # ORISO Agency ID from user data
            "repetitive": False,
            "startDate": None,
            "startTime": None,
            "duration": None
        }
        
        self.log(f"Payload: {json.dumps(payload, indent=2)}", "DEBUG")
        
        # Add CSRF token to headers if we have it
        headers = {}
        if self.csrf_token:
            headers['X-CSRF-TOKEN'] = self.csrf_token
            headers['X-XSRF-TOKEN'] = self.csrf_token
            self.log(f"Adding CSRF token to request headers", "DEBUG")
        else:
            self.log(f"⚠️  No CSRF token available - request may fail with 403", "WARN")
        
        try:
            response = self.session.post(url, json=payload, headers=headers, verify=False)
            self.print_response(response, "Create Group Chat Response")
            
            if response.status_code in [200, 201]:
                data = response.json()
                self.created_session_id = data.get('id') or data.get('sessionId')
                self.created_group_id = data.get('groupId')
                
                self.log(f"✅ Group chat created!", "SUCCESS")
                self.log(f"Session ID: {self.created_session_id}", "SUCCESS")
                self.log(f"Group ID: {self.created_group_id}", "SUCCESS")
                return True
            else:
                self.log(f"❌ Failed to create group chat: {response.status_code}", "ERROR")
                return False
                
        except Exception as e:
            self.log(f"❌ Error creating group chat: {str(e)}", "ERROR")
            return False
    
    def step_4_get_sessions_list(self):
        """Step 4: Get sessions list to verify group appears"""
        self.log("STEP 4: Getting sessions list...", "INFO")
        
        url = f"{SERVICE_URL}/users/sessions/consultants"
        params = {
            "status": 2,  # All sessions
            "count": 100,  # Get more sessions to find ours
            "filter": "all",
            "offset": 0
        }
        
        # Add CSRF token header (required for GET requests too!)
        headers = {}
        if self.csrf_token:
            headers['X-CSRF-TOKEN'] = self.csrf_token
        
        try:
            response = self.session.get(url, params=params, headers=headers, verify=False)
            self.print_response(response, "Sessions List Response")
            
            if response.status_code == 200:
                data = response.json()
                sessions = data.get('sessions', [])
                
                self.log(f"✅ Retrieved {len(sessions)} sessions", "SUCCESS")
                
                # Look for our created session
                found = False
                for session in sessions:
                    sess_data = session.get('session')
                    chat_data = session.get('chat')
                    
                    # Check if this is our group (by groupId or matrixRoomId)
                    if sess_data and (sess_data.get('groupId') == self.created_group_id or 
                                      sess_data.get('matrixRoomId') == self.created_group_id):
                        found = True
                        self.log(f"✅ FOUND OUR GROUP CHAT!", "SUCCESS")
                        self.log(f"Session: {json.dumps(sess_data, indent=2)}", "DEBUG")
                        self.log(f"Chat: {json.dumps(chat_data if chat_data else 'null', indent=2)}", "DEBUG")
                        
                        # Check if chat is null (the main issue!)
                        if not chat_data:
                            self.log(f"⚠️  WARNING: Chat data is NULL! This is the frontend display issue!", "WARN")
                        break
                
                if not found:
                    self.log(f"❌ Our group chat NOT found in sessions list!", "ERROR")
                    self.log(f"Created Session ID: {self.created_session_id}", "ERROR")
                    self.log(f"Created Group ID: {self.created_group_id}", "ERROR")
                    return False
                
                return True
            else:
                self.log(f"❌ Failed to get sessions list: {response.status_code}", "ERROR")
                return False
                
        except Exception as e:
            self.log(f"❌ Error getting sessions list: {str(e)}", "ERROR")
            return False
    
    def step_5_get_session_by_room_id(self):
        """Step 5: Get session by room ID (the endpoint that's failing with 403)"""
        self.log("STEP 5: Getting session by room ID...", "INFO")
        
        if not self.created_group_id:
            self.log("❌ No group ID to test with!", "ERROR")
            return False
        
        url = f"{SERVICE_URL}/users/sessions/room"
        params = {
            "rcGroupIds": self.created_group_id
        }
        
        # Add CSRF token header (required for GET requests too!)
        headers = {}
        if self.csrf_token:
            headers['X-CSRF-TOKEN'] = self.csrf_token
        
        self.log(f"URL: {url}", "DEBUG")
        self.log(f"Params: {params}", "DEBUG")
        
        try:
            response = self.session.get(url, params=params, headers=headers, verify=False)
            self.print_response(response, "Get Session by Room ID Response")
            
            if response.status_code == 200:
                data = response.json()
                self.log(f"✅ Session retrieved by room ID!", "SUCCESS")
                return True
            elif response.status_code == 403:
                self.log(f"❌ 403 FORBIDDEN - This is the issue!", "ERROR")
                self.log(f"This endpoint is rejecting the request", "ERROR")
                return False
            else:
                self.log(f"❌ Failed with status {response.status_code}", "ERROR")
                return False
                
        except Exception as e:
            self.log(f"❌ Error getting session by room ID: {str(e)}", "ERROR")
            return False
    
    def step_6_check_database(self):
        """Step 6: Check what's in the database"""
        self.log("STEP 6: Checking database...", "INFO")
        
        if not self.created_session_id:
            self.log("❌ No session ID to check!", "ERROR")
            return False
        
        self.log(f"Checking database for session ID: {self.created_session_id}", "INFO")
        
        # SQL queries to run
        queries = [
            f"SELECT * FROM session WHERE id = {self.created_session_id};",
            f"SELECT * FROM chat WHERE group_id = '{self.created_group_id}';",
            f"SELECT * FROM group_chat_participant WHERE chat_id = {self.created_session_id};"
        ]
        
        self.log("Run these SQL queries to check database:", "INFO")
        for query in queries:
            self.log(f"  {query}", "DEBUG")
        
        return True
    
    def run_full_test(self):
        """Run the complete test flow"""
        self.log("\n" + "="*80, "INFO")
        self.log("STARTING COMPREHENSIVE GROUP CHAT FLOW TEST", "INFO")
        self.log("="*80 + "\n", "INFO")
        
        steps = [
            ("Login", self.step_1_login),
            ("Get User Data", self.step_2_get_user_data),
            ("Create Group Chat", self.step_3_create_group_chat),
            ("Get Sessions List", self.step_4_get_sessions_list),
            ("Get Session by Room ID (403 issue)", self.step_5_get_session_by_room_id),
            ("Check Database", self.step_6_check_database)
        ]
        
        results = []
        for step_name, step_func in steps:
            try:
                result = step_func()
                results.append((step_name, result))
                
                if not result and step_name != "Check Database":
                    self.log(f"\n⚠️  Step '{step_name}' failed, but continuing...\n", "WARN")
                    
            except Exception as e:
                self.log(f"❌ Exception in step '{step_name}': {str(e)}", "ERROR")
                results.append((step_name, False))
        
        # Print summary
        self.log("\n" + "="*80, "INFO")
        self.log("TEST SUMMARY", "INFO")
        self.log("="*80, "INFO")
        
        for step_name, result in results:
            status = "✅ PASS" if result else "❌ FAIL"
            self.log(f"{status} - {step_name}", "SUCCESS" if result else "ERROR")
        
        self.log("="*80 + "\n", "INFO")
        
        # Return overall success
        return all(result for _, result in results[:-1])  # Exclude database check from overall result


if __name__ == "__main__":
    tester = GroupChatTester()
    success = tester.run_full_test()
    sys.exit(0 if success else 1)

