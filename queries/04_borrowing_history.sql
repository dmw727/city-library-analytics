-- One row per loan; repeated copy IDs are intentional historical events.
SELECT p.display_name,b.title,l.copy_id,l.checkout_date,l.due_date,l.returned_date,
       CASE WHEN l.returned_date IS NULL THEN 'Open'
            WHEN l.returned_date>l.due_date THEN 'Returned late'
            ELSE 'Returned on time' END AS loan_outcome
FROM loans l JOIN patrons p ON p.patron_id=l.patron_id
JOIN copies c ON c.copy_id=l.copy_id JOIN books b ON b.book_id=c.book_id
ORDER BY p.display_name,l.checkout_date,l.loan_id;
