


-- Trigger para aumentar el número de revisiones después de una inserción en la tabla reviews
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


-- Trigger para disminuir el número de revisiones después de eliminar una fila de la tabla reviews
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

