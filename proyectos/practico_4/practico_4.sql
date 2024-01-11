/*Listar el nombre de la ciudad y el nombre del país de todas las ciudades que pertenezcan a países con una población menor a 10,000 habitantes.
*/

SELECT city.name, country.name
FROM city
JOIN country ON city.country_code = country.code
WHERE country.population < 10000;

/* Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.
*/

SELECT name
FROM city
WHERE population > (SELECT AVG(population) FROM city);

/*Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total de algún país de Asia.*/

SELECT city.name
FROM city
JOIN country ON city.country_code = country.code
WHERE city.population >= ANY (SELECT MAX(population) FROM country WHERE continent = 'Asia')
AND country.continent != 'Asia';

/*Listar aquellos países junto a sus idiomas no oficiales, que superen en porcentaje de hablantes a cada uno de los idiomas oficiales del país.
*/

SELECT c.name AS country, cl.Language AS non_official_language
FROM country c
JOIN countrylanguage cl ON c.code = cl.CountryCode
WHERE cl.Percentage > ALL (SELECT cl2.Percentage FROM countrylanguage cl2 WHERE cl2.CountryCode = c.code AND cl2.IsOfficial = 'T');

/*Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 y exista (en el país) al menos una ciudad con más de 100,000 habitantes. (Versión con subquery)
*/
SELECT DISTINCT r.region
FROM country r
WHERE r.surface_area < 1000 AND EXISTS (SELECT 1 FROM city c WHERE c.country_code = r.code AND c.population > 100000);

/*Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada. (Usando consultas escalares)
*/

SELECT c.name AS country, (
    SELECT MAX(city.population) 
    FROM city 
    WHERE city.country_code = c.code
) AS max_city_population
FROM country c;

/*Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de hablantes sea mayor al promedio de hablantes de los lenguajes oficiales.
*/

SELECT c.name AS country, cl.Language AS non_official_language
FROM country c
JOIN countrylanguage cl ON c.code = cl.CountryCode
WHERE cl.Percentage > (SELECT AVG(cl2.Percentage) FROM countrylanguage cl2 WHERE cl2.CountryCode = c.code AND cl2.IsOfficial = 'T');

/*Listar la cantidad de habitantes por continente ordenado en forma descendente.
*/

SELECT c.continent, SUM(c.population) AS total_population
FROM country c
GROUP BY c.continent
ORDER BY total_population DESC;

/* Listar el promedio de esperanza de vida (LifeExpectancy) por continente con una esperanza de vida entre 40 y 70 años.
*/

    SELECT c.continent, AVG(c.life_expectancy) AS avg_life_expectancy
    FROM country c
    WHERE c.life_expectancy BETWEEN 40 AND 70
    GROUP BY c.continent;

/*   Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente.
*/

SELECT c.continent, MAX(c.population) AS max_population, MIN(c.population) AS min_population, AVG(c.population) AS avg_population, SUM(c.population) AS total_population
FROM country c
GROUP BY c.continent;

/* Parte II - Preguntas

Si en la consulta 6 se quisiera devolver, además de las columnas ya solicitadas, el nombre de la ciudad más poblada. ¿Podría lograrse con agrupaciones? ¿y con una subquery escalar?

Sí, se puede lograr tanto con agrupaciones como con una subquery escalar.

Usando agrupaciones:
*/

SELECT c.name AS country, MAX(city.population) AS max_city_population,
    (SELECT name FROM city WHERE city.population = MAX(city.population) AND city.country_code = c.code) AS most_populous_city
FROM country c
JOIN city ON c.code = city.country_code
GROUP BY c.name;

/*Usando una subquery escalar:*/

SELECT c.name AS country, (
   SELECT MAX(city.population) 
   FROM city 
   WHERE city.country_code = c.code
) AS max_city_population,
(
   SELECT city.name
   FROM city
   WHERE city.population = (SELECT MAX(city.population) FROM city WHERE city.country_code = c.code)
   AND city.country_code = c.code
) AS most_populous_city
FROM country c;

/* Ambos enfoques devuleven el nombre de la ciudad más poblada. además devuelve las columnas ya solicitadas en la consulta 6.