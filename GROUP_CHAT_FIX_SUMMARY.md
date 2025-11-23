# Group Chat Fix Summary

## Problem Description

When creating group chats, the following issues occurred:

1. **Corrupted session name**: Sessions showed as "4|G����" instead of the actual group name
2. **No message input box**: The chat interface didn't load properly
3. **Participants couldn't see the group**: Only the creator could see the group chat
4. **No success popup**: Frontend showed an error after group creation

## Root Causes Identified

### 1. Missing Chat Entity with Topic Field
- **Problem**: Group chats were created as `Session` entities only
- **Issue**: The `Session` table doesn't have a `topic` field to store the group name
- **Result**: Frontend couldn't display the group name, showing corrupted text "4|G����"

### 2. Creator Not Added to Participants
- **Problem**: The creator consultant was not added to `group_chat_participant` table
- **Issue**: Only invited consultants were saved as participants
- **Result**: Creator couldn't see their own group chat in some queries

### 3. Chat Entities Not Retrieved for Team Sessions
- **Problem**: `retrieveTeamSessionsForAuthenticatedConsultant` only fetched Session entities
- **Issue**: Chat entities (which contain the topic) were not fetched and merged
- **Result**: Frontend received sessions without the `chat` field containing the topic

## Solutions Implemented

### Fix 1: Create BOTH Session and Chat Entities
**File**: `CreateChatFacade.java`
**Method**: `createSimplifiedGroupChat()`

**Changes**:
1. Create a `Session` entity (for backend logic and participant tracking)
2. Create a `Chat` entity (for frontend display - contains the `topic` field)
3. Link both entities to the same Matrix room ID
4. Save both entities to the database

**Code snippet**:
```java
// Create a session for the group (needed for backend logic)
Session session = new Session();
// ... configure session ...
session = sessionService.saveSession(session);

// Create a Chat entity (needed for frontend - has topic field!)
Chat chat = chatConverter.convertToEntity(chatDTO, consultant);
chat.setActive(true);
chat = chatService.saveChat(chat);

// Create chat-agency relation
createChatAgencyRelation(chat, chatDTO.getAgencyId());

// Update BOTH session and chat with Matrix room ID
session.setMatrixRoomId(matrixRoomId);
session.setGroupId(matrixRoomId);
sessionService.saveSession(session);

chat.setGroupId(matrixRoomId);
chatService.saveChat(chat);
```

### Fix 2: Add Creator to Participants Table
**File**: `CreateChatFacade.java`
**Method**: `createSimplifiedGroupChat()`

**Changes**:
1. After creating the Matrix room, add the creator consultant to `group_chat_participant`
2. This ensures the creator appears in participant queries

**Code snippet**:
```java
// IMPORTANT: Add the CREATOR to group_chat_participant table!
GroupChatParticipant creatorParticipant = new GroupChatParticipant();
creatorParticipant.setChatId(sessionId); // Link to session ID
creatorParticipant.setConsultantId(consultant.getId());
groupChatParticipantRepository.save(creatorParticipant);
log.info("Added creator consultant {} to group_chat_participant", consultant.getId());
```

### Fix 3: Fetch and Merge Chat Entities for Team Sessions
**File**: `ConsultantSessionListService.java`
**Method**: `retrieveTeamSessionsForAuthenticatedConsultant()`

**Changes**:
1. Fetch team sessions (Session entities)
2. Fetch team chats (Chat entities with topic field)
3. Merge both lists using `mergeConsultantSessionsAndChats()`

**Code snippet**:
```java
// Get team sessions (Session entities)
List<ConsultantSessionResponseDTO> teamSessions =
    sessionService.getTeamSessionsForConsultant(consultant);

// MATRIX MIGRATION: Also get chats for group chats (Chat entities with topic field)
List<ConsultantSessionResponseDTO> teamChats = chatService.getChatsForConsultant(consultant);

// Merge sessions and chats
List<ConsultantSessionResponseDTO> allTeamSessions = 
    mergeConsultantSessionsAndChats(consultant, teamSessions, teamChats);
```

## Expected Behavior After Fix

1. ✅ **Group name displays correctly**: The Chat entity's `topic` field provides the group name
2. ✅ **Message input box appears**: The chat interface loads properly with the Chat entity
3. ✅ **All participants see the group**: 
   - Creator is in `group_chat_participant` table
   - Invited consultants are in `group_chat_participant` table
   - Both Session and Chat entities exist for proper querying
4. ✅ **Success popup shows**: Frontend receives proper response with `groupId` and `createdAt`

## Testing Instructions

1. **Rebuild the UserService**:
   ```bash
   cd caritas-workspace/ORISO-UserService
   mvn clean package -DskipTests
   ```

2. **Restart the UserService container**:
   ```bash
   docker-compose restart userservice
   ```

3. **Create a new group chat**:
   - Log in as consultant1
   - Go to "Neue Gruppenberatung erstellen"
   - Enter a group name (e.g., "Test Group Fixed")
   - Select consultant2 and consultant3
   - Click "Erstellen"

4. **Verify the fix**:
   - ✅ Success popup should appear
   - ✅ Group should appear in the session list with the correct name
   - ✅ Group should have a message input box
   - ✅ Log in as consultant2 - they should see the group
   - ✅ Log in as consultant3 - they should see the group
   - ✅ All participants should be able to send messages

## Database Schema

The solution uses the following tables:

1. **`session`**: Stores session data (backend logic, participant tracking)
   - `id`: Session ID
   - `consultant_id`: Creator consultant
   - `matrix_room_id`: Matrix room ID
   - `rc_group_id`: Also set to Matrix room ID for compatibility
   - `is_team_session`: Set to `true` for group chats

2. **`chat`**: Stores chat data (frontend display)
   - `id`: Chat ID
   - `topic`: Group name (THIS IS KEY!)
   - `group_id`: Matrix room ID
   - `chat_owner_id`: Creator consultant
   - `is_active`: Set to `true`

3. **`group_chat_participant`**: Stores participant relationships
   - `chat_id`: Links to `session.id` (NOT `chat.id`)
   - `consultant_id`: Participant consultant ID

4. **`chat_agency`**: Links chat to agency
   - `chat_id`: Links to `chat.id`
   - `agency_id`: Agency ID

## API Response Structure

The frontend expects a `ConsultantSessionResponseDTO` with:

```json
{
  "session": {
    "id": 101598,
    "groupId": "!matrixRoomId:server",
    "matrixRoomId": "!matrixRoomId:server",
    "isTeamSession": true,
    ...
  },
  "chat": {
    "id": 123,
    "topic": "Test Group Fixed",  // <-- THIS IS DISPLAYED!
    "groupId": "!matrixRoomId:server",
    ...
  },
  "consultant": {
    "id": "uuid",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

The `chat.topic` field is what the frontend displays as the group name!

## Files Modified

1. `/home/caritas/Desktop/online-beratung/caritas-workspace/ORISO-UserService/src/main/java/de/caritas/cob/userservice/api/facade/CreateChatFacade.java`
   - Modified `createSimplifiedGroupChat()` method
   - Creates both Session and Chat entities
   - Adds creator to participants table

2. `/home/caritas/Desktop/online-beratung/caritas-workspace/ORISO-UserService/src/main/java/de/caritas/cob/userservice/api/service/sessionlist/ConsultantSessionListService.java`
   - Modified `retrieveTeamSessionsForAuthenticatedConsultant()` method
   - Fetches and merges both Session and Chat entities

## Notes

- The foreign key constraint on `group_chat_participant.chat_id` was previously removed (it was pointing to `chat.id` but we use `session.id`)
- The `chat_id` field in `group_chat_participant` actually stores the `session.id`, not the `chat.id` (confusing naming but works)
- Both Session and Chat entities point to the same Matrix room ID via their `matrix_room_id`/`rc_group_id` and `group_id` fields respectively

