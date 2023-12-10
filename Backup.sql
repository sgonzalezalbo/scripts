USE master;
GO

CREATE PROCEDURE ProcBackup
@path VARCHAR(256)
AS
BEGIN
    DECLARE 
        @name VARCHAR(50),
        @fileName VARCHAR(256),
        @fileDate VARCHAR(20),
        @backupCount INT

    -- Crear una tabla temporal
    CREATE TABLE #tempBackup (
        intID INT IDENTITY (1, 1),
        name VARCHAR(200)
    )

    SET @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112)

    -- Insertar datos en la tabla temporal
    INSERT INTO #tempBackup (name)
    SELECT name
    FROM master.dbo.sysdatabases
    WHERE name IN ('SALVAMENTO')

    -- Obtener la cantidad de registros en la tabla temporal
    SELECT TOP 1 @backupCount = intID 
    FROM #tempBackup 
    ORDER BY intID DESC

    -- Verificar si hay registros en la tabla temporal
    IF (@backupCount IS NOT NULL AND @backupCount > 0)
    BEGIN
        DECLARE @currentBackup INT
        SET @currentBackup = 1

        -- Realizar el respaldo para cada registro en la tabla temporal
        WHILE (@currentBackup <= @backupCount) 
        BEGIN
            SELECT
                @name = name,
                @fileName = @path + name + '_' + @fileDate + '.BAK' 
            FROM #tempBackup
            WHERE intID = @currentBackup

            -- Realizar el respaldo de la base de datos
            BACKUP DATABASE @name TO DISK = @fileName

            SET @currentBackup = @currentBackup + 1
        END
    END

    -- Eliminar la tabla temporal
    DROP TABLE #tempBackup
END
GO
