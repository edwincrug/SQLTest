CREATE PROCEDURE [partida].[INS_PARTIDA_PROPIEDADES_SP]
	@idClase			varchar(13) = NULL ,
    @idCliente			INT = 0,
	@numeroContrato		nvarchar(10) = NULL,
	@rfcEmpresa			varchar(13) = NULL,
	@idPadre			INT,
	@idTipoDato			nvarchar(10),
	@idTipoValor		nvarchar(10),
	@obligatorio		bit,
	@orden				INT,
	@activo				bit,
	@posicion			INT,
	@propiedad			nvarchar(10),
	@valor				nvarchar(250),
	@idUsuario			INT,
	@err				varchar(max) OUTPUT
		
AS

BEGIN
	
	DECLARE @msj		varchar(50) = '', 
			@VC_ErrorMessage	VARCHAR(4000)	= '',
			@VC_ThrowMessage	VARCHAR(100)	= 'An error has occured on [INS_PROPIEDADES]:',
			@VC_ErrorSeverity	INT = 0,
			@VC_ErrorState		INT = 0,
			@status		int = 0,
			@propiedadId	int = 0


	IF EXISTS(SELECT * FROM ( SELECT [idPropiedadClase] ,[valor] ,'clase'AS prop, activo
									FROM [Partida].[partida].[PropiedadClase]
								  UNION ALL
									SELECT [idPropiedadGeneral] ,[valor] ,'general', activo
									FROM [Partida].[partida].[PropiedadGeneral]
								  UNION ALL
									  SELECT [idPropiedadContrato] ,[valor] ,'contrato' , activo
									  FROM [Partida].[partida].[PropiedadContrato] ) propiedades
					WHERE LOWER(Valor) = LOWER(@valor) AND prop = @propiedad AND activo = 1)
		BEGIN
			SET @msj = 'El nombre de la propiedad ya existe';
			SET @propiedadId = (SELECT idPropiedadClase FROM ( SELECT [idPropiedadClase] ,[valor] ,'clase' AS prop
									FROM [Partida].[partida].[PropiedadClase]
								  UNION ALL
									SELECT [idPropiedadGeneral] ,[valor] ,'general'
									FROM [Partida].[partida].[PropiedadGeneral]
								  UNION ALL
									  SELECT [idPropiedadContrato] ,[valor] ,'contrato' 
									  FROM [Partida].[partida].[PropiedadContrato] ) propiedades
							WHERE LOWER(Valor) = LOWER(@valor))
		END
	ELSE
		BEGIN TRY
			BEGIN TRANSACTION INS_PROPIEDADES_PARTIDA_SP
						IF @propiedad = 'general'
				BEGIN
				INSERT INTO [partida].[PropiedadGeneral]
				VALUES
					(CASE WHEN (@idTipoValor = 'Unico' OR @idTipoValor = 'Etiqueta') THEN NULL
							ELSE @idPadre
							END
					,@idTipoValor
					,@idTipoDato
					,CASE WHEN (@idTipoValor = 'Unico' OR @idTipoValor = 'Etiqueta') THEN @valor
						ELSE (SELECT TOP 1 agrupador FROM [Partida].[partida].[PropiedadGeneral] WHERE idPropiedadGeneral = @idPadre)
						END
					,@valor
					,@obligatorio
					,@orden
					,@posicion
					,@activo
					,@idUsuario)

				set @status = 1;
				SET @propiedadId = SCOPE_IDENTITY();
				SET @msj = 'La propiedad se agrego correctamente';
				END 
						IF @propiedad = 'clase'
				BEGIN
				INSERT INTO [partida].[PropiedadClase]
				VALUES
					(@idClase
					,CASE WHEN (@idTipoValor = 'Unico' OR @idTipoValor = 'Etiqueta') THEN NULL
							ELSE @idPadre
							END
					,@idTipoValor
					,@idTipoDato
					,CASE WHEN (@idTipoValor = 'Unico' OR @idTipoValor = 'Etiqueta') THEN @valor
						ELSE (SELECT TOP 1 agrupador FROM [partida].[PropiedadClase] WHERE idPropiedadClase = @idPadre)
						END
					,@valor
					,@obligatorio
					,@orden
					,@posicion
					,@activo
					,@idUsuario)
				set @status = 1;
				SET @propiedadId = SCOPE_IDENTITY();
				SET @msj = 'La propiedad se agrego correctamente';
				END 
						IF @propiedad = 'contrato'
				BEGIN
				INSERT INTO [partida].[PropiedadContrato]
				VALUES
					(@rfcEmpresa
					,@idCliente
					,@numeroContrato
					,CASE WHEN (@idTipoValor = 'Unico' OR @idTipoValor = 'Etiqueta') THEN NULL
							ELSE @idPadre
							END
					,@idTipoValor
					,@idTipoDato
					,CASE WHEN (@idTipoValor = 'Unico' OR @idTipoValor = 'Etiqueta') THEN @valor
							ELSE (SELECT TOP 1 agrupador FROM [partida].[PropiedadContrato] WHERE idPropiedadContrato = @idPadre)
							END
					,@valor
					,@obligatorio
					,@orden
					,@posicion
					,@activo
					,@idUsuario)

				set @status = 1;
				SET @propiedadId = SCOPE_IDENTITY();
				SET @msj = 'La propiedad se agrego correctamente';
				END 


			COMMIT TRANSACTION INS_PROPIEDADES_PARTIDA_SP
		END TRY
		BEGIN CATCH
			SELECT  
				@VC_ErrorMessage	= ERROR_MESSAGE(),
				@VC_ErrorSeverity	= ERROR_SEVERITY(),
				@VC_ErrorState		= ERROR_STATE();
			BEGIN
				ROLLBACK TRANSACTION INS_PROPIEDADES_PARTIDA_SP
				SET @msj = 'Error al registar la propiedad';
				SET @VC_ErrorMessage = {
					fn CONCAT(
						@VC_ThrowMessage,
						@VC_ErrorMessage)
				}
				RAISERROR (
					@VC_ErrorMessage, 
					@VC_ErrorSeverity, 
					@VC_ErrorState
				);
			END
		END CATCH
	SELECT 
		@msj				AS [Message], 
		@status				AS [Insertado],
		@propiedadId			AS [PropiedadId];

    SET NOCOUNT OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END
GO
