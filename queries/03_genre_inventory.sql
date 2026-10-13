-- Pre-aggregate copies before joining to avoid author/loan fan-out.
SELECT g.name AS genre, COUNT(DISTINCT b.book_id) AS catalog_titles,
       COUNT(s.copy_id) AS copies,
       SUM(CASE WHEN s.status='Available' THEN 1 ELSE 0 END) AS available_copies
FROM genres g LEFT JOIN books b ON b.genre_id=g.genre_id
LEFT JOIN copy_status s ON s.book_id=b.book_id
GROUP BY g.genre_id,g.name ORDER BY copies DESC,g.name;
