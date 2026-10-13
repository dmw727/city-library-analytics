-- Grain: one row per catalog title, including titles without copies.
SELECT b.book_id, b.title, COUNT(s.copy_id) AS total_copies,
       SUM(CASE WHEN s.status='Available' THEN 1 ELSE 0 END) AS available_copies,
       SUM(CASE WHEN s.status='On loan' THEN 1 ELSE 0 END) AS on_loan_copies,
       SUM(CASE WHEN s.status IN ('Lost','Under repair','Needs review') THEN 1 ELSE 0 END) AS unavailable_other
FROM books b LEFT JOIN copy_status s ON s.book_id=b.book_id
GROUP BY b.book_id,b.title ORDER BY available_copies DESC,b.title;
