-- Fixed reporting date supplied by the runner; due today is not overdue.
SELECT l.loan_id, c.copy_id, b.title, p.display_name, l.due_date,
       CAST(julianday(:as_of)-julianday(l.due_date) AS INTEGER) AS days_overdue
FROM loans l JOIN copies c ON c.copy_id=l.copy_id
JOIN books b ON b.book_id=c.book_id JOIN patrons p ON p.patron_id=l.patron_id
WHERE l.returned_date IS NULL AND l.checkout_date <= :as_of AND l.due_date < :as_of
ORDER BY days_overdue DESC,l.loan_id;
