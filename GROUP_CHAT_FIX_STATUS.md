# Group Chat Fix - Current Status

## Problem Identified

From reading your chat logs (`1.md` and `2.md`), I understand the core issue:

### The "subscribed" Field Problem
When you click on a group chat, the frontend shows `JoinGroupChatView` instead of the actual chat interface because:

1. **Frontend Error**: `TypeError: n.useContext(...) is null` at `JoinGroupChatView.tsx:58`
2. **Root Cause**: The `subscribed` field in the chat data is `false` instead of `true`
3. **Why**: The backend tries to get the consultant's Matrix rooms to set `subscribed`, but it fails and returns an empty list

## What I Fixed

### 1. Added Matrix Room Fetching
**File**: `MatrixSynapseService.java`
- Added `getJoinedRooms()` method that calls Matrix API `/_matrix/client/r0/joined_rooms`
- This fetches the list of Matrix rooms a user has joined

### 2. Updated RocketChatRoomInformationProvider
**File**: `RocketChatRoomInformationProvider.java`
- When RocketChat fails (expected during Matrix migration), it now falls back to fetching Matrix rooms
- Calls `matrixSynapseService.getJoinedRooms(username, password)` to get the consultant's joined rooms
- This list is used to set the `subscribed` field correctly

### 3. How It Works
```
1. Frontend requests session list
2. Backend calls RocketChatRoomInformationProvider.retrieveRocketChatInformation()
3. RocketChat fails (not available)
4. Falls back to Matrix: getMatrixRoomsForUser()
5. Fetches consultant from database by ID
6. Calls matrixSynapseService.getJoinedRooms(username, password)
7. Returns list of Matrix room IDs the consultant has joined
8. ConsultantChatEnricher uses this list to set chat.subscribed = true
9. Frontend receives chat with subscribed=true
10. Shows actual chat interface instead of JoinGroupChatView
```

## Current Status

✅ **Code Changes Complete**:
- MatrixSynapseService.java - Added getJoinedRooms() method
- RocketChatRoomInformationProvider.java - Added Matrix fallback logic
- Code compiled successfully
- UserService pod restarted with new code

❓ **Testing Needed**:
- Create a new group chat
- Check if all participants can see it
- Check if clicking on the group chat loads the chat interface (not JoinGroupChatView)
- Verify the `subscribed` field is `true` in the API response

## Testing Instructions

### Manual Testing (via Browser)
1. Log in as consultant1
2. Create a new group chat (e.g., "Test Matrix Rooms")
3. Add consultant2 and consultant3
4. **Expected**: Success popup appears
5. Click on the group chat in the session list
6. **Expected**: Chat interface loads (with message input box)
7. Log in as consultant2
8. **Expected**: Group chat appears in their session list
9. Click on it
10. **Expected**: Chat interface loads properly

### Check Backend Logs
```bash
kubectl logs -n caritas -l app=userservice --tail=100 | grep -E "Fetching Matrix rooms|Found.*Matrix rooms|subscribed"
```

### Check API Response
When you click on a group chat, check the browser console for the API response:
- Look for the `/users/sessions/consultant` response
- Find your group chat in the `sessions` array
- Check the `chat.subscribed` field - it should be `true`

## What This Fixes

✅ **subscribed field**: Will be `true` for group chats where the consultant is a member
✅ **Chat interface loading**: Frontend will show the actual chat instead of JoinGroupChatView
✅ **Message input box**: Will appear because the chat interface loads properly

## What's NOT Changed

✅ **1-on-1 chats**: Still work exactly the same way (no changes to their flow)
✅ **Group chat creation**: Still creates both Session and Chat entities (from your previous fix in `1.md`)
✅ **Participants table**: Still saves all participants to `group_chat_participant` table

## Next Steps

1. **Test the fix**: Create a new group chat and verify it works
2. **Check logs**: Look for "Fetching Matrix rooms" and "Found X Matrix rooms" in userservice logs
3. **Verify subscribed field**: Check the API response to confirm `subscribed: true`
4. **Report results**: Let me know if the chat interface loads properly or if there are still issues

## Files Modified

1. `/home/caritas/Desktop/online-beratung/caritas-workspace/ORISO-UserService/src/main/java/de/caritas/cob/userservice/api/adapters/matrix/MatrixSynapseService.java`
   - Added `getJoinedRooms()` method (lines 1000-1047)

2. `/home/caritas/Desktop/online-beratung/caritas-workspace/ORISO-UserService/src/main/java/de/caritas/cob/userservice/api/facade/sessionlist/RocketChatRoomInformationProvider.java`
   - Added Matrix fallback logic in `retrieveRocketChatInformation()` (lines 37-67)
   - Added `getMatrixRoomsForUser()` method (lines 69-95)
   - Added `extractMatrixUsername()` helper method (lines 97-104)

## Python Test Script

Created: `/home/caritas/Desktop/online-beratung/test_group_chat_complete.py`

This script tests the complete flow but requires network access to Keycloak (won't work from outside the cluster).

## Summary

The fix addresses the root cause of why group chats weren't loading properly:
- **Before**: `subscribed` was always `false` because RocketChat room list was empty
- **After**: `subscribed` is `true` because we fetch the actual Matrix rooms the consultant has joined

This should make group chats work just like 1-on-1 chats!

