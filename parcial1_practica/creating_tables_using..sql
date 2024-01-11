

-- Crear la tabla reviews:
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    game_id INT NOT NULL,
    rating DECIMAL(3, 1) NOT NULL,
    comment VARCHAR(250),
    UNIQUE KEY (user_id, game_id),  -- solo un usuario tiene una review por juego3
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (game_id) REFERENCES games(game_id)
);

-- Eliminar filas con comment nulo y modificar la tabla reviews:

DELETE FROM reviews WHERE comment IS NULL;

-- Luego, modificamos la estructura de la tabla para que comment no acepte valores nulos:

ALTER TABLE person add total_medals INT DEFAULT 0;


-- Devolver el nombre y el rating promedio del género con mayor y menor rating promedio:
-- AVG, MAX, MIN, SUM, COUNT, COUNT(DISTINC __), SUM(DISTINC __), STDDEV, VARIANCE, 
-- Other useful shit
-- ORDER BY HIRE_DATE DESC
-- FETCH FIRST ROW ONLY;
SELECT g.genre_name, AVG(r.rating) AS avg_rating
FROM reviews r
INNER JOIN games g ON r.game_id = g.game_id
INNER JOIN genres gn ON g.genre_id = gn.genre_id
GROUP BY g.genre_name
ORDER BY avg_rating DESC
LIMIT 1; -- Para el género con mayor rating

-- usamos innerjoin para traer los datos importantes que están relacionados por algun valor entre sí.

SELECT g.genre_name, AVG(r.rating) AS avg_rating
FROM reviews r
INNER JOIN games g ON r.game_id = g.game_id
INNER JOIN genres gn ON g.genre_id = gn.genre_id
GROUP BY g.genre_name
ORDER BY avg_rating ASC
FETCH FIRST Row ONLY; -- Para el género con menor rating







Unknown column 'medals' in 'field list'
INSERT INTO person (id, total_medals)
SELECT  person.id, count(*) AS medals
FROM competitor_event
INNER JOIN games_competitor ON competitor_event.competitor_id = games_competitor.id
INNER JOIN person ON games_competitor.person_id = person.id
WHERE medal_id IS NOT NULL 
GROUP BY person.id
ON DUPLICATE KEY UPDATE person.total_medals = medals;

UPDATE person
SET total_medals = COUNT(*)
SELECT  person.id, count(*) AS medals
FROM competitor_event
INNER JOIN games_competitor ON competitor_event.competitor_id = games_competitor.id
INNER JOIN person ON games_competitor.person_id = person.id
WHERE medal_id IS NOT NULL 


-- Agregar la columna number_of_reviews a la tabla user:
ALTER TABLE users ADD COLUMN number_of_reviews INT DEFAULT 0 NOT NULL;


-- Devolver el nombre y el rating promedio de las 5 compañías desarrolladoras con mayor rating promedio:
SELECT d.developer_name, AVG(r.rating) AS avg_rating
FROM reviews r
INNER JOIN games g ON r.game_id = g.game_id
INNER JOIN developers d ON g.developer_id = d.developer_id
GROUP BY d.developer_name
ORDER BY avg_rating DESC
LIMIT 5;


-- Actualiza el campo number_of_reviews en la tabla users
INSERT INTO users (user_id, number_of_reviews)
SELECT r.user_id, COUNT(*) AS total_reviews
FROM reviews r
GROUP BY r.user_id
ON DUPLICATE KEY UPDATE users.number_of_reviews = VALUES(number_of_reviews);
