# Library Management System Database

A comprehensive, fully normalized relational database solution for modern library management needs. This MySQL-based system efficiently handles book inventory, member management, loan operations, and fine calculations through an optimized schema design.

## 📚 Features

- **Member Management**
  - Store detailed member information including contact details and membership status
  - Track membership history and activity

- **Book Inventory**
  - Catalog books by ISBN, title, publication year, and genre
  - Track book availability status in real-time
  - Manage multiple copies of the same title

- **Author & Publisher Records**
  - Maintain comprehensive information about authors and publishers
  - Support books with multiple authors through many-to-many relationships

- **Loan System**
  - Process book checkouts and returns
  - Track due dates and loan history
  - Implement lending policy enforcement

- **Fine Calculation**
  - Automatically compute fines for overdue books
  - Track payment status and history

- **Pre-built Views**
  - Quick access to available books
  - Easy identification of overdue loans
  - Member activity statistics

## 🗃️ Database Schema

The system consists of the following core tables:

| Table | Description |
|-------|-------------|
| `members` | Stores member details including name, contact information, and membership status |
| `publishers` | Contains information about book publishers |
| `authors` | Stores author biographical information |
| `books` | Central inventory table with book details including ISBN, title, and availability |
| `book_authors` | Junction table managing the many-to-many relationship between books and authors |
| `loans` | Tracks all book loans with checkout dates, due dates, and return status |
| `fines` | Records fines for overdue books and payment information |

## 🔧 Installation

### Prerequisites

- MySQL Server (v8.0 or higher recommended)
- MySQL client (MySQL Workbench, phpMyAdmin, or command-line interface)

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/library-management-db.git
   cd library-management-db
   ```

2. **Import the schema (command line):**
   ```bash
   mysql -u [username] -p [database_name] < library_management.sql
   ```

3. **Or import manually in MySQL client:**
   ```sql
   CREATE DATABASE library_management;
   USE library_management;
   SOURCE library_management.sql;
   ```

## 📋 Usage Examples

### View all available books
```sql
SELECT * FROM available_books;
```

### Check overdue loans
```sql
SELECT * FROM overdue_loans;
```

### Borrow a book (using stored procedure)
```sql
CALL borrow_book(member_id, book_id, @result);
SELECT @result;
```

### Return a book
```sql
UPDATE loans 
SET return_date = CURDATE() 
WHERE loan_id = 3;
```

### Calculate fine for an overdue book
```sql
CALL calculate_fine(loan_id, @fine_amount);
SELECT @fine_amount;
```

## 📊 ER Diagram

The Entity-Relationship diagram for this database can be found in the `ERD.md` file, providing a visual representation of the table relationships and schema design.

## 🔍 Database Views

| View Name | Description |
|-----------|-------------|
| `available_books` | Shows all books currently available for checkout |
| `overdue_loans` | Lists all loans that are past their due date |
| `member_activity` | Displays statistics on member borrowing activity |
| `popular_books` | Shows most frequently borrowed books |

## 💻 Development

### Adding Test Data

The repository includes a `sample_data.sql` script to populate the database with test data:

```sql
USE library_management;
SOURCE sample_data.sql;
```

### Running Tests

Execute the included test suite to verify database functionality:

```sql
SOURCE tests/run_tests.sql;
```

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows the established SQL style guidelines.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📮 Contact

Project Maintainer: [Your Name](mailto:your.email@example.com)

Project Repository: [GitHub](https://github.com/yourusername/library-management-db)

---

**Note**: This README represents a documentation standard. Actual implementation details may vary.
