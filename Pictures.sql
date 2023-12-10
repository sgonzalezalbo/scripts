
CREATE TABLE FOTOS_SOCORRISTAS
(
    IDFoto VARCHAR(6) PRIMARY KEY,
    Foto VARBINARY(MAX) NOT NULL,
    RutaFoto NVARCHAR(MAX) NOT NULL,
);

CREATE OR ALTER PROCEDURE ProcSubirImagen (
     @IDImagen VARCHAR (6)
   , @Ruta NVARCHAR (1000)
   , @Nombre NVARCHAR (1000)
)
AS
BEGIN
    DECLARE @Path2OutFile NVARCHAR (2000);
    DECLARE @tsql NVARCHAR (2000);

    SET NOCOUNT ON;

    SET @Path2OutFile = CONCAT(@Ruta, '\', @Nombre);

    SET @tsql = 'INSERT INTO FOTOS_SOCORRISTAS (IDFoto, Foto, RutaFoto) ' +
               'SELECT ' + '''' + @IDImagen + '''' + ', CONVERT(VARBINARY(MAX), BulkColumn), * ' + 
               'FROM OPENROWSET(BULK ' + '''' + @Path2OutFile + '''' + ', SINGLE_BLOB) as img';

    EXEC (@tsql);

    SET NOCOUNT OFF;
END;
'


CREATE OR ALTER PROCEDURE ProcBajarImagen (
   @IDImagen NVARCHAR (6)
   ,@Ruta NVARCHAR(1000)
   ,@Nombre NVARCHAR(1000)
   )
AS
BEGIN
   DECLARE @ImageData VARBINARY (max);
   DECLARE @Path2OutFile NVARCHAR (2000);
   DECLARE @Obj INT
 
   SET NOCOUNT ON
 
   SELECT @ImageData = (
         SELECT convert (VARBINARY (max), Foto, 1)
         FROM FOTOS_SOCORRISTAS
         WHERE IDFoto = @IDImagen
         );
 
   SET @Path2OutFile = CONCAT (
         @Ruta
         ,'\'
         , @Nombre
         );
    BEGIN TRY
     EXEC sp_OACreate 'ADODB.Stream' ,@Obj OUTPUT;
     EXEC sp_OASetProperty @Obj ,'Type',1;
     EXEC sp_OAMethod @Obj,'Open';
     EXEC sp_OAMethod @Obj,'Write', NULL, @ImageData;
     EXEC sp_OAMethod @Obj,'SaveToFile', NULL, @Path2OutFile, 2;
     EXEC sp_OAMethod @Obj,'Close';
     EXEC sp_OADestroy @Obj;
    END TRY
    
 BEGIN CATCH
  EXEC sp_OADestroy @Obj;
 END CATCH
 
   SET NOCOUNT OFF
END
GO

'

exec ProcBajarImagen 'IMG01','C:\IMAGENES\SALIDA','EXPORTADA.jpg'
GO
