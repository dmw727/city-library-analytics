"""Build and verify the demonstration with Python's standard library only."""
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parent
AS_OF = '2026-10-13'

def build():
    db = sqlite3.connect(':memory:')
    db.executescript((ROOT/'schema.sql').read_text())
    db.executescript((ROOT/'sample_data.sql').read_text())
    return db

def verify(db):
    assert db.execute('PRAGMA foreign_key_check').fetchall() == []
    assert db.execute('SELECT COUNT(*),COUNT(DISTINCT copy_id) FROM copy_status').fetchone() == (8,8)
    availability = db.execute((ROOT/'queries/01_title_availability.sql').read_text()).fetchall()
    assert len(availability)==5 and sum(r[2] for r in availability)==8
    assert next(r for r in availability if r[0]==5)[2:]==(0,0,0,0)
    assert sum(r[3] for r in availability)==4
    overdue = db.execute((ROOT/'queries/02_overdue_loans.sql').read_text(),{'as_of':AS_OF}).fetchall()
    assert len(overdue)==1 and overdue[0][-1]==9
    assert db.execute((ROOT/'queries/06_quality_checks.sql').read_text(),{'as_of':AS_OF}).fetchall()==[]
    rejected = [
        "INSERT INTO loans VALUES (90,101,1,'2026-10-01','2026-10-15',NULL)",
        "INSERT INTO loans VALUES (91,999,1,'2026-10-01','2026-10-15',NULL)",
        "INSERT INTO loans VALUES (92,103,1,'2026-10-01','2026-10-15',NULL)",
        "INSERT INTO loans VALUES (93,102,1,'2026-10-01','2026-09-15',NULL)",
        "INSERT INTO loans VALUES (94,102,1,'2026-10-01','2026-10-15','2026-09-30')",
        "UPDATE loans SET copy_id=103 WHERE loan_id=2",
    ]
    for statement in rejected:
        db.execute('SAVEPOINT invalid_example')
        try:
            db.execute(statement)
        except sqlite3.IntegrityError:
            pass
        else:
            raise AssertionError('Invalid record accepted: '+statement)
        finally:
            db.execute('ROLLBACK TO invalid_example')
            db.execute('RELEASE invalid_example')
    db.execute('SAVEPOINT due_today')
    db.execute("INSERT INTO loans VALUES (95,102,1,'2026-10-01','2026-10-13',NULL)")
    assert len(db.execute((ROOT/'queries/02_overdue_loans.sql').read_text(),{'as_of':AS_OF}).fetchall())==1
    db.execute('ROLLBACK TO due_today')
    db.execute('RELEASE due_today')

def main():
    db=build()
    verify(db)
    target=ROOT/'results'
    target.mkdir(exist_ok=True)
    sections=['# Synthetic Demonstration Results','',f'Reporting date: {AS_OF}. All records below are synthetic. These are demonstrations, not findings about a real library.','']
    for path in sorted((ROOT/'queries').glob('*.sql')):
        cursor=db.execute(path.read_text(),{'as_of':AS_OF})
        rows=cursor.fetchall()
        columns=[c[0] for c in cursor.description]
        sections.extend(['## '+path.stem.replace('_',' '),'','| '+' | '.join(columns)+' |','| '+' | '.join(['---']*len(columns))+' |'])
        sections.extend('| '+' | '.join('NULL' if v is None else str(v).replace('|','\\|') for v in row)+' |' for row in rows)
        if not rows:
            sections.extend(['','No rows returned.'])
        sections.append('')
    (target/'demonstration-results.md').write_text('\n'.join(sections)+'\n',encoding='utf-8')
    with sqlite3.connect(ROOT/'library.db') as destination:
        db.backup(destination)
    print('PASS: query totals, row grain, foreign keys, zero-copy title, overdue boundary, and six invalid-write checks.')
    print('Created library.db and results/demonstration-results.md')

if __name__=='__main__':
    main()
