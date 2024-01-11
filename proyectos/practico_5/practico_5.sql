-- Create a table for directors with columns: Name, Last Name, Number of Movies.
CREATE TABLE directors (
  director_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  num_movies_directed INT DEFAULT 0
);

-- Insert data of the top 5 actors who are also directors into the directors table using a subquery.
-- This subquery counts the number of movies each actor has acted in.
INSERT INTO directors (first_name, last_name, num_movies_directed)
SELECT a.first_name, a.last_name, COUNT(fa.film_id)
FROM actor AS a
JOIN film_actor AS fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY COUNT(fa.film_id) DESC
LIMIT 5;

-- Add a 'premium_customer' column to the customer table with a default value of 'F'.
ALTER TABLE customer
ADD COLUMN premium_customer CHAR(1) DEFAULT 'F';

-- Update the 'premium_customer' column for the top 10 customers with the highest spending.
UPDATE customer
SET premium_customer = 'T'
WHERE customer_id IN (
  SELECT customer_id
  FROM payment
  GROUP BY customer_id
  ORDER BY SUM(amount) DESC
  LIMIT 10
);

-- List the distinct movie ratings (G, PG, PG-13, R, NC-17) ordered by count of movies in each rating.
SELECT rating, COUNT(*) AS cantidad
FROM film
GROUP BY rating
ORDER BY cantidad DESC;

-- Find the first and last payment dates.
SELECT MIN(payment_date) AS primera_fecha_pago
FROM payment;

SELECT MAX(payment_date) AS ultima_fecha_pago
FROM payment;

-- Calculate the average payment amount per month.
SELECT DATE_FORMAT(payment_date, '%M %Y') AS mes,
       AVG(amount) AS promedio_pago
FROM payment
GROUP BY mes
ORDER BY payment_date;

-- List the top 10 districts with the most rentals, along with the total number of rentals in each district.
SELECT a.district, COUNT(r.rental_id) AS total_alquileres
FROM address AS a
JOIN customer AS c ON a.address_id = c.address_id
JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY a.district
ORDER BY total_alquileres DESC
LIMIT 10;

-- Add a 'stock' column to the inventory table with a default value of 5.
ALTER TABLE inventory
ADD COLUMN stock INT DEFAULT 5;

-- Create a trigger 'update_stock' that subtracts one copy from stock each time a rental is inserted.
DELIMITER //
CREATE TRIGGER update_stock
AFTER INSERT ON rental
FOR EACH ROW
BEGIN
  UPDATE inventory
  SET stock = stock - 1
  WHERE inventory_id = NEW.inventory_id;
END;
//
DELIMITER ;

-- Create a fines table with rental_id and amount columns.
CREATE TABLE fines (
  rental_id INT NOT NULL,
  amount DECIMAL(5,2)
);

-- Create a procedure 'check_date_and_fine' that checks rentals for late returns and calculates fines.
DELIMITER //
CREATE PROCEDURE check_date_and_fine()
BEGIN
  INSERT INTO fines (rental_id, amount)
  SELECT r.rental_id, DATEDIFF(r.return_date, r.rental_date) * 1.5
  FROM rental AS r
  WHERE r.return_date IS NOT NULL
  AND DATEDIFF(r.return_date, r.rental_date) > 3;
END;
//
DELIMITER ;


-- Create an 'employee' user with insert, update, and delete privileges on the 'rental' table:

CREATE USER 'employee'@'localhost' IDENTIFIED BY 'password'; -- Replace 'password' with a secure password

GRANT INSERT, UPDATE, DELETE ON sakila.rental TO 'employee'@'localhost';

-- Revoke delete access from 'employee' and create an 'administrator' user with all privileges on the 'sakila' database:


REVOKE DELETE ON sakila.rental FROM 'employee'@'localhost';

CREATE USER 'administrator'@'localhost' IDENTIFIED BY 'password'; -- Replace 'password' with a secure password

GRANT ALL PRIVILEGES ON sakila.* TO 'administrator'@'localhost';

-- Create two users, one with 'employee' permissions and the other with 'administrator' permissions:

CREATE USER 'employee_user_1'@'localhost' IDENTIFIED BY 'password'; -- Replace 'password' with a secure password

GRANT INSERT, UPDATE, DELETE ON sakila.rental TO 'employee_user_1'@'localhost';

CREATE USER 'administrator_user_1'@'localhost' IDENTIFIED BY 'password'; -- Replace 'password' with a secure password

GRANT ALL PRIVILEGES ON sakila.* TO 'administrator_user_1'@'localhost';
