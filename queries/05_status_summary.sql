SELECT status,COUNT(*) AS copies,
       ROUND(100.0*COUNT(*)/(SELECT NULLIF(COUNT(*),0) FROM copies),1) AS inventory_percentage
FROM copy_status GROUP BY status ORDER BY copies DESC,status;
