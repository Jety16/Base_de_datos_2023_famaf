


-- podemos usar your_user@localhost o los roles directamente como está arriba 
GRANT INSERT, UPDATE, DELETE ON your_database.your_table TO 'your_user'@'localhost';


GRANT EXECUTE ON PROCEDURE your_database.your_procedure TO 'your_user'@'localhost';


GRANT CREATE, DROP ON your_database.* TO 'your_user'@'localhost';

--- specific column
GRANT SELECT (column1, column2) ON your_database.your_table TO 'your_user'@'localhost';


