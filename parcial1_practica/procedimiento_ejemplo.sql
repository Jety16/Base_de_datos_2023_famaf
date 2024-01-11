DELIMITER //

CREATE PROCEDURE add_product_stock_to_store(
    IN store_name VARCHAR(255),
    IN product_name VARCHAR(255),
    IN quantity INT
)
BEGIN
    DECLARE current_quantity INT;

    -- Obtener la cantidad actual del producto en la tienda
    SELECT quantity INTO current_quantity
    FROM stocks
    WHERE store_name = store_name AND product_name = product_name;

    -- Si no existe una entrada para el producto en la tienda, insertarla
    IF current_quantity IS NULL THEN
        INSERT INTO stocks (store_name, product_name, quantity)
        VALUES (store_name, product_name, quantity);
    ELSE
        -- Actualizar la cantidad existente sumándole la cantidad de entrada
        UPDATE stocks
        SET quantity = current_quantity + quantity
        WHERE store_name = store_name AND product_name = product_name;
    END IF;
END //

DELIMITER ;

DELIMITER //
CREATE PROCEDURE set_user_number_of_reviews(IN username VARCHAR(255))
BEGIN
    UPDATE users
    SET number_of_reviews = (
        SELECT COUNT(*)
        FROM reviews
        WHERE user_id = (SELECT user_id FROM users WHERE username = username)
    )
    WHERE username = username;
END;
//
DELIMITER ;
