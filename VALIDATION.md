# Validation

Assessment: Ready to share with stated sample limitations.

Executed October 13, 2026 using Python's standard-library SQLite engine. Both entry points completed successfully.

## Historical Finding

`python verify_original.py` reproduces 9 flagged copies out of 31 (29.0%). Eight have returned-loan history. Flagged IDs: 2, 3, 6, 9, 15, 19, 22, 25, 26.

The minimal evidence extract excludes patron contacts and links to patrons. It is not a full database restoration. Incomplete history and stale flags remain possible explanations; no physical-location claim is supported.

## Demonstration

`python run_project.py` builds the schema and executes all six reports successfully. Verified:

- Eight copy rows and eight distinct copy IDs in the status view.
- Five catalog titles, including one title with zero copies.
- Title-level copy counts sum to eight; four copies are available.
- One overdue open loan, nine days overdue at the fixed reporting date.
- A loan due on the reporting date does not count as overdue.
- No foreign-key violations or quality-report exceptions in the supplied sample.
- Invalid writes rejected: duplicate open loan, unknown copy, open loan on a repair copy, due date before checkout, return before checkout, and update moving an open loan to a repair copy.

All six reports execute without third-party packages or remote assets.

## Limits

Synthetic results demonstrate behavior and cannot support claims about real-library performance. Historical evidence and synthetic results are separate. Closed-loan overlap, fee calculation, lost-copy resolution, reservations, and production security are outside scope. SQLite is the verified dialect; MySQL execution is not claimed.
