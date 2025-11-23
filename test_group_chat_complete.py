#!/usr/bin/env python3
"""
Complete end-to-end test for group chat functionality.
Tests:
1. Group chat creation
2. Participants can see the group
3. Group chat displays correctly (name, subscribed status)
4. Chat interface loads properly
"""
import requests
import json
import time
import sys
import urllib3

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

BASE_URL = "https://api.oriso.site/service"
KEYCLOAK_URL = "https://keycloak.oriso.site"

# Test credentials
CONSULTANTS = {
    "consultant1": {
        "username": "orisoconsultant1",
        "password": "Consultant12345",
        "id": "3eb87875-d58d-4a33-b182-6ff7c7db0acc"
    },
    "consultant2": {
        "username": "orisoconsultant2",
        "password": "Consultant12345",
        "id": "d4e87875-d58d-4a33-b182-6ff7c7db0bdd"
    },
    "consultant3": {
        "username": "orisoconsultant3",
        "password": "Consultant12345",
        "id": "e5f87875-d58d-4a33-b182-6ff7c7db0cee"
    }
}


def print_header(text):
    """Print a formatted header."""
    print("\n" + "=" * 80)
    print(f"  {text}")
    print("=" * 80)


def print_step(step_num, text):
    """Print a step number and description."""
    print(f"\n[STEP {step_num}] {text}")


def print_success(text):
    """Print a success message."""
    print(f"✅ {text}")


def print_error(text):
    """Print an error message."""
    print(f"❌ {text}")


def print_info(text):
    """Print an info message."""
    print(f"ℹ️  {text}")


def get_keycloak_token(username, password):
    """Get Keycloak access token."""
    print_info(f"Getting token for {username}...")
    
    url = f"{KEYCLOAK_URL}/realms/caritas/protocol/openid-connect/token"
    data = {
        "grant_type": "password",
        "client_id": "caritas-frontend",
        "username": username,
        "password": password
    }
    
    try:
        response = requests.post(url, data=data, verify=False, timeout=10)
        response.raise_for_status()
        token = response.json()["access_token"]
        print_success(f"Got token for {username}")
        return token
    except Exception as e:
        print_error(f"Failed to get token: {e}")
        return None


def create_group_chat(token, topic, consultant_ids):
    """Create a group chat."""
    print_info(f"Creating group chat: '{topic}'")
    print_info(f"Participants: {consultant_ids}")
    
    url = f"{BASE_URL}/users/chat/v2/new"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    payload = {
        "topic": topic,
        "agencyId": 1,
        "consultantIds": consultant_ids
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload, verify=False, timeout=10)
        print_info(f"Response status: {response.status_code}")
        
        if response.status_code == 201:
            data = response.json()
            print_success("Group created successfully!")
            print_info(f"Group ID: {data.get('groupId')}")
            print_info(f"Created at: {data.get('createdAt')}")
            return data
        else:
            print_error(f"Failed to create group: {response.status_code}")
            print_error(f"Response: {response.text}")
            return None
    except Exception as e:
        print_error(f"Error creating group: {e}")
        return None


def get_sessions(token):
    """Get all sessions for the consultant."""
    url = f"{BASE_URL}/users/sessions/consultant"
    headers = {
        "Authorization": f"Bearer {token}"
    }
    
    try:
        response = requests.get(url, headers=headers, verify=False, timeout=10)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print_error(f"Failed to get sessions: {e}")
        return None


def get_session_by_id(token, session_id):
    """Get a specific session."""
    url = f"{BASE_URL}/users/sessions/room/{session_id}"
    headers = {
        "Authorization": f"Bearer {token}"
    }
    
    try:
        response = requests.get(url, headers=headers, verify=False, timeout=10)
        
        if response.status_code == 200:
            return response.json()
        else:
            print_error(f"Failed to get session: {response.status_code}")
            print_error(f"Response: {response.text}")
            return None
    except Exception as e:
        print_error(f"Error getting session: {e}")
        return None


def find_group_in_sessions(sessions, group_id):
    """Find a group chat in the sessions list."""
    if not sessions or "sessions" not in sessions:
        return None
    
    for session in sessions["sessions"]:
        session_data = session.get("session") or session.get("chat")
        if session_data and session_data.get("groupId") == group_id:
            return session
    
    return None


def verify_group_chat_data(session_data, expected_topic):
    """Verify that group chat data is correct."""
    errors = []
    
    # Check if chat data exists
    if "chat" not in session_data:
        errors.append("Missing 'chat' field in session data")
        return errors
    
    chat = session_data["chat"]
    
    # Check topic
    if chat.get("topic") != expected_topic:
        errors.append(f"Topic mismatch: expected '{expected_topic}', got '{chat.get('topic')}'")
    
    # Check subscribed field
    if not chat.get("subscribed"):
        errors.append(f"Subscribed field is False (should be True)")
    
    # Check groupId
    if not chat.get("groupId"):
        errors.append("Missing groupId in chat")
    
    return errors


def main():
    """Main test function."""
    print_header("GROUP CHAT END-TO-END TEST")
    
    # Step 1: Get tokens for all consultants
    print_step(1, "Getting authentication tokens")
    tokens = {}
    for key, consultant in CONSULTANTS.items():
        token = get_keycloak_token(consultant["username"], consultant["password"])
        if not token:
            print_error(f"Could not get token for {key}")
            sys.exit(1)
        tokens[key] = token
    
    # Step 2: Create group chat
    print_step(2, "Creating group chat")
    group_name = f"Test Group {int(time.time())}"
    group_data = create_group_chat(
        tokens["consultant1"],
        group_name,
        [CONSULTANTS["consultant2"]["id"], CONSULTANTS["consultant3"]["id"]]
    )
    
    if not group_data:
        print_error("Could not create group chat")
        sys.exit(1)
    
    group_id = group_data.get("groupId")
    print_success(f"Group created with ID: {group_id}")
    
    # Step 3: Wait for group to be fully created
    print_step(3, "Waiting for group to be fully created")
    time.sleep(3)
    
    # Step 4: Verify creator can see the group
    print_step(4, "Verifying creator (consultant1) can see the group")
    sessions1 = get_sessions(tokens["consultant1"])
    if not sessions1:
        print_error("Could not get sessions for consultant1")
        sys.exit(1)
    
    group_session1 = find_group_in_sessions(sessions1, group_id)
    if not group_session1:
        print_error("Consultant1 (creator) cannot see the group!")
        print_info(f"Total sessions: {len(sessions1.get('sessions', []))}")
        sys.exit(1)
    
    print_success("Consultant1 can see the group")
    
    # Verify group data for consultant1
    errors1 = verify_group_chat_data(group_session1, group_name)
    if errors1:
        print_error("Group data verification failed for consultant1:")
        for error in errors1:
            print_error(f"  - {error}")
        print_info("Full session data:")
        print(json.dumps(group_session1, indent=2))
    else:
        print_success("Group data is correct for consultant1")
        print_info(f"  - Topic: {group_session1['chat']['topic']}")
        print_info(f"  - Subscribed: {group_session1['chat']['subscribed']}")
        print_info(f"  - Group ID: {group_session1['chat']['groupId']}")
    
    # Step 5: Verify consultant2 can see the group
    print_step(5, "Verifying consultant2 can see the group")
    sessions2 = get_sessions(tokens["consultant2"])
    if not sessions2:
        print_error("Could not get sessions for consultant2")
        sys.exit(1)
    
    group_session2 = find_group_in_sessions(sessions2, group_id)
    if not group_session2:
        print_error("Consultant2 cannot see the group!")
        print_info(f"Total sessions: {len(sessions2.get('sessions', []))}")
    else:
        print_success("Consultant2 can see the group")
        errors2 = verify_group_chat_data(group_session2, group_name)
        if errors2:
            print_error("Group data verification failed for consultant2:")
            for error in errors2:
                print_error(f"  - {error}")
        else:
            print_success("Group data is correct for consultant2")
    
    # Step 6: Verify consultant3 can see the group
    print_step(6, "Verifying consultant3 can see the group")
    sessions3 = get_sessions(tokens["consultant3"])
    if not sessions3:
        print_error("Could not get sessions for consultant3")
        sys.exit(1)
    
    group_session3 = find_group_in_sessions(sessions3, group_id)
    if not group_session3:
        print_error("Consultant3 cannot see the group!")
        print_info(f"Total sessions: {len(sessions3.get('sessions', []))}")
    else:
        print_success("Consultant3 can see the group")
        errors3 = verify_group_chat_data(group_session3, group_name)
        if errors3:
            print_error("Group data verification failed for consultant3:")
            for error in errors3:
                print_error(f"  - {error}")
        else:
            print_success("Group data is correct for consultant3")
    
    # Step 7: Get session by ID
    print_step(7, "Testing session retrieval by ID")
    session_id = group_session1.get("session", {}).get("id") or group_session1.get("chat", {}).get("id")
    if session_id:
        print_info(f"Session ID: {session_id}")
        session_details = get_session_by_id(tokens["consultant1"], session_id)
        if session_details:
            print_success("Session retrieved successfully by ID")
            # Verify the session data
            if "sessions" in session_details and len(session_details["sessions"]) > 0:
                session_data = session_details["sessions"][0]
                errors = verify_group_chat_data(session_data, group_name)
                if errors:
                    print_error("Session data verification failed:")
                    for error in errors:
                        print_error(f"  - {error}")
                else:
                    print_success("Session data is correct when retrieved by ID")
        else:
            print_error("Could not retrieve session by ID")
    
    # Final summary
    print_header("TEST SUMMARY")
    
    all_passed = True
    
    if not group_session1:
        print_error("Creator cannot see group")
        all_passed = False
    elif errors1:
        print_error(f"Creator's group data has {len(errors1)} error(s)")
        all_passed = False
    else:
        print_success("Creator can see group with correct data")
    
    if not group_session2:
        print_error("Consultant2 cannot see group")
        all_passed = False
    elif errors2:
        print_error(f"Consultant2's group data has {len(errors2)} error(s)")
        all_passed = False
    else:
        print_success("Consultant2 can see group with correct data")
    
    if not group_session3:
        print_error("Consultant3 cannot see group")
        all_passed = False
    elif errors3:
        print_error(f"Consultant3's group data has {len(errors3)} error(s)")
        all_passed = False
    else:
        print_success("Consultant3 can see group with correct data")
    
    if all_passed:
        print_header("✅ ALL TESTS PASSED!")
        sys.exit(0)
    else:
        print_header("❌ SOME TESTS FAILED")
        sys.exit(1)


if __name__ == "__main__":
    main()

