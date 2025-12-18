-- ============================================================================
-- CLEAN ALL MARIADB DATA EXCEPT SYSTEM USER (group-chat-system)
-- ============================================================================
-- WARNING:
--   This script removes ALL data from MariaDB databases EXCEPT:
--     - group-chat-system user (required for group chat functionality)
--
--   Make sure you have a fresh backup before running this.
-- ============================================================================
-- Usage:
--   kubectl exec -n caritas mariadb-0 -- mysql -u root -proot < cleanup-mariadb-keep-system-user.sql
-- ============================================================================

START TRANSACTION;

-- --------------------------------------------------------------------------
-- 1) USER-RELATED DATA (userservice)
-- --------------------------------------------------------------------------

-- 1.1 Child tables that reference users (delete all except system user's data)
DELETE FROM userservice.user_mobile_token 
WHERE user_id IN (
    SELECT user_id FROM userservice.user 
    WHERE user_id != 'group-chat-system'
);

DELETE FROM userservice.user_agency 
WHERE user_id IN (
    SELECT user_id FROM userservice.user 
    WHERE user_id != 'group-chat-system'
);

DELETE FROM userservice.user_chat 
WHERE user_id IN (
    SELECT user_id FROM userservice.user 
    WHERE user_id != 'group-chat-system'
);

-- 1.2 Sessions - remove user reference for non-system users
UPDATE userservice.session
SET user_id = NULL
WHERE user_id IS NOT NULL 
  AND user_id != 'group-chat-system';

-- 1.3 Delete all users EXCEPT group-chat-system
DELETE FROM userservice.user 
WHERE user_id != 'group-chat-system';

-- --------------------------------------------------------------------------
-- 2) CONSULTANT-RELATED DATA (userservice)
-- --------------------------------------------------------------------------

-- 2.1 Child tables that reference consultants
DELETE FROM userservice.consultant_mobile_token;
DELETE FROM userservice.language;

-- 2.2 Preserve sessions but remove consultant reference
UPDATE userservice.session
SET consultant_id = NULL
WHERE consultant_id IS NOT NULL;

-- 2.3 Chats - remove chat_agency mappings first
DELETE FROM userservice.chat_agency;

-- 2.4 Remove all chats
DELETE FROM userservice.chat;

-- 2.5 Consultant/agency mapping
DELETE FROM userservice.consultant_agency;

-- 2.6 Delete all consultants
DELETE FROM userservice.consultant;

-- --------------------------------------------------------------------------
-- 3) AGENCY-RELATED DATA (agencyservice + userservice)
-- --------------------------------------------------------------------------

-- 3.1 Child tables in agencyservice
DELETE FROM agencyservice.agency_postcode_range;
DELETE FROM agencyservice.agency_topic;

-- 3.2 Mapping tables in userservice that reference agencies
DELETE FROM userservice.admin_agency;

-- 3.3 Preserve sessions but break the agency FK
UPDATE userservice.session
SET agency_id = NULL
WHERE agency_id IS NOT NULL;

-- 3.4 Delete all agencies
DELETE FROM agencyservice.agency;

-- --------------------------------------------------------------------------
-- 4) SESSION DATA (clean all sessions)
-- --------------------------------------------------------------------------

-- 4.1 Delete all sessions (they're now orphaned)
DELETE FROM userservice.session;

-- --------------------------------------------------------------------------
-- 5) VERIFICATION
-- --------------------------------------------------------------------------

-- Show what's left
SELECT 'Users remaining:' AS info, COUNT(*) AS count FROM userservice.user;
SELECT 'Consultants remaining:' AS info, COUNT(*) AS count FROM userservice.consultant;
SELECT 'Agencies remaining:' AS info, COUNT(*) AS count FROM agencyservice.agency;
SELECT 'Sessions remaining:' AS info, COUNT(*) AS count FROM userservice.session;

-- Show the system user
SELECT 'System user details:' AS info;
SELECT user_id, username, email, matrix_user_id, create_date 
FROM userservice.user 
WHERE user_id = 'group-chat-system';

COMMIT;

-- ============================================================================
-- END OF CLEANUP SCRIPT
-- ============================================================================

