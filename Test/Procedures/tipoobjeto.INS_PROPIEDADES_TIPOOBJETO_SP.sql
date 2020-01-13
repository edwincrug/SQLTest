CREATE PROCEDURE [tipoobjeto].[INS_PROPIEDADES_TIPOOBJETO_SP]
	@idClase			varchar(13) = NULL ,
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
			@VC_ThrowMessage	VARCHAR(100)	= 'An error has occured on [INS_PROPIEDADES_TIPOOBJETO_SP]:',
			@VC_ErrorSeverity	INT = 0,
			@VC_ErrorState		INT = 0,
			@status				int = 0,
			@propiedadId		int = 0


	IF EXISTS(SELECT * FROM ( SELECT [idPropiedadClase] ,[valor] ,'clase'AS prop, activo
									FROM [Partida].[tipoobjeto].[PropiedadClase]
								  UNION ALL
									SELECT [idPropiedadGeneral] ,[valor] ,'general', activo
									FROM [Partida].[tipoobjeto].[PropiedadGeneral]) propiedades
					WHERE LOWER(Valor) = LOWER(@valor) AND prop = @propiedad AND activo = 1)
		BEGIN
			SET @msj = 'El nombre de la propiedad de tipo ya existe';
			SET @propiedadId = (SELECT idPropiedadClase FROM ( SELECT [idPropiedadClase] ,[valor] ,'clase'AS prop
									FROM [Partida].[tipoobjeto].[PropiedadClase]
								  UNION ALL
									SELECT [idPropiedadGeneral] ,[valor] ,'general'
									FROM [Partida].[tipoobjeto].[PropiedadGeneral]) propiedades
							WHERE LOWER(Valor) = LOWER(@valor))
		END
	ELSE
		BEGIN TRY
			BEGIN TRANSACTION INS_PROPIEDADES_TIPOOBJETO_SP
						IF @propiedad = 'general'
				BEGIN
				INSERT INTO [tipoobjeto].[PropiedadGeneral]
				VALUES
					(CASE WHEN (@idPadre = 0) THEN NULL
							ELSE @idPadre
							END
					,@idTipoValor
					,@idTipoDato
					,CASE WHEN (@idPadre = 0) THEN @valor
						ELSE (SELECT TOP 1 agrupador FROM [tipoobjeto].[PropiedadGeneral] WHERE idPropiedadGeneral = @idPadre)
						END
					,@valor
					,@obligatorio
					,@orden
					,@activo
					,@posicion)

				set @status = 1;
				SET @propiedadId = SCOPE_IDENTITY();
				SET @msj = 'La propiedad se agrego correctamente.';
				END 
						IF @propiedad = 'clase'
				BEGIN
				INSERT INTO [tipoobjeto].[PropiedadClase]
				VALUES
					(@idClase
					,CASE WHEN (@idPadre = 0) THEN NULL
							ELSE @idPadre
							END
					,@idTipoValor
					,@idTipoDato
					,CASE WHEN (@idPadre = 0) THEN @valor
						ELSE (SELECT TOP 1 agrupador FROM [tipoobjeto].[PropiedadClase] WHERE idPropiedadClase = @idPadre)
						END
					,@valor
					,@obligatorio
					,@orden
					,@posicion
					,@activo
					,@idUsuario)
				set @status = 1;
				SET @propiedadId = SCOPE_IDENTITY();
				SET @msj = 'La propiedad se agrego correctamente.';
				END 

			COMMIT TRANSACTION INS_PROPIEDADES_TIPOOBJETO_SP
		END TRY
		BEGIN CATCH
			SELECT  
				@VC_ErrorMessage	= ERROR_MESSAGE(),
				@VC_ErrorSeverity	= ERROR_SEVERITY(),
				@VC_ErrorState		= ERROR_STATE();
			BEGIN
				ROLLBACK TRANSACTION INS_PROPIEDADES_TIPOOBJETO_SP
				SET @msj = 'Error al registar la propiedad de tipo.';
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
