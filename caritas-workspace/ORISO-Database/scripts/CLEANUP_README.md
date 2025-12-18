# Database Cleanup Scripts

## 📋 Overview

These scripts clean all data from MariaDB and Matrix databases while preserving essential system/admin users.

## 🔐 Users That Will Be Kept

### MariaDB (userservice)
- **group-chat-system** - System user required for group chat functionality

### Matrix Synapse
- **@caritas_admin:91.99.219.182** - Main admin user
- **@oriso_call_admin:91.99.219.182** - Call admin user  
- **@group-chat-system:91.99.219.182** - System user for group chats

## 📁 Files

1. **cleanup-mariadb-keep-system-user.sql** - Cleans MariaDB data
2. **cleanup-matrix-keep-admin-users.py** - Cleans Matrix Synapse data
3. **run-full-cleanup.sh** - Master script to run both cleanups

## ⚠️ IMPORTANT WARNINGS

1. **BACKUP FIRST!** Always create backups before running these scripts
2. **PRODUCTION DATA WILL BE DELETED!** All users, consultants, agencies, sessions, chats, and rooms will be removed
3. **IRREVERSIBLE!** Once deleted, data cannot be recovered without backups
4. **TEST FIRST!** Test on a non-production environment first

## 🚀 Usage

### Option 1: Run Full Cleanup (Both Databases)

```bash
cd /home/caritas/Desktop/online-beratung/caritas-workspace/ORISO-Database/scripts

# Make script executable
chmod +x run-full-cleanup.sh

# Run full cleanup
./run-full-cleanup.sh
```

### Option 2: Run Individual Cleanups

#### Clean MariaDB Only

```bash
# From your local machine or server
kubectl exec -n caritas mariadb-0 -- mysql -u root -proot < cleanup-mariadb-keep-system-user.sql

# Or copy to pod and run
kubectl cp cleanup-mariadb-keep-system-user.sql caritas/mariadb-0:/tmp/
kubectl exec -n caritas mariadb-0 -- mysql -u root -proot < /tmp/cleanup-mariadb-keep-system-user.sql
```

#### Clean Matrix Only

```bash
# Get Matrix pod name
MATRIX_POD=$(kubectl get pods -n caritas -l app=matrix-synapse -o jsonpath='{.items[0].metadata.name}')

# Copy script to pod
kubectl cp cleanup-matrix-keep-admin-users.py caritas/$MATRIX_POD:/tmp/

# Make executable
kubectl exec -n caritas $MATRIX_POD -- chmod +x /tmp/cleanup-matrix-keep-admin-users.py

# Run cleanup
kubectl exec -n caritas $MATRIX_POD -- python3 /tmp/cleanup-matrix-keep-admin-users.py
```

## 📊 What Gets Deleted

### MariaDB (userservice & agencyservice)
- ✗ All users (except group-chat-system)
- ✗ All consultants
- ✗ All agencies
- ✗ All sessions
- ✗ All chats
- ✗ All user/consultant/agency relationships
- ✗ All mobile tokens
- ✗ All language preferences

### Matrix Synapse
- ✗ All users (except the 3 admin/system users)
- ✗ All rooms without kept users
- ✗ All events in deleted rooms
- ✗ All devices and encryption keys for deleted users
- ✗ All access tokens for deleted users
- ✗ All profile data for deleted users
- ✗ All presence data for deleted users
- ✗ All push notifications for deleted users

## ✅ What Gets Kept

### MariaDB
- ✓ group-chat-system user and all its data
- ✓ Database structure (tables, schemas)
- ✓ Configuration data

### Matrix Synapse
- ✓ @caritas_admin:91.99.219.182 and all its data
- ✓ @oriso_call_admin:91.99.219.182 and all its data
- ✓ @group-chat-system:91.99.219.182 and all its data
- ✓ Rooms where kept users are members
- ✓ Events in kept rooms
- ✓ Database structure

## 🔍 Verification

After running the cleanup, verify the results:

### Check MariaDB

```bash
kubectl exec -n caritas mariadb-0 -- mysql -u root -proot -e "
SELECT 'Users' AS table_name, COUNT(*) AS count FROM userservice.user
UNION ALL SELECT 'Consultants', COUNT(*) FROM userservice.consultant
UNION ALL SELECT 'Agencies', COUNT(*) FROM agencyservice.agency
UNION ALL SELECT 'Sessions', COUNT(*) FROM userservice.session;
"

# Should show:
# Users: 1 (group-chat-system)
# Consultants: 0
# Agencies: 0
# Sessions: 0
```

### Check Matrix

```bash
MATRIX_POD=$(kubectl get pods -n caritas -l app=matrix-synapse -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n caritas $MATRIX_POD -- python3 -c "
import sqlite3
con = sqlite3.connect('/data/homeserver.db')
cur = con.cursor()
cur.execute('SELECT name, admin FROM users ORDER BY name')
for row in cur.fetchall():
    print(f'{row[0]} (admin={row[1]})')
"

# Should show only:
# @caritas_admin:91.99.219.182 (admin=1)
# @group-chat-system:91.99.219.182 (admin=1)
# @oriso_call_admin:91.99.219.182 (admin=1)
```

## 🔄 Post-Cleanup Steps

After cleanup, you can:

1. **Register new users** - Fresh user registrations will work
2. **Create new agencies** - No conflicts with old data
3. **Create new consultants** - Clean slate for consultant accounts
4. **Test the system** - Verify all functionality works

## 📞 Troubleshooting

### MariaDB Cleanup Fails

```bash
# Check MariaDB logs
kubectl logs -n caritas mariadb-0 --tail=100

# Verify MariaDB is running
kubectl get pods -n caritas | grep mariadb

# Check if you can connect
kubectl exec -n caritas mariadb-0 -- mysql -u root -proot -e "SELECT 1"
```

### Matrix Cleanup Fails

```bash
# Check Matrix logs
kubectl logs -n caritas $MATRIX_POD --tail=100

# Verify Python is available
kubectl exec -n caritas $MATRIX_POD -- python3 --version

# Check database file exists
kubectl exec -n caritas $MATRIX_POD -- ls -lh /data/homeserver.db
```

### Script Permission Denied

```bash
# Make scripts executable
chmod +x cleanup-matrix-keep-admin-users.py
chmod +x run-full-cleanup.sh
```

## 💾 Backup Before Cleanup

**ALWAYS backup before running cleanup!**

```bash
# Backup MariaDB
kubectl exec -n caritas mariadb-0 -- mysqldump -u root -proot --all-databases > mariadb-backup-$(date +%Y%m%d-%H%M%S).sql

# Backup Matrix
MATRIX_POD=$(kubectl get pods -n caritas -l app=matrix-synapse -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n caritas $MATRIX_POD -- sqlite3 /data/homeserver.db ".backup /data/backup.db"
kubectl cp caritas/$MATRIX_POD:/data/backup.db ./matrix-backup-$(date +%Y%m%d-%H%M%S).db
```

## 📝 Notes

- Scripts use transactions and will rollback on errors
- MariaDB script shows verification queries at the end
- Matrix script provides detailed progress output
- Both scripts are idempotent (safe to run multiple times)

## 🆘 Emergency Restore

If something goes wrong:

```bash
# Restore MariaDB
kubectl exec -i -n caritas mariadb-0 -- mysql -u root -proot < mariadb-backup-TIMESTAMP.sql

# Restore Matrix
kubectl cp matrix-backup-TIMESTAMP.db caritas/$MATRIX_POD:/data/homeserver.db
kubectl rollout restart deployment/matrix-synapse -n caritas
```

---

**Created:** December 18, 2025  
**Version:** 1.0.0  
**Status:** Production Ready

