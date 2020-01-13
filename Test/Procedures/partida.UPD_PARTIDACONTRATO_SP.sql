CREATE  PROCEDURE [partida].[UPD_PARTIDACONTRATO_SP] 
@idTipoObjeto			INT,
@idClase				VARCHAR(10),
@idUsuario				INT,
@rfc					varchar(13),
@idCliente				int,
@numeroContrato			varchar(50),
@propiedades			XML,
@err				    NVARCHAR(500) OUTPUT
AS
BEGIN 

	DECLARE @idPartida	AS INT
    DECLARE @tbl_propiedades AS TABLE(
        _row                    INT IDENTITY(1,1),
        propiedadDesc			NVARCHAR(250),
        idPropiedad				INT,
        valor                   NVARCHAR(500),
		fechaCaducidad			DATETIME,
		idTipoValor				NVARCHAR(250)
    )

	SET @idPartida = (SELECT TOP 1  ParamValues.col.value('idPartida[1]','int') FROM @propiedades.nodes('propiedades/propiedad') AS ParamValues(col))

	DELETE FROM partida.PartidaContratoPropiedadGeneral  WHERE idPartidaContrato = @idPartida AND idClase= @idClase AND rfcEmpresa= @rfc AND idCliente = @idCliente AND numeroContrato = @numeroContrato
	DELETE FROM partida.PartidaContratoPropiedadClase  WHERE idPartidaContrato = @idPartida AND idClase= @idClase AND rfcEmpresa= @rfc AND idCliente = @idCliente AND numeroContrato = @numeroContrato
	DELETE FROM partida.PartidaContratoPropiedadContrato  WHERE idPartidaContrato = @idPartida AND idClase= @idClase AND rfcEmpresa= @rfc AND idCliente = @idCliente AND numeroContrato = @numeroContrato


    INSERT INTO @tbl_propiedades(propiedadDesc,
								idPropiedad,
                                valor,
								fechaCaducidad,
								idTipoValor)

    SELECT
        ParamValues.col.value('propiedadDesc[1]','nvarchar(250)'),
        ParamValues.col.value('idPropiedad[1]','int'),
        ParamValues.col.value('valor[1]','nvarchar(500)'),
		ParamValues.col.value('fechaCaducidad[1]','datetime'),
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
				INSERT INTO partida.PartidaContratoPropiedadGeneral 
				SELECT
					@idPartida,
					@idTipoObjeto,
					@idClase,
					@rfc,
					@idCliente,
					@numeroContrato,
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
				INSERT INTO partida.PartidaContratoPropiedadClase
				SELECT
					@idPartida,
					@idTipoObjeto,
					@idClase,
					@rfc,
					@idCliente,
					@numeroContrato,
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
				INSERT INTO partida.PartidaContratoPropiedadContrato
				SELECT
					@idPartida,
					@idTipoObjeto,
					@idClase,
					@rfc,
					@idCliente,
					@numeroContrato,
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


	END

GO
