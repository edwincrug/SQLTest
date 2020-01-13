CREATE  PROCEDURE [partida].[INS_PARTIDA_SP] 
@idTipoObjeto			INT,
@idClase				varchar(10),
@idUsuario				int,
@rfc					varchar(13),
@idCliente				int,
@numeroContrato			varchar(50),
@propiedades			XML,
@idTipoSolicitud		xml,
@err				    NVARCHAR(500) OUTPUT
AS
BEGIN TRY
	BEGIN TRANSACTION
	DECLARE
		@VI_One				INT = 1,
		@VI_Zero			INT = 0,
		@VC_ErrorMessage	VARCHAR(4000)	= '',
		@VC_ThrowMessage	VARCHAR(100)	= 'Ocurrio un error en el stored: [INS_TIPOSOLICITUD_SP]:',
		@VC_ErrorSeverity	INT = 0,
		@VC_ErrorState		INT = 0,
		@VI_ResultCount		INT = 0,
		@VI_Result			BIT = 0
	DECLARE @idPartida	AS INT
    DECLARE @tbl_propiedades AS TABLE(
        _row                    INT IDENTITY(1,1),
		idClase					NVARCHAR(250),
		propiedadDesc			NVARCHAR(250),
        idPropiedad				INT,
        valor                   NVARCHAR(500),
		fechaCaducidad			DATETIME,
        activo                  BIT,
		idTipoValor				NVARCHAR(250)
    )

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
		ParamValues.col.value('idTipoValor[1]','nvarchar(250)')

        FROM @propiedades.nodes('propiedades/propiedad') AS ParamValues(col)

	INSERT INTO partida.Partida 
	SELECT TOP 1
		@idTipoObjeto,
		@idClase,
		1,
		@idUsuario
	FROM @tbl_propiedades

	SET @idPartida = @@IDENTITY;

	EXEC [partida].[INS_TIPOSOLICITUDPARTIDA_SP] @idPartida, @idTipoObjeto, @idClase,  @idUsuario, @idTipoSolicitud
    
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

	COMMIT transaction


	
	SELECT @idPartida as idPartida

END TRY

BEGIN CATCH
ROLLBACK transaction
END CATCH





GO
