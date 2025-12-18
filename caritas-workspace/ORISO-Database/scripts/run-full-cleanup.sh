#!/bin/bash
# ============================================================================
# FULL DATABASE CLEANUP - MariaDB + Matrix
# ============================================================================
# This script cleans both MariaDB and Matrix databases while preserving
# essential system/admin users.
#
# Users kept:
#   MariaDB: group-chat-system
#   Matrix: @caritas_admin, @oriso_call_admin, @group-chat-system
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}  ORISO DATABASE CLEANUP - KEEP SYSTEM/ADMIN USERS ONLY${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if running in correct directory
if [ ! -f "$SCRIPT_DIR/cleanup-mariadb-keep-system-user.sql" ]; then
    echo -e "${RED}✗ Error: cleanup-mariadb-keep-system-user.sql not found!${NC}"
    echo "  Please run this script from the ORISO-Database/scripts directory"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/cleanup-matrix-keep-admin-users.py" ]; then
    echo -e "${RED}✗ Error: cleanup-matrix-keep-admin-users.py not found!${NC}"
    echo "  Please run this script from the ORISO-Database/scripts directory"
    exit 1
fi

# Warning
echo -e "${RED}⚠️  WARNING: THIS WILL DELETE ALL DATA EXCEPT SYSTEM/ADMIN USERS!${NC}"
echo ""
echo "Users that will be KEPT:"
echo -e "  ${GREEN}✓ MariaDB: group-chat-system${NC}"
echo -e "  ${GREEN}✓ Matrix: @caritas_admin:91.99.219.182${NC}"
echo -e "  ${GREEN}✓ Matrix: @oriso_call_admin:91.99.219.182${NC}"
echo -e "  ${GREEN}✓ Matrix: @group-chat-system:91.99.219.182${NC}"
echo ""
echo "Everything else will be DELETED:"
echo -e "  ${RED}✗ All users (except system user)${NC}"
echo -e "  ${RED}✗ All consultants${NC}"
echo -e "  ${RED}✗ All agencies${NC}"
echo -e "  ${RED}✗ All sessions${NC}"
echo -e "  ${RED}✗ All chats${NC}"
echo -e "  ${RED}✗ All Matrix rooms (except those with kept users)${NC}"
echo ""

# Confirmation
read -p "Do you want to continue? (type 'YES' to confirm): " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo -e "${YELLOW}✗ Cleanup cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}  STEP 1: BACKUP DATABASES${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

# Create backup directory
BACKUP_DIR="$SCRIPT_DIR/../backups/cleanup-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backup directory: $BACKUP_DIR"
echo ""

# Backup MariaDB
echo -e "${YELLOW}Backing up MariaDB...${NC}"
kubectl exec -n caritas mariadb-0 -- mysqldump -u root -proot --all-databases > "$BACKUP_DIR/mariadb-backup.sql" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ MariaDB backup completed${NC}"
    echo "  Saved to: $BACKUP_DIR/mariadb-backup.sql"
else
    echo -e "${RED}✗ MariaDB backup failed!${NC}"
    exit 1
fi
echo ""

# Backup Matrix
echo -e "${YELLOW}Backing up Matrix...${NC}"
MATRIX_POD=$(kubectl get pods -n caritas -l app=matrix-synapse -o jsonpath='{.items[0].metadata.name}')
if [ -z "$MATRIX_POD" ]; then
    echo -e "${RED}✗ Matrix pod not found!${NC}"
    exit 1
fi

kubectl exec -n caritas $MATRIX_POD -- sqlite3 /data/homeserver.db ".backup /data/backup-temp.db" 2>/dev/null
kubectl cp caritas/$MATRIX_POD:/data/backup-temp.db "$BACKUP_DIR/matrix-backup.db" 2>/dev/null
kubectl exec -n caritas $MATRIX_POD -- rm -f /data/backup-temp.db 2>/dev/null

if [ -f "$BACKUP_DIR/matrix-backup.db" ]; then
    echo -e "${GREEN}✓ Matrix backup completed${NC}"
    echo "  Saved to: $BACKUP_DIR/matrix-backup.db"
else
    echo -e "${RED}✗ Matrix backup failed!${NC}"
    exit 1
fi
echo ""

echo -e "${GREEN}✓ All backups completed successfully!${NC}"
echo ""

# Final confirmation
read -p "Backups are ready. Proceed with cleanup? (type 'YES' to confirm): " CONFIRM2
if [ "$CONFIRM2" != "YES" ]; then
    echo -e "${YELLOW}✗ Cleanup cancelled. Backups are saved in: $BACKUP_DIR${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}  STEP 2: CLEAN MARIADB${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

echo -e "${YELLOW}Cleaning MariaDB...${NC}"
kubectl exec -i -n caritas mariadb-0 -- mysql -u root -proot < "$SCRIPT_DIR/cleanup-mariadb-keep-system-user.sql"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ MariaDB cleanup completed${NC}"
else
    echo -e "${RED}✗ MariaDB cleanup failed!${NC}"
    echo "  You can restore from: $BACKUP_DIR/mariadb-backup.sql"
    exit 1
fi
echo ""

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}  STEP 3: CLEAN MATRIX${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

echo -e "${YELLOW}Cleaning Matrix Synapse...${NC}"

# Copy Python script to Matrix pod
kubectl cp "$SCRIPT_DIR/cleanup-matrix-keep-admin-users.py" caritas/$MATRIX_POD:/tmp/cleanup-matrix.py

# Make executable
kubectl exec -n caritas $MATRIX_POD -- chmod +x /tmp/cleanup-matrix.py

# Run cleanup
kubectl exec -n caritas $MATRIX_POD -- python3 /tmp/cleanup-matrix.py

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Matrix cleanup completed${NC}"
    # Clean up temp file
    kubectl exec -n caritas $MATRIX_POD -- rm -f /tmp/cleanup-matrix.py
else
    echo -e "${RED}✗ Matrix cleanup failed!${NC}"
    echo "  You can restore from: $BACKUP_DIR/matrix-backup.db"
    exit 1
fi
echo ""

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}  STEP 4: VERIFICATION${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

echo -e "${YELLOW}Verifying MariaDB...${NC}"
kubectl exec -n caritas mariadb-0 -- mysql -u root -proot -e "
SELECT 'Users' AS table_name, COUNT(*) AS count FROM userservice.user
UNION ALL SELECT 'Consultants', COUNT(*) FROM userservice.consultant
UNION ALL SELECT 'Agencies', COUNT(*) FROM agencyservice.agency
UNION ALL SELECT 'Sessions', COUNT(*) FROM userservice.session;
"
echo ""

echo -e "${YELLOW}Verifying Matrix...${NC}"
kubectl exec -n caritas $MATRIX_POD -- python3 -c "
import sqlite3
con = sqlite3.connect('/data/homeserver.db')
cur = con.cursor()
cur.execute('SELECT name, admin FROM users ORDER BY name')
print('Remaining Matrix users:')
for row in cur.fetchall():
    print(f'  ✓ {row[0]} (admin={row[1]})')
"
echo ""

echo -e "${BLUE}============================================================================${NC}"
echo -e "${GREEN}  ✓ CLEANUP COMPLETED SUCCESSFULLY!${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""
echo "Summary:"
echo -e "  ${GREEN}✓ MariaDB cleaned (kept: group-chat-system)${NC}"
echo -e "  ${GREEN}✓ Matrix cleaned (kept: 3 admin/system users)${NC}"
echo -e "  ${GREEN}✓ Backups saved to: $BACKUP_DIR${NC}"
echo ""
echo "Next steps:"
echo "  1. Test user registration"
echo "  2. Test agency creation"
echo "  3. Test consultant creation"
echo "  4. Test group chat functionality"
echo ""
echo -e "${YELLOW}Note: If anything goes wrong, restore from backups in: $BACKUP_DIR${NC}"
echo ""

