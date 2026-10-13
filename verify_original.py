"""Recompute the original coursework finding from a minimal non-contact extract."""
import json
from pathlib import Path
import sqlite3

root=Path(__file__).resolve().parent
data=json.loads((root/'evidence/coursework-records.json').read_text())
db=sqlite3.connect(':memory:')
db.executescript('''
CREATE TABLE inventory(INV_CODE INTEGER PRIMARY KEY,BK_CODE TEXT,INV_INLIB TEXT,INV_RENTED TEXT);
CREATE TABLE rented(RNT_CODE TEXT PRIMARY KEY,INV_CODE INTEGER,RNT_CHECKOUTDATE TEXT,RNT_DUEDATE TEXT,RNT_RTRNDATE TEXT);
''')
db.executemany('INSERT INTO inventory VALUES (?,?,?,?)',data['inventory'])
db.executemany('INSERT INTO rented VALUES (?,?,?,?,?)',data['loans'])
rows=db.execute('''
WITH open_loans AS (
 SELECT INV_CODE,COUNT(*) AS n FROM rented WHERE RNT_RTRNDATE IS NULL GROUP BY INV_CODE
)
SELECT i.INV_CODE FROM inventory i LEFT JOIN open_loans o ON i.INV_CODE=o.INV_CODE
WHERE COALESCE(o.n,0)>1
 OR (COALESCE(o.n,0)>0 AND (i.INV_INLIB='Y' OR i.INV_RENTED='N'))
 OR (COALESCE(o.n,0)=0 AND (i.INV_INLIB='N' OR i.INV_RENTED='Y'))
ORDER BY i.INV_CODE
''').fetchall()
total=db.execute('SELECT COUNT(*) FROM inventory').fetchone()[0]
assert total==31 and len(rows)==9
returned=db.execute('''SELECT COUNT(*) FROM inventory i
WHERE i.INV_CODE IN (2,3,6,9,15,19,22,25,26)
AND EXISTS (SELECT 1 FROM rented r WHERE r.INV_CODE=i.INV_CODE AND r.RNT_RTRNDATE IS NOT NULL)''').fetchone()[0]
assert returned==8
print(f'PASS: {len(rows)} / {total} copies need review ({100*len(rows)/total:.1f}%); {returned} have returned-loan history.')
print('Flagged copy IDs:',[r[0] for r in rows])
