# Reliable Library Inventory Reporting

## Business Question

The original college project supported catalog searches, inventory checks, due dates, and returns. This extension asks whether those records agree well enough to support an availability report.

## Evidence

The original sample contains 31 physical copies. Comparing each copy's status flags with recorded open loans flagged 9 copies, or 29.0% of the sample. All nine were marked rented without an open loan recorded. Eight had returned-loan history; one had no loan history.

The query defines an open loan as a recorded loan with a NULL actual return date. Loans are grouped by copy before joining to inventory so multiple loans cannot inflate the copy count. LEFT JOIN preserves copies with no loan history; ordered CASE rules label discrepancies before ordinary loan statuses. Counts reconcile to all 31 distinct copies.

## Interpretation

The available evidence cannot determine whether the flags are stale or the historical loan records are incomplete. It does not establish that any books are missing. The appropriate action is to review loan history and physical status before correcting records.

## Design Response

A separate SQLite demonstration replaces duplicated loan-status flags with status derived from loans, keeps copy condition separate, and normalizes authors and genres. A unique index prevents two open loans for one copy. Foreign keys and checks reject missing entities, invalid chronology, and negative replacement costs.

Synthetic records demonstrate zero-stock titles, repeated historical loans, open and overdue loans, returned loans, lost copies, and repairs. A fixed date makes the results reproducible. The revised dataset is a demonstration, not evidence that historical data quality improved.

## Validation

The reproducible checks cover the original 9/31 finding; preservation of one row per copy; title totals; zero-copy titles; due-today boundaries; foreign keys; duplicate open loans; loans on non-serviceable copies; and invalid loan chronology. See `VALIDATION.md` for the executed assessment.

## Scope

This iteration demonstrates SQL joins, CTEs, conditional aggregation, NULL handling, normalization, integrity constraints, and evidence-based recommendations. It does not attempt to model a complete production library system.
