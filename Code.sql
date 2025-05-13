-- Library Management System Database
-- Created by James Njoroge 
-- Date: 13/05/2025

-- Create database
-- CREATE DATABASE library_management;
-- USE library_management;

-- Members table: Stores information about library members
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    membership_date DATE NOT NULL,
    membership_status ENUM('active', 'expired', 'suspended') DEFAULT 'active',
    CONSTRAINT chk_email CHECK (email LIKE '%@%.%')
) COMMENT 'Stores library member information';

-- Publishers table: Stores book publisher information
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    CONSTRAINT unq_publisher_name UNIQUE (name)
) COMMENT 'Book publisher information';

-- Authors table: Stores author information
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    CONSTRAINT unq_author_name UNIQUE (first_name, last_name)
) COMMENT 'Book author information';

-- Books table: Stores book information
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    publisher_id INT,
    publication_year INT,
    edition INT,
    category VARCHAR(50),
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    description TEXT,
    stock_quantity INT NOT NULL DEFAULT 1,
    available_quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    CONSTRAINT chk_publication_year CHECK (publication_year BETWEEN 1000 AND YEAR(CURDATE())),
    CONSTRAINT chk_quantities CHECK (available_quantity <= stock_quantity AND stock_quantity >= 0 AND available_quantity >= 0)
) COMMENT 'Main book inventory information';

-- Book-Author relationship (Many-to-Many)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
) COMMENT 'Relationship between books and authors';

-- Loans table: Tracks book loans to members
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('on loan', 'returned', 'overdue') DEFAULT 'on loan',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    CONSTRAINT chk_dates CHECK (due_date > loan_date AND (return_date IS NULL OR return_date >= loan_date))
) COMMENT 'Tracks book loans and returns';

-- Fines table: Tracks fines for overdue books
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    issue_date DATE NOT NULL,
    payment_date DATE,
    status ENUM('pending', 'paid', 'waived') DEFAULT 'pending',
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    CONSTRAINT chk_amount CHECK (amount >= 0)
) COMMENT 'Tracks fines for overdue books';

-- Create indexes for performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_fines_status ON fines(status);

-- Create a view for currently available books
CREATE VIEW available_books AS
SELECT b.book_id, b.title, b.isbn, GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) AS authors, 
       p.name AS publisher, b.available_quantity
FROM books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
WHERE b.available_quantity > 0
GROUP BY b.book_id, b.title, b.isbn, p.name, b.available_quantity;

-- Create a view for current overdue loans
CREATE VIEW overdue_loans AS
SELECT l.loan_id, m.member_id, CONCAT(m.first_name, ' ', m.last_name) AS member_name,
       b.book_id, b.title, l.loan_date, l.due_date, DATEDIFF(CURDATE(), l.due_date) AS days_overdue
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.status = 'on loan' AND l.due_date < CURDATE();

-- Create stored procedure for borrowing a book
DELIMITER //
CREATE PROCEDURE borrow_book(
    IN p_member_id INT,
    IN p_book_id INT,
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE v_available INT;
    DECLARE v_member_status VARCHAR(20);
    DECLARE v_overdue_count INT;
    
    -- Check member status
    SELECT membership_status INTO v_member_status FROM members WHERE member_id = p_member_id;
    IF v_member_status != 'active' THEN
        SET p_result = 'Error: Membership is not active';
        LEAVE borrow_book;
    END IF;
    
    -- Check for overdue books
    SELECT COUNT(*) INTO v_overdue_count FROM overdue_loans WHERE member_id = p_member_id;
    IF v_overdue_count > 0 THEN
        SET p_result = 'Error: Member has overdue books';
        LEAVE borrow_book;
    END IF;
    
    -- Check book availability
    SELECT available_quantity INTO v_available FROM books WHERE book_id = p_book_id;
    IF v_available <= 0 THEN
        SET p_result = 'Error: Book is not available';
        LEAVE borrow_book;
    END IF;
    
    -- Create loan record
    INSERT INTO loans (book_id, member_id, loan_date, due_date)
    VALUES (p_book_id, p_member_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));
    
    -- Update book availability
    UPDATE books 
    SET available_quantity = available_quantity - 1 
    WHERE book_id = p_book_id;
    
    SET p_result = 'Book successfully borrowed';
END //
DELIMITER ;

-- Create trigger to update loan status when book is returned
DELIMITER //
CREATE TRIGGER after_book_return
BEFORE UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        SET NEW.status = 'returned';
        
        -- Update book availability
        UPDATE books 
        SET available_quantity = available_quantity + 1 
        WHERE book_id = NEW.book_id;
        
        -- Create fine if overdue
        IF NEW.due_date < NEW.return_date THEN
            INSERT INTO fines (loan_id, amount, issue_date)
            VALUES (NEW.loan_id, DATEDIFF(NEW.return_date, NEW.due_date) * 0.50, CURDATE());
        END IF;
    END IF;
END //
DELIMITER ;

-- Create trigger to update loan status to overdue
DELIMITER //
CREATE TRIGGER check_overdue_loans
BEFORE UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'on loan' AND NEW.due_date < CURDATE() THEN
        SET NEW.status = 'overdue';
    END IF;
END //
DELIMITER ;
