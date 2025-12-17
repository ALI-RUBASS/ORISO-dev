-- ============================================================================
-- HARD DELETE OF ALL AGENCIES AND CONSULTANTS (AND THEIR RELATIONS)
-- ============================================================================
-- WARNING:
--   This script removes ALL data from:
--     - userservice.consultant and related tables
--     - agencyservice.agency and related tables
--   It preserves sessions/chats by setting their foreign keys to NULL.
--
--   Make sure you have a fresh backup before running this.
-- ============================================================================

START TRANSACTION;

-- --------------------------------------------------------------------------
-- 1) CONSULTANT-RELATED DATA (userservice)
-- --------------------------------------------------------------------------

-- 1.1 Child tables that reference consultants
DELETE FROM userservice.consultant_mobile_token;
DELETE FROM userservice.language;

-- 1.2 Preserve sessions but remove consultant reference
UPDATE userservice.session
SET consultant_id = NULL
WHERE consultant_id IS NOT NULL;

-- Chats have a NOT NULL FK from userservice.chat_agency, so remove those
-- mappings first, then delete chats.
DELETE FROM userservice.chat_agency;

-- Remove all chats that belonged to consultants.
DELETE FROM userservice.chat;

-- 1.3 Consultant/agency mapping
DELETE FROM userservice.consultant_agency;

-- 1.4 Consultants themselves
DELETE FROM userservice.consultant;

-- --------------------------------------------------------------------------
-- 2) AGENCY-RELATED DATA (agencyservice + userservice)
-- --------------------------------------------------------------------------

-- 2.1 Child tables in agencyservice
DELETE FROM agencyservice.agency_postcode_range;
DELETE FROM agencyservice.agency_topic;

-- 2.2 Mapping tables in userservice that reference agencies
DELETE FROM userservice.user_agency;
DELETE FROM userservice.admin_agency;

-- 2.3 Preserve sessions but break the agency FK
UPDATE userservice.session
SET agency_id = NULL
WHERE agency_id IS NOT NULL;

-- 2.4 Agencies themselves
DELETE FROM agencyservice.agency;

COMMIT;


