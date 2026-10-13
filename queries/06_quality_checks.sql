-- Empty output is expected; foreign keys and duplicate-open-loan rules
-- are also enforced and tested by the runner.
SELECT 'Open loan on non-serviceable copy' AS issue,c.copy_id
FROM copies c JOIN loans l ON l.copy_id=c.copy_id
WHERE l.returned_date IS NULL AND c.condition<>'serviceable'
UNION ALL
SELECT 'Checkout after reporting date',copy_id FROM loans WHERE checkout_date>:as_of;
