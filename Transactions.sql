CREATE TABLE BANCO (
    IDCuenta VARCHAR(6) PRIMARY KEY,
    Saldo DECIMAL NOT NULL);

-- Inserto el saldo inicial, por ejemplo, 1000.
UPDATE INTO BANCO (IDCuenta,Saldo ) VALUES ('CUE001', '1000');


BEGIN TRY
    BEGIN TRANSACTION;

    -- Intenta realizar la inserción en COMPRAS
    INSERT INTO COMPRAS (IDCompra, Precio, Fecha, PROVEEDORES_IDProveedor)
    VALUES ('COM002', 200, '2023-12-10', '09050681C');

    -- Intenta realizar la actualización en BANCO
    UPDATE BANCO
    SET Saldo = Saldo - 200D
	WHERE IDCuenta = 'CUE001';

    -- Si no hay errores, confirma la transacción
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Si hay algún error, revierte la transacción
    ROLLBACK;
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;

