-- ============================================================================
-- SAFE DELETION SCRIPT FOR OLD AGENCIES AND CONSULTANTS
-- ============================================================================
-- This script safely deletes old agencies and consultants while respecting
-- foreign key constraints.
--
-- IMPORTANT: Review the queries below and adjust the WHERE clauses to
-- identify which records are "old" before executing.
-- ============================================================================

-- STEP 1: BACKUP FIRST! (Run this separately before deletion)
-- mysqldump -u root -proot userservice > userservice_backup_$(date +%Y%m%d_%H%M%S).sql
-- mysqldump -u root -proot agencyservice > agencyservice_backup_$(date +%Y%m%d_%H%M%S).sql

-- ============================================================================
-- STEP 2: DRY RUN - Check what will be deleted
-- ============================================================================

-- Check old consultants (adjust date as needed)
SELECT 
    consultant_id,
    username,
    first_name,
    last_name,
    email,
    create_date,
    delete_date
FROM userservice.consultant
WHERE delete_date IS NOT NULL 
   OR create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)  -- Adjust date as needed
ORDER BY create_date;

-- Check old agencies (adjust date as needed)
SELECT 
    id,
    name,
    city,
    postcode,
    create_date,
    delete_date
FROM agencyservice.agency
WHERE delete_date IS NOT NULL 
   OR create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)  -- Adjust date as needed
ORDER BY create_date;

-- Count related records for consultants
SELECT 
    'consultant_agency' as table_name,
    COUNT(*) as count
FROM userservice.consultant_agency ca
INNER JOIN userservice.consultant c ON ca.consultant_id = c.consultant_id
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'appointment' as table_name,
    COUNT(*) as count
FROM userservice.appointment a
INNER JOIN userservice.consultant c ON a.consultant_id = c.consultant_id
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'chat' as table_name,
    COUNT(*) as count
FROM userservice.chat ch
INNER JOIN userservice.consultant c ON ch.consultant_id_owner = c.consultant_id
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'session' as table_name,
    COUNT(*) as count
FROM userservice.session s
INNER JOIN userservice.consultant c ON s.consultant_id = c.consultant_id
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'consultant_mobile_token' as table_name,
    COUNT(*) as count
FROM userservice.consultant_mobile_token cmt
INNER JOIN userservice.consultant c ON cmt.consultant_id = c.consultant_id
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'language' as table_name,
    COUNT(*) as count
FROM userservice.language l
INNER JOIN userservice.consultant c ON l.consultant_id = c.consultant_id
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Count related records for agencies
SELECT 
    'consultant_agency' as table_name,
    COUNT(*) as count
FROM userservice.consultant_agency ca
INNER JOIN agencyservice.agency a ON ca.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'user_agency' as table_name,
    COUNT(*) as count
FROM userservice.user_agency ua
INNER JOIN agencyservice.agency a ON ua.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'chat_agency' as table_name,
    COUNT(*) as count
FROM userservice.chat_agency cha
INNER JOIN agencyservice.agency a ON cha.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'admin_agency' as table_name,
    COUNT(*) as count
FROM userservice.admin_agency aa
INNER JOIN agencyservice.agency a ON aa.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'session' as table_name,
    COUNT(*) as count
FROM userservice.session s
INNER JOIN agencyservice.agency a ON s.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'agency_postcode_range' as table_name,
    COUNT(*) as count
FROM agencyservice.agency_postcode_range apr
INNER JOIN agencyservice.agency a ON apr.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR)
UNION ALL
SELECT 
    'agency_topic' as table_name,
    COUNT(*) as count
FROM agencyservice.agency_topic at
INNER JOIN agencyservice.agency a ON at.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- ============================================================================
-- STEP 3: ACTUAL DELETION (Execute in transaction for safety)
-- ============================================================================
-- WARNING: Review the WHERE clauses above before executing!
-- Uncomment the lines below only after reviewing the dry-run results.

/*
START TRANSACTION;

-- Delete order: Child tables first, then parent tables

-- 1. Delete consultant-related child records
DELETE cmt FROM userservice.consultant_mobile_token cmt
INNER JOIN userservice.consultant c ON cmt.consultant_id = c.consultant_id
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

DELETE l FROM userservice.language l
INNER JOIN userservice.consultant c ON l.consultant_id = c.consultant_id
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Note: appointment will auto-delete due to ON DELETE CASCADE
-- Note: chat and session have FK constraints, we'll set consultant_id to NULL instead

-- 2. Set consultant_id to NULL in session (to preserve session data)
UPDATE userservice.session s
INNER JOIN userservice.consultant c ON s.consultant_id = c.consultant_id
SET s.consultant_id = NULL
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 3. Handle chat - set consultant_id_owner to NULL or delete if appropriate
-- Option A: Set to NULL (preserves chat)
UPDATE userservice.chat ch
INNER JOIN userservice.consultant c ON ch.consultant_id_owner = c.consultant_id
SET ch.consultant_id_owner = NULL
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Option B: Delete chats (uncomment if preferred)
-- DELETE ch FROM userservice.chat ch
-- INNER JOIN userservice.consultant c ON ch.consultant_id_owner = c.consultant_id
-- WHERE c.delete_date IS NOT NULL 
--    OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 4. Delete consultant_agency relationships
DELETE ca FROM userservice.consultant_agency ca
INNER JOIN userservice.consultant c ON ca.consultant_id = c.consultant_id
WHERE c.delete_date IS NOT NULL 
   OR c.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 5. Delete consultants
DELETE FROM userservice.consultant
WHERE delete_date IS NOT NULL 
   OR create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 6. Delete agency-related child records
DELETE apr FROM agencyservice.agency_postcode_range apr
INNER JOIN agencyservice.agency a ON apr.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

DELETE at FROM agencyservice.agency_topic at
INNER JOIN agencyservice.agency a ON at.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 7. Delete agency relationships (no FK constraints, safe to delete)
DELETE ca FROM userservice.consultant_agency ca
INNER JOIN agencyservice.agency a ON ca.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

DELETE ua FROM userservice.user_agency ua
INNER JOIN agencyservice.agency a ON ua.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

DELETE cha FROM userservice.chat_agency cha
INNER JOIN agencyservice.agency a ON cha.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

DELETE aa FROM userservice.admin_agency aa
INNER JOIN agencyservice.agency a ON aa.agency_id = a.id
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 8. Set agency_id to NULL in session (to preserve session data)
UPDATE userservice.session s
INNER JOIN agencyservice.agency a ON s.agency_id = a.id
SET s.agency_id = NULL
WHERE a.delete_date IS NOT NULL 
   OR a.create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 9. Delete agencies
DELETE FROM agencyservice.agency
WHERE delete_date IS NOT NULL 
   OR create_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Review the changes before committing
-- SELECT 'Review the changes above, then commit or rollback';

-- COMMIT;
-- ROLLBACK;  -- Use this if something went wrong
*/


