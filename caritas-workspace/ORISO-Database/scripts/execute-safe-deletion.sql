-- ============================================================================
-- SAFE DELETION EXECUTION SCRIPT
-- ============================================================================
-- This script will delete old consultants (created > 1 year ago)
-- Backups have been created before execution
-- ============================================================================

START TRANSACTION;

-- Step 1: Delete consultant_agency relationships for old consultants
DELETE ca FROM userservice.consultant_agency ca
INNER JOIN userservice.consultant c ON ca.consultant_id = c.consultant_id
WHERE c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Step 2: Delete old consultants
-- Note: No appointments, chats, sessions, mobile tokens, or languages found
-- for these consultants, so safe to delete directly
DELETE FROM userservice.consultant
WHERE create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Show what was deleted
SELECT 
    'Deleted consultants' as action,
    ROW_COUNT() as count;

-- Review before committing
-- If everything looks good, run: COMMIT;
-- If something went wrong, run: ROLLBACK;


