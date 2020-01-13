CREATE  PROCEDURE [partida].[UPD_PARTIDA_SP] 
@idTipoObjeto			INT,
@propiedades			XML,
@idUsuario				INT,
@idClase				VARCHAR(10),
@rfc					varchar(13),
@idCliente				int,
@numeroContrato			varchar(50),
@idTipoSolicitud		xml,
@err				    NVARCHAR(500) OUTPUT
AS
BEGIN TRY
	BEGIN TRANSACTION

	DECLARE @idPartida	AS INT
    DECLARE @tbl_propiedades AS TABLE(
        _row                    INT IDENTITY(1,1),
        propiedadDesc			NVARCHAR(250),
        idPropiedad				INT,
        valor                   NVARCHAR(500),
		fechaCaducidad			DATETIME,
        activo                  BIT,
		idTipoValor				NVARCHAR(250)
    )

	SET @idPartida = (SELECT TOP 1  ParamValues.col.value('idPartida[1]','int') FROM @propiedades.nodes('propiedades/propiedad') AS ParamValues(col))

	EXEC [partida].[INS_TIPOSOLICITUDPARTIDA_SP] @idPartida, @idTipoObjeto, @idClase,  @idUsuario, @idTipoSolicitud
    

	DELETE FROM partida.PartidaPropiedadGeneral  WHERE idPartida = @idPartida AND idClase = @idClase
	DELETE FROM partida.PartidaPropiedadClase  WHERE idPartida = @idPartida AND idClase = @idClase
	DELETE FROM partida.PartidaPropiedadContrato  WHERE idPartida = @idPartida AND idClase = @idClase


    INSERT INTO @tbl_propiedades(propiedadDesc,
								idPropiedad,
                                valor,
								fechaCaducidad,
                                activo,
								idTipoValor)

    SELECT
        ParamValues.col.value('propiedadDesc[1]','nvarchar(250)'),
        ParamValues.col.value('idPropiedad[1]','int'),
        ParamValues.col.value('valor[1]','nvarchar(500)'),
		ParamValues.col.value('fechaCaducidad[1]','datetime'),
        1,
		ParamValues.col.value('idTipoValor[1]','NVARCHAR(250)')

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
				INSERT INTO partida.PartidaPropiedadGeneral 
				SELECT
					@idPartida,
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
				INSERT INTO partida.PartidaPropiedadClase
				SELECT
					@idPartida,
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

		  ELSE IF(@propiedad = 'contrato')
            BEGIN
				INSERT INTO partida.PartidaPropiedadContrato
				SELECT
					@idPartida,
					@idTipoObjeto,
					@idClase,
					CASE 
						WHEN ((SELECT TOP 1 idTipoValor FROM @tbl_propiedades WHERE _row = @cont) != 'Unico') THEN valor
						ELSE idPropiedad
						END,
					@rfc,
					@idCliente,
					@numeroContrato,
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
