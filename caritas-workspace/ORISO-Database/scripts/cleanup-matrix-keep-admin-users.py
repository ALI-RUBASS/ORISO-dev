#!/usr/bin/env python3
"""
============================================================================
CLEAN ALL MATRIX DATA EXCEPT ADMIN/SYSTEM USERS
============================================================================
WARNING:
  This script removes ALL data from Matrix Synapse database EXCEPT:
    - @caritas_admin:91.99.219.182 (main admin)
    - @oriso_call_admin:91.99.219.182 (call admin)
    - @group-chat-system:91.99.219.182 (system user for group chats)

  Make sure you have a fresh backup before running this.
============================================================================
Usage:
  # Copy to Matrix pod
  kubectl cp cleanup-matrix-keep-admin-users.py caritas/matrix-synapse-xxx:/tmp/

  # Execute in pod
  kubectl exec -n caritas matrix-synapse-xxx -- python3 /tmp/cleanup-matrix-keep-admin-users.py
============================================================================
"""

import sqlite3
import sys

# Users to keep (DO NOT DELETE)
KEEP_USERS = [
    '@caritas_admin:91.99.219.182',
    '@oriso_call_admin:91.99.219.182',
    '@group-chat-system:91.99.219.182'
]

def main():
    print("=" * 70)
    print("MATRIX DATABASE CLEANUP - KEEP ADMIN/SYSTEM USERS ONLY")
    print("=" * 70)
    print()
    print("Users to KEEP:")
    for user in KEEP_USERS:
        print(f"  ✓ {user}")
    print()
    
    # Connect to database
    try:
        con = sqlite3.connect('/data/homeserver.db')
        cur = con.cursor()
        print("✓ Connected to Matrix database")
    except Exception as e:
        print(f"✗ Failed to connect to database: {e}")
        sys.exit(1)
    
    # Start transaction
    cur.execute("BEGIN TRANSACTION")
    
    try:
        # Get list of all users
        cur.execute("SELECT name FROM users")
        all_users = [row[0] for row in cur.fetchall()]
        users_to_delete = [u for u in all_users if u not in KEEP_USERS]
        
        print(f"\nTotal users in database: {len(all_users)}")
        print(f"Users to keep: {len(KEEP_USERS)}")
        print(f"Users to delete: {len(users_to_delete)}")
        print()
        
        if not users_to_delete:
            print("✓ No users to delete. Database is already clean.")
            con.close()
            return
        
        print("Users that will be DELETED:")
        for user in users_to_delete[:10]:  # Show first 10
            print(f"  ✗ {user}")
        if len(users_to_delete) > 10:
            print(f"  ... and {len(users_to_delete) - 10} more")
        print()
        
        # Create placeholders for SQL IN clause
        placeholders = ','.join(['?' for _ in KEEP_USERS])
        
        # Tables to clean (in order to respect foreign key constraints)
        tables_to_clean = [
            # User-related tables
            ('user_ips', 'user_id'),
            ('user_directory_search', 'user_id'),
            ('user_directory', 'user_id'),
            ('user_daily_visits', 'user_id'),
            ('user_stats_current', 'user_id'),
            ('user_filters', 'user_id'),
            ('users_who_share_private_rooms', 'user_id'),
            ('users_in_public_rooms', 'user_id'),
            
            # Profile and presence
            ('profiles', 'full_user_id'),
            ('presence_stream', 'user_id'),
            
            # Devices and encryption
            ('devices', 'user_id'),
            ('device_lists_stream', 'user_id'),
            ('device_lists_changes_in_room', 'user_id'),
            ('device_inbox', 'user_id'),
            ('e2e_device_keys_json', 'user_id'),
            ('e2e_one_time_keys_json', 'user_id'),
            ('e2e_fallback_keys_json', 'user_id'),
            ('e2e_cross_signing_keys', 'user_id'),
            ('e2e_cross_signing_signatures', 'user_id'),
            ('e2e_room_keys_versions', 'user_id'),
            
            # Account data
            ('account_data', 'user_id'),
            ('room_account_data', 'user_id'),
            
            # Access tokens and sessions
            ('access_tokens', 'user_id'),
            ('refresh_tokens', 'user_id'),
            ('open_id_tokens', 'user_id'),
            
            # Receipts and read markers
            ('receipts_linearized', 'user_id'),
            ('receipts_graph', 'user_id'),
            
            # Push notifications
            ('event_push_actions', 'user_id'),
            ('event_push_summary', 'user_id'),
            
            # Room memberships and events
            ('local_current_membership', 'user_id'),
            ('sliding_sync_membership_snapshots', 'user_id'),
            ('sliding_sync_joined_rooms', 'user_id'),
        ]
        
        total_deleted = 0
        
        print("Cleaning tables...")
        for table, column in tables_to_clean:
            try:
                # Check if table exists
                cur.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name=?", (table,))
                if not cur.fetchone():
                    continue
                
                # Check if column exists
                cur.execute(f"PRAGMA table_info({table})")
                columns = [row[1] for row in cur.fetchall()]
                if column not in columns:
                    continue
                
                # Delete rows for users not in keep list
                cur.execute(f"SELECT COUNT(*) FROM {table} WHERE {column} NOT IN ({placeholders})", KEEP_USERS)
                count_before = cur.fetchone()[0]
                
                if count_before > 0:
                    cur.execute(f"DELETE FROM {table} WHERE {column} NOT IN ({placeholders})", KEEP_USERS)
                    deleted = cur.rowcount
                    total_deleted += deleted
                    print(f"  ✓ {table}: deleted {deleted} rows")
            except Exception as e:
                print(f"  ⚠ {table}: {e}")
        
        # Clean room-related data for rooms that no longer have any kept users
        print("\nCleaning room-related data...")
        
        # Get rooms that still have kept users
        cur.execute(f"""
            SELECT DISTINCT room_id 
            FROM room_memberships 
            WHERE user_id IN ({placeholders})
        """, KEEP_USERS)
        rooms_to_keep = [row[0] for row in cur.fetchall()]
        
        if rooms_to_keep:
            room_placeholders = ','.join(['?' for _ in rooms_to_keep])
            
            # Delete events from rooms without kept users
            cur.execute(f"SELECT COUNT(*) FROM events WHERE room_id NOT IN ({room_placeholders})", rooms_to_keep)
            events_count = cur.fetchone()[0]
            if events_count > 0:
                print(f"  Deleting {events_count} events from old rooms...")
                cur.execute(f"DELETE FROM events WHERE room_id NOT IN ({room_placeholders})", rooms_to_keep)
                
            # Delete state events
            cur.execute(f"SELECT COUNT(*) FROM state_events WHERE room_id NOT IN ({room_placeholders})", rooms_to_keep)
            state_count = cur.fetchone()[0]
            if state_count > 0:
                print(f"  Deleting {state_count} state events from old rooms...")
                cur.execute(f"DELETE FROM state_events WHERE room_id NOT IN ({room_placeholders})", rooms_to_keep)
            
            # Delete current state
            cur.execute(f"SELECT COUNT(*) FROM current_state_events WHERE room_id NOT IN ({room_placeholders})", rooms_to_keep)
            current_state_count = cur.fetchone()[0]
            if current_state_count > 0:
                print(f"  Deleting {current_state_count} current state events from old rooms...")
                cur.execute(f"DELETE FROM current_state_events WHERE room_id NOT IN ({room_placeholders})", rooms_to_keep)
            
            # Delete room memberships for non-kept users
            cur.execute(f"SELECT COUNT(*) FROM room_memberships WHERE user_id NOT IN ({placeholders})", KEEP_USERS)
            membership_count = cur.fetchone()[0]
            if membership_count > 0:
                print(f"  Deleting {membership_count} room memberships...")
                cur.execute(f"DELETE FROM room_memberships WHERE user_id NOT IN ({placeholders})", KEEP_USERS)
            
            # Delete rooms without kept users
            cur.execute(f"SELECT COUNT(*) FROM rooms WHERE room_id NOT IN ({room_placeholders})", rooms_to_keep)
            rooms_count = cur.fetchone()[0]
            if rooms_count > 0:
                print(f"  Deleting {rooms_count} rooms...")
                cur.execute(f"DELETE FROM rooms WHERE room_id NOT IN ({room_placeholders})", rooms_to_keep)
        
        # Delete users not in keep list
        print("\nDeleting users...")
        cur.execute(f"DELETE FROM users WHERE name NOT IN ({placeholders})", KEEP_USERS)
        deleted_users = cur.rowcount
        print(f"  ✓ Deleted {deleted_users} users")
        
        # Commit transaction
        con.commit()
        print()
        print("=" * 70)
        print("✓ CLEANUP COMPLETED SUCCESSFULLY")
        print("=" * 70)
        print(f"\nTotal rows deleted: {total_deleted + deleted_users}")
        print()
        
        # Verification
        print("Verification:")
        cur.execute("SELECT name, admin, deactivated FROM users ORDER BY name")
        remaining_users = cur.fetchall()
        print(f"  Remaining users: {len(remaining_users)}")
        for user in remaining_users:
            print(f"    ✓ {user[0]} (admin={user[1]}, deactivated={user[2]})")
        
        # Show room count
        cur.execute("SELECT COUNT(*) FROM rooms")
        room_count = cur.fetchone()[0]
        print(f"\n  Remaining rooms: {room_count}")
        
        # Show event count
        cur.execute("SELECT COUNT(*) FROM events")
        event_count = cur.fetchone()[0]
        print(f"  Remaining events: {event_count}")
        
        print()
        print("✓ Database is now clean and ready for fresh data!")
        
    except Exception as e:
        print()
        print("=" * 70)
        print("✗ ERROR OCCURRED - ROLLING BACK")
        print("=" * 70)
        print(f"Error: {e}")
        con.rollback()
        sys.exit(1)
    finally:
        con.close()

if __name__ == "__main__":
    main()

