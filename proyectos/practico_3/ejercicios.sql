
/* 1-*/
SELECT city.name, country.Name , country.Region , country.GovernmentForm 
FROM country
INNER JOIN city
ON city.CountryCode = country.Code
ORDER BY country.Population
DESC LIMIT  10;

/* 2- */
SELECT city.* , country.Name
FROM country
INNER JOIN city
ON city.ID = country.Capital 
ORDER BY country.Population
ASC LIMIT  10;

/* 3-*/
SELECT country.Name, country.Continent , countrylanguage.`Language`
FROM country
INNER JOIN countrylanguage
ON country.Code = countrylanguage.CountryCode
WHERE countrylanguage.IsOfficial IS TRUE;

/* 4-*/
SELECT country.Name, city.Name
FROM country
INNER JOIN city
ON city.ID = country.Capital
ORDER BY country.SurfaceArea DESC LIMIT 20;

/* 5-*/
SELECT city.Name, countrylanguage.`Language`, countrylanguage.Percentage
FROM city
INNER JOIN countrylanguage
ON city.CountryCode = countrylanguage.CountryCode;
/* 6-*/
(SELECT  country.Name
FROM country
WHERE (country.Population < 100)
ORDER BY country.Population ASC 
LIMIT 10)
UNION
(SELECT country.Name
FROM country
ORDER BY country.Population DESC
LIMIT  10);
/* 7-*/
(SELECT country.Name
FROM country INNER JOIN countrylanguage
WHERE    
countrylanguage.IsOfficial = 'T' AND  country.Code = countrylanguage.CountryCode
AND countrylanguage.`Language` = 'English')
INTERSECT
(
SELECT country.Name
FROM country INNER JOIN countrylanguage
WHERE
countrylanguage.IsOfficial = 'T' AND  country.Code = countrylanguage.CountryCode
AND countrylanguage.`Language` = 'French');
/* 8-*/
(SELECT country.name, countrylanguage.`Language` 
FROM country INNER JOIN countrylanguage
WHERE
countrylanguage.`Language` = 'English' AND  country.Code  = countrylanguage.CountryCode)
INTERSECT
(SELECT country.name, countrylanguage.`Language`
FROM country INNER JOIN countrylanguage
WHERE 
NOT countrylanguage.`Language` = 'Spanish' AND  country.Code = countrylanguage.CountryCode);



/* 9*/
SELECT city.Name, country.Name
FROM city
INNER JOIN country ON city.CountryCode = country.Code AND country.Name = 'Argentina';


SELECT city.Name , country.Name
FROM city
INNER JOIN country ON city.CountryCode = country.Code
WHERE  country.Name = 'Argentina';


/* 
Ambas consultas anteriores generan resultados idénticos debido a que utilizan una operación INNER JOIN, 
que combina las tablas en función de la igualdad de las columnas. En la primera consulta,
se agrega una condición adicional de filtrado en la columna country.Name = 'Argentina',
mientras que en la segunda consulta, se realiza la unión de las dos tablas primero y luego se 
filtran las filas en función de la misma condición*/














SELECT city.Name, country.Name
FROM city
LEFT JOIN country ON city.CountryCode = country.Code AND country.Name = 'Argentina';


SELECT city.Name , country.Name
FROM city
LEFT JOIN country ON city.CountryCode = country.Code
WHERE  country.Name = 'Argentina';


/* Las 2 querys de arriba devuelven resultados diferentes porque al ser un left join, todas las filas de la tabla city estan incluidas(Se muestra todas las ciudades), y solo donde el pais es Argentina se muestra el pais.
En la segunda query, solo se muestran las ciudades de ‘Argentina’. Esto es porque se juntan todas las filas de la tabla city con country, y luego SE FILTRAN las filas donde country.Name = ‘Argentina’
 */