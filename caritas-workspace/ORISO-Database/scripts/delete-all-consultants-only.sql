-- ============================================================================
-- HARD DELETE OF ALL CONSULTANTS (AND THEIR RELATIONS), AGENCIES UNTOUCHED
-- ============================================================================
-- WARNING:
--   This script removes ALL data from:
--     - userservice.consultant and related tables
--   It preserves agencies but cleans consultant-related data
--   and breaks FKs by nulling consultant_id in sessions, then
--   deletes chats and mappings that depend on consultants.
--
--   Use only on non-production or after taking a full backup.
-- ============================================================================

START TRANSACTION;

-- 1) CONSULTANT-RELATED DATA (userservice)

-- 1.1 Child tables that reference consultants
DELETE FROM userservice.consultant_mobile_token;
DELETE FROM userservice.language;

-- 1.2 Preserve sessions but remove consultant reference
UPDATE userservice.session
SET consultant_id = NULL
WHERE consultant_id IS NOT NULL;

-- 1.3 Chats & mappings that depend on consultants (and agencies via chats)
DELETE FROM userservice.chat_agency;
DELETE FROM userservice.chat;

-- 1.4 Consultant/agency mapping
DELETE FROM userservice.consultant_agency;

-- 1.5 Consultants themselves
DELETE FROM userservice.consultant;

COMMIT;


