/*
 g33_jm6_mock_exam_sql
 Sobirov Nurmuhammad
 https://drawsql.app/teams/uzclan/diagrams/library-3 DrawSql link
 */



CREATE TABLE "book"(
                       "id" bigserial NOT NULL,
                       "name" VARCHAR(255) NOT NULL,
                       "author_id" BIGINT NOT NULL,
                       "language_id" BIGINT NOT NULL,
                       "genre_id" BIGINT NOT NULL
);
ALTER TABLE
    "book" ADD PRIMARY KEY("id");
CREATE TABLE "staff"(
                        "id" bigserial NOT NULL,
                        "name" VARCHAR(255) NOT NULL,
                        "phone_number" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "staff" ADD PRIMARY KEY("id");
CREATE TABLE "users"(
                        "id" bigserial primary key NOT NULL,
                        "name" varchar(255) NOT NULL,
                        "phone_number" VARCHAR(255) NOT NULL
);

CREATE TABLE "genre"(
                        "id" bigserial primary key NOT NULL,
                        "name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "genre" ADD PRIMARY KEY("id");
CREATE TABLE "author"(
                         "id" bigserial primary key NOT NULL,
                         "name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "author" ADD PRIMARY KEY("id");

CREATE TABLE "renting"(
                          "id" bigserial primary key NOT NULL,
                          "book_id" BIGINT NOT NULL,
                          "user_id" BIGINT NOT NULL,
                          "staff_id" BIGINT NOT NULL,
                          "rent_date" DATE NOT NULL,
                          "return_date" DATE NOT NULL
);

ALTER TABLE
    "renting" ADD PRIMARY KEY("id");

CREATE TABLE "language"(
                           "id" bigserial primary key NOT NULL,
                           "name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "language" ADD PRIMARY KEY("id");
ALTER TABLE
    "book" ADD CONSTRAINT "book_author_id_foreign" FOREIGN KEY("author_id") REFERENCES "author"("id");
ALTER TABLE
    "book" ADD CONSTRAINT "book_language_id_foreign" FOREIGN KEY("language_id") REFERENCES "language"("id");
ALTER TABLE
    "renting" ADD CONSTRAINT "renting_staff_id_foreign" FOREIGN KEY("staff_id") REFERENCES "staff"("id");
ALTER TABLE
    "renting" ADD CONSTRAINT "renting_book_id_foreign" FOREIGN KEY("book_id") REFERENCES "users"("id");

ALTER TABLE
    "book" ADD CONSTRAINT "book_genre_id_foreign" FOREIGN KEY("genre_id") REFERENCES "genre"("id");

INSERT INTO author (name) VALUES ('J.K. Rowling'), ('Stephen King'), ('Dan Brown');
INSERT INTO language (name) VALUES ('English'), ('Spanish'), ('French');
INSERT INTO genre (name) VALUES ('Fiction'), ('Non-fiction'), ('Mystery');
INSERT INTO book (name, author_id, language_id, genre_id) VALUES ('Harry Potter and the Philosopher''s Stone', 1, 1, 1), ('The Shining', 2, 1, 2), ('The Da Vinci Code', 3, 2, 3);
INSERT INTO staff (name, phone_number) VALUES ('John Doe', '123-456-7890'), ('Jane Doe', '098-765-4321');
INSERT INTO "users" (name, phone_number) VALUES ('Alice', '555-1234'), ('Bob', '555-5678');
INSERT INTO renting (book_id, user_id, rent_date, staff_id) VALUES (1, 1, '2023-01-01', 1), (2, 2, '2023-02-01', 2), (3, 1, '2023-03-01', 1);

select * from users;

select * from book;

select * from renting;

CREATE OR REPLACE FUNCTION fn_search_book(
    s_name varchar(255)
)
    returns table(
        book_id bigint,
        book_name varchar,
        book_author bigint,
        book_language bigint,
        book_genre bigint
                 )
language plpgsql
as
    $$
begin
return query
select * from book where book.name like '%'||s_name||'%';
end
    $$;

select * from fn_search_book(s_name := 'Potter');

select * from book;

CREATE OR REPLACE procedure pr_borrowing_books(
    i_user_id bigint,
    i_book_id bigint,
    i_staff_id bigint,
    i_return_date DATE
)
language plpgsql
as
    $$
begin
insert into renting(book_id, user_id, staff_id, rent_date, return_date)
values (i_book_id,i_user_id,i_staff_id, now(), i_return_date);
end;
    $$;

call pr_borrowing_books(i_user_id := 1, i_book_id := 2, i_staff_id := 3, i_return_date := date('2024-03-14'));
call pr_borrowing_books(i_user_id := 3, i_book_id := 1, i_staff_id := 3, i_return_date := date('2024-05-14'));
call pr_borrowing_books(i_user_id := 2, i_book_id := 3, i_staff_id := 1, i_return_date := date('2024-01-12'));

select * from renting;

Create view rented_books_will_return_not_today
as
select * from renting where return_date>current_date;

select * from rented_books_will_return_not_today;

CREATE MATERIALIZED VIEW number_of_books_rented_last_year
as
select count(book_id) from renting
where extract(year from rent_date) = extract(year from now())-1;

select * from number_of_books_rented_last_year;

insert into renting(book_id, user_id, staff_id, rent_date, return_date)
values (3,2,2,date('2023-05-12'),date('2023-08-11'));

refresh materialized view number_of_books_rented_last_year;

select * from renting;



