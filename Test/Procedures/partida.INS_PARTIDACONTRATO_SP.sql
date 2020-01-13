CREATE  PROCEDURE [partida].[INS_PARTIDACONTRATO_SP] 
@idTipoObjeto			INT,
@numeroContrato			VARCHAR(50),
@idCliente				INT,
@rfc					varchar(13),
@idClase				VARCHAR(10),
@propiedades			XML,
@idUsuario				INT,
@err				    NVARCHAR(500) OUTPUT
AS
BEGIN 
	BEGIN TRANSACTION

	DECLARE @idPartida	AS INT
    DECLARE @tbl_propiedades AS TABLE(
        _row                    INT IDENTITY(1,1),
		propiedadDesc			VARCHAR(10),
        idPropiedad				INT,
        valor                   VARCHAR(500),
		fechaCaducidad			DATETIME,
        activo                  BIT,
		idTipoValor				VARCHAR(250)
    )

    INSERT INTO @tbl_propiedades(
								propiedadDesc,
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
		ParamValues.col.value('idTipoValor[1]','nvarchar(250)')

        FROM @propiedades.nodes('propiedades/propiedad') AS ParamValues(col)

	INSERT INTO partida.PartidaContrato
	SELECT TOP 1
		@idTipoObjeto,
		@idClase,
		@rfc,
		@idCliente,
		@numeroContrato,
		1,
		@idUsuario
	FROM @tbl_propiedades

	SET @idPartida = @@IDENTITY


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

	COMMIT transaction


	END
GO
