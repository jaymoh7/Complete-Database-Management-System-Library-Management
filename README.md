Library Management System Database



Overview

This project provides a fully normalized relational database for a Library Management System, implemented using MySQL. It manages essential library functions including book inventory, member tracking, loan management, and fine calculation.

Features

Member Management: Store and manage member details, contact info, and membership status

Book Inventory: Track books by ISBN, availability, and publisher

Authors & Publishers: Maintain comprehensive records for authors and publishers

Loan System: Handle book checkouts, returns, and due dates

Fine Calculation: Automatically compute fines for overdue books

Pre-built Views: Easily retrieve available books and overdue loan information


Database Schema

The system includes the following core tables:

1. members – Stores library member details


2. publishers – Information about book publishers


3. authors – Author details


4. books – Central book inventory table


5. book_authors – Junction table for many-to-many book-author relationships


6. loans – Tracks book loans, due dates, and returns


7. fines – Records overdue fines for borrowed books



Installation

Prerequisites

MySQL Server (v8.0 or higher recommended)

A MySQL client (e.g., MySQL Workbench, phpMyAdmin, or command-line interface)


Setup Instructions

1. Clone the repository:

git clone https://github.com/yourusername/library-management-db.git
cd library-management-db


2. Import the SQL schema:

mysql -u [username] -p [database_name] < library_management.sql

Alternatively, you can run the script manually in your MySQL client:

CREATE DATABASE library_management;
USE library_management;
SOURCE library_management.sql;



Usage Examples

View available books

SELECT * FROM available_books;

Check overdue loans

SELECT * FROM overdue_loans;

Borrow a book (via stored procedure)

CALL borrow_book(1, 5, @result);
SELECT @result;

Return a book

UPDATE loans 
SET return_date = CURDATE() 
WHERE loan_id = 3;

ER Diagram

The ER diagram is available in ERD.md file

Contributing

Contributions are welcome! To contribute:

1. Fork the repository


2. Create a new branch


3. Make your changes


4. Submit a pull request



License

This project is licensed under the MIT License.
