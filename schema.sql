PRAGMA foreign_keys = ON;
CREATE TABLE genres (genre_id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE);
CREATE TABLE authors (author_id INTEGER PRIMARY KEY, name TEXT NOT NULL);
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY, title TEXT NOT NULL,
    genre_id INTEGER NOT NULL REFERENCES genres,
    replacement_cost_cents INTEGER NOT NULL CHECK(replacement_cost_cents >= 0)
);
CREATE TABLE book_authors (
    book_id INTEGER REFERENCES books, author_id INTEGER REFERENCES authors,
    PRIMARY KEY(book_id, author_id)
);
CREATE TABLE copies (
    copy_id INTEGER PRIMARY KEY, book_id INTEGER NOT NULL REFERENCES books,
    condition TEXT NOT NULL CHECK(condition IN ('serviceable','repair','lost'))
);
CREATE TABLE patrons (patron_id INTEGER PRIMARY KEY, display_name TEXT NOT NULL);
CREATE TABLE loans (
    loan_id INTEGER PRIMARY KEY,
    copy_id INTEGER NOT NULL REFERENCES copies,
    patron_id INTEGER NOT NULL REFERENCES patrons,
    checkout_date TEXT NOT NULL CHECK(date(checkout_date) IS NOT NULL AND date(checkout_date)=checkout_date),
    due_date TEXT NOT NULL CHECK(date(due_date) IS NOT NULL AND date(due_date)=due_date AND due_date >= checkout_date),
    returned_date TEXT CHECK(returned_date IS NULL OR (date(returned_date) IS NOT NULL AND date(returned_date)=returned_date AND returned_date >= checkout_date))
);
-- One physical copy cannot have two simultaneous open loans.
CREATE UNIQUE INDEX one_open_loan_per_copy ON loans(copy_id) WHERE returned_date IS NULL;
CREATE INDEX loans_patron ON loans(patron_id);
CREATE TRIGGER loan_copy_serviceable BEFORE INSERT ON loans
WHEN NEW.returned_date IS NULL AND (SELECT condition FROM copies WHERE copy_id=NEW.copy_id) <> 'serviceable'
BEGIN SELECT RAISE(ABORT, 'An open loan requires a serviceable copy'); END;
CREATE TRIGGER updated_loan_copy_serviceable BEFORE UPDATE ON loans
WHEN NEW.returned_date IS NULL AND (SELECT condition FROM copies WHERE copy_id=NEW.copy_id) <> 'serviceable'
BEGIN SELECT RAISE(ABORT, 'An open loan requires a serviceable copy'); END;
CREATE VIEW copy_status AS
SELECT c.copy_id, c.book_id, c.condition,
    CASE WHEN l.loan_id IS NOT NULL AND c.condition <> 'serviceable' THEN 'Needs review'
         WHEN l.loan_id IS NOT NULL THEN 'On loan'
         WHEN c.condition='repair' THEN 'Under repair'
         WHEN c.condition='lost' THEN 'Lost'
         ELSE 'Available' END AS status
FROM copies c LEFT JOIN loans l ON l.copy_id=c.copy_id AND l.returned_date IS NULL;
