-- Entirely synthetic demonstration data; not migrated or corrected coursework.
INSERT INTO genres VALUES (1,'Fiction'),(2,'Science'),(3,'History');
INSERT INTO authors VALUES (1,'Avery Example'),(2,'Jordan Sample'),(3,'Morgan Demo');
INSERT INTO books VALUES
 (1,'The Last Station',1,1800),(2,'Patterns in Nature',2,2400),
 (3,'A History of Rivers',3,2200),(4,'Beyond the Observatory',2,2600),
 (5,'Unstocked Catalog Title',1,1500);
INSERT INTO book_authors VALUES (1,1),(2,2),(3,3),(4,1),(4,2),(5,3);
INSERT INTO copies VALUES
 (101,1,'serviceable'),(102,1,'serviceable'),(103,1,'repair'),
 (104,2,'serviceable'),(105,2,'serviceable'),(106,3,'lost'),
 (107,3,'serviceable'),(108,4,'serviceable');
INSERT INTO patrons VALUES (1,'Demo Patron A'),(2,'Demo Patron B'),(3,'Demo Patron C');
INSERT INTO loans VALUES
 (1,101,1,'2026-09-01','2026-09-15','2026-09-14'),
 (2,101,2,'2026-10-01','2026-10-15',NULL),
 (3,104,1,'2026-09-20','2026-10-04',NULL),
 (4,105,3,'2026-09-01','2026-09-15','2026-09-18'),
 (5,108,3,'2026-09-10','2026-09-24','2026-09-24');
