-- 1 Crear un campo nuevo `total_medals` en la tabla `person` que almacena la cantidad de medallas ganadas por cada persona. Por defecto, con valor 0.
ALTER TABLE person add total_medals INT DEFAULT 0;

-- 2 Actualizar la columna  `total_medals` de cada persona con el recuento real de 
-- medallas que ganó. Por ejemplo, para Michael Fred Phelps II, luego de la actualización 
-- debería tener como valor de `total_medals` igual a 28.

UPDATE person SET total_medals = (
   SELECT COUNT(*)
   FROM competitor_event
   INNER JOIN games_competitor ON competitor_event.competitor_id = games_competitor.id
   WHERE games_competitor.person_id = person.id
   AND competitor_event.medal_id IS NOT NULL
);


-- 3 Devolver todos los medallistas olímpicos de Argentina, 
-- es decir, los que hayan logrado alguna medalla de oro, plata, 
-- o bronce, enumerando la cantidad por tipo de mallas
-- (por ejemplo, | Juan Martn del Potro       | Bronze     |        2 |
--               | Juan Martn del Potro       | Silver     |        2 |

SELECT person.full_name, medal.medal_name,
  (
    SELECT COUNT(*)
    FROM competitor_event
    WHERE competitor_event.competitor_id = games_competitor.id
    AND games_competitor.person_id = person.id
  ) AS quantity
FROM person
INNER JOIN games_competitor ON person.id = games_competitor.person_id
INNER JOIN competitor_event ON games_competitor.id = competitor_event.competitor_id
INNER JOIN medal ON competitor_event.medal_id = medal.id
INNER JOIN person_region ON person.id = person_region.person_id
INNER JOIN noc_region ON person_region.region_id = noc_region.id
WHERE noc_region.noc = 'ARG' AND NOT medal.medal_name = 'NA'
ORDER BY person.full_name, medal.medal_name;


--4  Listar el total de medallas ganadas por los deportistas argentinos en cada deporte.
SELECT
  sport.sport_name,
  COUNT(*) AS total_medals
FROM sport
INNER JOIN event ON sport.id = event.sport_id
INNER JOIN competitor_event ON event.id = competitor_event.event_id
INNER JOIN medal ON competitor_event.medal_id = medal.id
INNER JOIN games_competitor ON competitor_event.competitor_id = games_competitor.id
INNER JOIN person ON games_competitor.person_id = person.id
INNER JOIN person_region ON person.id = person_region.person_id
INNER JOIN noc_region ON person_region.region_id = noc_region.id
WHERE noc_region.noc = 'ARG' AND NOT medal.medal_name = 'NA'
GROUP BY sport.sport_name;

--5 Listar el número total de medallas de oro, plata y bronce ganadas por cada país
-- (país representado en la tabla `noc_region`), agruparlas los resultados por pais.
SELECT
  noc_region.noc,
  medal.medal_name,
  COUNT(*) AS total_medals
FROM noc_region
INNER JOIN person_region ON person_region.region_id = noc_region.id
INNER JOIN person ON person_region.person_id = person.id
INNER JOIN games_competitor ON person.id = games_competitor.person_id
INNER JOIN competitor_event ON games_competitor.id = competitor_event.competitor_id
INNER JOIN medal ON competitor_event.medal_id = medal.id
WHERE NOT medal.medal_name = 'NA'
GROUP BY noc_region.region_name, medal.medal_name, competitor_event.medal_id;


-- 6 
-- con mneos medallas 
SELECT
  noc_region.region_name,
  medal.medal_name,
  COUNT(*) AS total_medals
FROM noc_region
INNER JOIN person_region ON person_region.region_id = noc_region.id
INNER JOIN person ON person_region.person_id = person.id
INNER JOIN games_competitor ON person.id = games_competitor.person_id
INNER JOIN competitor_event ON games_competitor.id = competitor_event.competitor_id
INNER JOIN medal ON competitor_event.medal_id = medal.id
WHERE NOT medal.medal_name = 'NA'
GROUP BY noc_region.region_name, medal.medal_name, competitor_event.medal_id
ORDER BY total_medals ASC LIMIT 1;


-- con mas medallas
SELECT
  noc_region.region_name,
  medal.medal_name,
  COUNT(*) AS total_medals
FROM noc_region
INNER JOIN person_region ON person_region.region_id = noc_region.id
INNER JOIN person ON person_region.person_id = person.id
INNER JOIN games_competitor ON person.id = games_competitor.person_id
INNER JOIN competitor_event ON games_competitor.id = competitor_event.competitor_id
INNER JOIN medal ON competitor_event.medal_id = medal.id
WHERE NOT medal.medal_name = 'NA'
GROUP BY noc_region.region_name, medal.medal_name, competitor_event.medal_id
ORDER BY total_medals DESC LIMIT 1;

-- 7

-- Trigger para aumentar el número de medallas después de una inserción en la tabla competitor event
DELIMITER //
CREATE TRIGGER increase_number_of_medals
AFTER INSERT ON competitor_event
FOR EACH ROW
BEGIN
    UPDATE person
    SET total_medals = total_medals + 1
    WHERE person.id = (
        SELECT person_id
        FROM games_competitor
        WHERE id = NEW.competitor_id
    );
END;
//
DELIMITER ;


-- Trigger para disminuir el número de medallas después de una eliminacion en la tabla competitor event
DELIMITER //
CREATE TRIGGER decrease_number_of_medals
AFTER DELETE ON competitor_event
FOR EACH ROW
BEGIN
    UPDATE person
    SET total_medals = total_medals - 1
    WHERE person.id = (
        SELECT person_id
        FROM games_competitor
        WHERE id = OLD.competitor_id
    );
END;
//
DELIMITER ;

--8 Crear un procedimiento  `add_new_medalists` que tomará un `event_id`, y tres ids de atletas `g_id`, `s_id`, y `b_id` donde se deberá insertar tres registros en la tabla `competitor_event`  asignando a `g_id` la medalla de oro, a `s_id` la medalla de plata, y a `b_id` la medalla de bronce.
DELIMITER //

CREATE PROCEDURE add_new_medalists(
  IN event_id INT,
  IN g_id INT,
  IN s_id INT,
  IN b_id INT
)
BEGIN
  -- Insertar gold
  INSERT INTO competitor_event (event_id, competitor_id, medal_id)
  VALUES (event_id, g_id, 1); 

  -- Insertar silver
  INSERT INTO competitor_event (event_id, competitor_id, medal_id)
  VALUES (event_id, s_id, 2);

  -- Insertar bronze
  INSERT INTO competitor_event (event_id, competitor_id, medal_id)
  VALUES (event_id, b_id, 3);
END;
//

DELIMITER ;



-- 9 Crear el rol `organizer` y asignarle permisos de eliminación sobre la tabla `games` y permiso de actualización sobre la columna `games_name`  de la tabla `games` .
-- No pude testear esto por mi version de mysql, pero debería de ser así la sintaxis:
-- Acá hay un stackoverflow que lo explica jaja:
-- https://stackoverflow.com/questions/63738070/syntax-error-in-mysql-but-with-correct-syntax-when-creating-role
-- Crear el rol 'organizer'
CREATE ROLE organizer;

-- Asignar permisos de eliminación
GRANT DELETE ON games TO organizer;

-- Asignar permiso de actualización
GRANT UPDATE(games_name) ON games TO organizer;