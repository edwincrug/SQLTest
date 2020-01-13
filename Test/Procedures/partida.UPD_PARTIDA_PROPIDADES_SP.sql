CREATE PROCEDURE [partida].[UPD_PARTIDA_PROPIDADES_SP]
	@idClase			varchar(13) = NULL ,
    @idCliente			INT = 0,
	@numeroContrato		nvarchar(10) = NULL,
	@rfcEmpresa			varchar(13) = NULL ,
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
	@idUsuario				int,
	@err					varchar(max) OUTPUT
		
AS

BEGIN
	
	DECLARE @msj		varchar(50) = '', 
			@VC_ErrorMessage	VARCHAR(4000)	= '',
			@VC_ThrowMessage	VARCHAR(100)	= 'An error has occured on [UPD_PROPIEDADES]:',
			@VC_ErrorSeverity	INT = 0,
			@VC_ErrorState		INT = 0,
			@status		int = 0,
			@propiedadId	int = 0


	IF NOT EXISTS(SELECT * FROM ( SELECT [idPropiedadClase] ,[valor] ,'clase'AS prop
									FROM [Partida].[partida].[PropiedadClase]
								  UNION ALL
									SELECT [idPropiedadGeneral] ,[valor] ,'general'
									FROM [Partida].[partida].[PropiedadGeneral]
								  UNION ALL
									  SELECT [idPropiedadContrato] ,[valor] ,'contrato' 
									  FROM [Partida].[partida].[PropiedadContrato] ) propiedades
					WHERE idPropiedadClase = @idPropiedad)
		BEGIN
			SET @msj = 'El nombre de la propiedad no existe';
			SET @propiedadId = 0
		END
	ELSE
		BEGIN TRY
			BEGIN TRANSACTION UPD_PARTIDA_PROPIDADES_SP
						IF @propiedad = 'general'
				BEGIN
					UPDATE [partida].[PropiedadGeneral]
					   SET [idTipoValor] = @idTipoValor
						  ,[idTipoDato] = @idTipoDato
						  ,[agrupador] = CASE WHEN (@idPadre = 0) THEN @valor
							ELSE (SELECT TOP 1 agrupador FROM [partida].[PropiedadGeneral] WHERE idPropiedadGeneral = @idPadre)
							END
						  ,[valor] = @valor
						  ,[obligatorio] = @obligatorio
						  ,[orden] = @orden
						  ,[posicion] = @posicion
						  ,[activo] = @activo
						  ,[idUsuario] = @idUsuario
					 WHERE idPropiedadGeneral = @idPropiedad 
						 						 IF @idPadre = 0 AND ( @idTipoValor = 'Catalogo' OR @idTipoValor = 'Agrupador')
						 BEGIN
						 UPDATE [partida].[PropiedadGeneral]
						 SET 
						 [agrupador] = @valor
						 WHERE idPadre = @idPropiedad  AND agrupador != @valor
						 END

				set @status = 1;
				SET @propiedadId = (SELECT idPropiedadGeneral FROM [partida].[PropiedadGeneral] WHERE idPropiedadGeneral = @idPropiedad);
				SET @msj = 'La propiedad se actualizo correctamente';
				END 
						IF @propiedad = 'clase'
				BEGIN
					UPDATE [partida].[PropiedadClase]
					   SET [idTipoValor] = @idTipoValor
						  ,[idTipoDato] = @idTipoDato
						  ,[agrupador] = CASE WHEN (@idPadre = 0) THEN @valor
								ELSE (SELECT TOP 1 agrupador FROM [partida].[PropiedadClase] WHERE idPropiedadClase = @idPadre)
								END
						  ,[valor] = @valor
						  ,[obligatorio] = @obligatorio
						  ,[orden] = @orden
						  ,[posicion] = @posicion
						  ,[activo] = @activo
						  ,[idUsuario] = @idUsuario
						  WHERE idPropiedadClase = @idPropiedad 
						  								IF @idPadre = 0 AND ( @idTipoValor = 'Catalogo' OR @idTipoValor = 'Agrupador')
								BEGIN
								UPDATE [partida].[PropiedadClase]
								SET 
								[agrupador] = @valor
								WHERE idPadre = @idPropiedad  AND agrupador != @valor
								END
				set @status = 1;
				SET @propiedadId =  (SELECT idPropiedadClase FROM [partida].[PropiedadClase] WHERE idPropiedadClase = @idPropiedad);
				SET @msj = 'La propiedad se actualizo correctamente';
				END 
						IF @propiedad = 'contrato'
				BEGIN
					UPDATE [partida].[PropiedadContrato]
					   SET [idTipoValor] = @idTipoValor
						  ,[idTipoDato] = @idTipoDato
						  ,[agrupador] = CASE WHEN (@idPadre = 0) THEN @valor
							ELSE (SELECT TOP 1 agrupador FROM [partida].[PropiedadContrato] WHERE idPropiedadContrato = @idPadre)
							END
						  ,[valor] = @valor
						  ,[obligatorio] = @obligatorio
						  ,[orden] = @orden
						  ,[posicion] = @posicion
						  ,[activo] = @activo
						  ,[idUsuario] = @idUsuario
						  WHERE idPropiedadContrato = @idPropiedad 
						  								IF @idPadre = 0 AND ( @idTipoValor = 'Catalogo' OR @idTipoValor = 'Agrupador')
								BEGIN
								UPDATE [partida].[PropiedadContrato]
								SET 
								[agrupador] = @valor
								WHERE idPadre = @idPropiedad  AND agrupador != @valor
								END
				set @status = 1;
				SET @propiedadId =  (SELECT idPropiedadContrato FROM [partida].[PropiedadContrato] WHERE idPropiedadContrato = @idPropiedad);
				SET @msj = 'La propiedad se actualizo correctamente';
				END 

			COMMIT TRANSACTION UPD_PARTIDA_PROPIDADES_SP
		END TRY
		BEGIN CATCH
			SELECT  
				@VC_ErrorMessage	= ERROR_MESSAGE(),
				@VC_ErrorSeverity	= ERROR_SEVERITY(),
				@VC_ErrorState		= ERROR_STATE();
			BEGIN
				ROLLBACK TRANSACTION UPD_PARTIDA_PROPIDADES_SP
				SET @msj = 'Error al actualizar la propiedad';
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
