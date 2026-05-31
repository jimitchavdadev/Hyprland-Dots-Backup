#!/usr/bin/env python3
import sqlite3
import json
import glob
import os

# Find the active profile database
db_paths = glob.glob(os.path.expanduser('~/.thunderbird/*/global-messages-db.sqlite'))
if not db_paths:
    print("[]")
    exit(0)

# Sort by modification time to find the active one
db_path = max(db_paths, key=os.path.getmtime)

try:
    # Open a read-only connection
    conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    c = conn.cursor()
    # Query latest 8 messages
    c.execute("""
        SELECT m.date, mt.c3author, mt.c1subject 
        FROM messages m 
        JOIN messagesText_content mt ON m.id = mt.docid 
        WHERE m.deleted = 0
        ORDER BY m.date DESC 
        LIMIT 8;
    """)
    rows = c.fetchall()
    
    mails = []
    for r in rows:
        timestamp = r[0] // 1000000 # convert micro to seconds
        author = r[1].split('<')[0].strip(' "') # friendly author name
        subject = r[2]
        mails.append({
            "time": timestamp,
            "author": author if author else "Unknown",
            "subject": subject if subject else "No Subject"
        })
    print(json.dumps(mails))
except Exception as e:
    # Output empty list on error
    print("[]")
