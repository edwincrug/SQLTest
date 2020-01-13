CREATE PROCEDURE [tipoobjeto].[UPD_PROPIEDADES_TIPOOBJETO_SP]
	@idClase			varchar(13) = NULL ,
   			@idPadre			INT,
	@idPropiedad		INT,
	@idTipoDato			nvarchar(10),
	@idTipoValor		nvarchar(10),
	@obligatorio		bit,
	@orden				INT,
	@activo				bit,
	@posicion			INT,
	@propiedad			nvarchar(10),
	@valor				nvarchar(250),
	@idUsuario				int = null,
	@err					varchar(max) OUTPUT
		
AS

BEGIN
	
	DECLARE @msj		varchar(50) = '', 
			@VC_ErrorMessage	VARCHAR(4000)	= '',
			@VC_ThrowMessage	VARCHAR(100)	= 'An error has occured on [UPD_PROPIEDADES_TIPOOBJETO_SP]:',
			@VC_ErrorSeverity	INT = 0,
			@VC_ErrorState		INT = 0,
			@status		int = 0,
			@propiedadId	int = 0


	IF NOT EXISTS(SELECT * FROM ( SELECT [idPropiedadClase] ,[valor] ,'clase'AS prop
									FROM [Partida].[tipoobjeto].[PropiedadClase]
								  UNION ALL
									SELECT [idPropiedadGeneral] ,[valor] ,'general'
									FROM [Partida].[tipoobjeto].[PropiedadGeneral]) propiedades
					WHERE idPropiedadClase = @idPropiedad)
		BEGIN
			SET @msj = 'El nombre de la propiedad no existe';
			SET @propiedadId = 0
		END
	ELSE
		BEGIN TRY
			BEGIN TRANSACTION UPD_PROPIEDADES_TIPOOBJETO_SP
						IF @propiedad = 'general'
				BEGIN
					UPDATE [tipoobjeto].[PropiedadGeneral]
					   SET [idTipoValor] = @idTipoValor
						  ,[idTipoDato] = @idTipoDato
						  ,[agrupador] = CASE WHEN (@idPadre = 0) THEN @valor
							ELSE (SELECT TOP 1 agrupador FROM [tipoobjeto].[PropiedadGeneral] WHERE idPropiedadGeneral = @idPadre)
							END
						  ,[valor] = @valor
						  ,[obligatorio] = @obligatorio
						  ,[orden] = @orden
						  ,[posicion] = @posicion
						  ,[activo] = @activo
					 WHERE idPropiedadGeneral = @idPropiedad 
				set @status = 1;
				SET @propiedadId = (SELECT idPropiedadGeneral FROM [tipoobjeto].[PropiedadGeneral] WHERE idPropiedadGeneral = @idPropiedad);
				SET @msj = 'La propiedad de tipo se actualizo correctamente';
				END 
						IF @propiedad = 'clase'
				BEGIN
					UPDATE [tipoobjeto].[PropiedadClase]
					   SET [idTipoValor] = @idTipoValor
						  ,[idTipoDato] = @idTipoDato
						  ,[agrupador] = CASE WHEN (@idPadre = 0) THEN @valor
								ELSE (SELECT TOP 1 agrupador FROM [tipoobjeto].[PropiedadClase] WHERE idPropiedadClase = @idPadre)
								END
						  ,[valor] = @valor
						  ,[obligatorio] = @obligatorio
						  ,[orden] = @orden
						  ,[posicion] = @posicion
						  ,[activo] = @activo
						  ,[idUsuario] = @idUsuario
						  WHERE idPropiedadClase = @idPropiedad 
				set @status = 1;
				SET @propiedadId =  (SELECT idPropiedadClase FROM [tipoobjeto].[PropiedadClase] WHERE idPropiedadClase = @idPropiedad);
				SET @msj = 'La propiedad de tipo se actualizo correctamente';
				END

			COMMIT TRANSACTION UPD_PROPIEDADES_TIPOOBJETO_SP
		END TRY
		BEGIN CATCH
			SELECT  
				@VC_ErrorMessage	= ERROR_MESSAGE(),
				@VC_ErrorSeverity	= ERROR_SEVERITY(),
				@VC_ErrorState		= ERROR_STATE();
			BEGIN
				ROLLBACK TRANSACTION UPD_PROPIEDADES_TIPOOBJETO_SP
				SET @msj = 'Error al actualizar la propiedad de tipo';
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
		@propiedadId		AS [PropiedadId];

    SET NOCOUNT OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END
GO
