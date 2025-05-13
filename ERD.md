erDiagram
    members ||--o{ loans : "1-to-many"
    members {
        int member_id PK
        varchar(50) first_name
        varchar(50) last_name
        varchar(100) email
        varchar(20) phone
        text address
        date membership_date
        enum membership_status
    }
    
    publishers ||--o{ books : "1-to-many"
    publishers {
        int publisher_id PK
        varchar(100) name
        text address
        varchar(20) phone
        varchar(100) email
        varchar(100) website
    }
    
    books ||--o{ loans : "1-to-many"
    books {
        int book_id PK
        varchar(255) title
        varchar(20) isbn
        int publisher_id FK
        int publication_year
        int edition
        varchar(50) category
        varchar(30) language
        int page_count
        text description
        int stock_quantity
        int available_quantity
    }
    
    authors ||--o{ book_authors : "1-to-many"
    authors {
        int author_id PK
        varchar(50) first_name
        varchar(50) last_name
        date birth_date
        varchar(50) nationality
        text biography
    }
    
    book_authors }|--|| books : "many-to-1"
    book_authors {
        int book_id PK,FK
        int author_id PK,FK
    }
    
    loans ||--o{ fines : "1-to-many"
    loans {
        int loan_id PK
        int book_id FK
        int member_id FK
        date loan_date
        date due_date
        date return_date
        enum status
    }
    
    fines {
        int fine_id PK
        int loan_id FK
        decimal(10,2) amount
        date issue_date
        date payment_date
        enum status
    }
