  
CREATE  PROCEDURE [tipoobjeto].[UPD_TIPOOBJETO_SP]   
@propiedades		XML,  
@idClase			VARCHAR(10),
@idUsuario			INT,
@err				NVARCHAR(500) OUTPUT  
AS  
BEGIN TRY  
 BEGIN TRANSACTION  
  
 DECLARE @idTipoObjeto AS INT  
    DECLARE @tbl_propiedades AS TABLE(  
        _row                    INT IDENTITY(1,1),  
        propiedadDesc			VARCHAR(250),  
        idPropiedad				INT,  
        valor                   VARCHAR(500),  
		fechaCaducidad			DATETIME,  
		idTipoValor				VARCHAR(250)  
    )  
  
 SET @idTipoObjeto = (SELECT TOP 1  ParamValues.col.value('idTipoObjeto[1]','int') FROM @propiedades.nodes('propiedades/propiedad') AS ParamValues(col))  
  
 DELETE FROM tipoobjeto.TipoObjetoPropiedadGeneral  WHERE idTipoObjeto = @idTipoObjeto and idClase= @idClase
 DELETE FROM tipoobjeto.TipoObjetoPropiedadClase  WHERE idTipoObjeto = @idTipoObjeto and idClase= @idClase   
  
  
    INSERT INTO @tbl_propiedades(
		propiedadDesc,  
        idPropiedad,  
		valor,  
        fechaCaducidad,  
        idTipoValor)  
  
    SELECT  
        ParamValues.col.value('propiedadDesc[1]','varchar(250)'),  
        ParamValues.col.value('idPropiedad[1]','int'),  
        ParamValues.col.value('valor[1]','varchar(500)'),  
  ParamValues.col.value('fechaCaducidad[1]','datetime'),  
  ParamValues.col.value('idTipoValor[1]','VARCHAR(250)')  
  
        FROM @propiedades.nodes('propiedades/propiedad') AS ParamValues(col)  
  
    
  
 DECLARE @cont INT = 1  
  
    WHILE((SELECT COUNT(*) FROM @tbl_propiedades)>= @cont)  
  
    BEGIN  
        DECLARE @propiedad NVARCHAR(250);  
        SELECT @propiedad = propiedadDesc  
        FROM @tbl_propiedades   
        WHERE _row = @cont  
  
       IF(@propiedad = 'general')  
   BEGIN  
    INSERT INTO tipoobjeto.TipoObjetoPropiedadGeneral   
    SELECT  
     @idTipoObjeto,  
	 @idClase,
     CASE  
      WHEN ((SELECT TOP 1 idTipoValor FROM @tbl_propiedades WHERE _row = @cont) != 'Unico') THEN valor  
      ELSE idPropiedad  
      END,  
     CASE   
      WHEN ((SELECT TOP 1 idTipoValor FROM @tbl_propiedades WHERE _row = @cont) != 'Unico') THEN ''  
      ELSE valor  
      END,  
     fechaCaducidad,
	 @idUsuario 
    FROM @tbl_propiedades  
    WHERE _row = @cont  
   END  
  
        ELSE IF(@propiedad = 'clase')  
            BEGIN  
    INSERT INTO tipoobjeto.TipoObjetoPropiedadClase  
    SELECT  
     @idTipoObjeto,  
	 @idClase,
     CASE   
      WHEN ((SELECT TOP 1 idTipoValor FROM @tbl_propiedades WHERE _row = @cont) != 'Unico') THEN valor  
      ELSE idPropiedad  
      END,  
     CASE  
      WHEN ((SELECT TOP 1 idTipoValor FROM @tbl_propiedades WHERE _row = @cont) != 'Unico') THEN ''  
      ELSE valor  
      END,  
     fechaCaducidad,
	 @idUsuario
    FROM @tbl_propiedades  
    WHERE _row = @cont  
  
            END  
  
  
        SET @cont = @cont + 1  
 END  
  
 COMMIT  
END TRY  
  
BEGIN CATCH  
ROLLBACK  
END CATCH  
  
GO
