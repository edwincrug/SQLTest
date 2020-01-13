
CREATE TRIGGER [partida].[UPD_TIPOCOBRO_TG] 
   ON  [partida].[TipoCobro]
   AFTER UPDATE
AS 

BEGIN
	SET NOCOUNT ON;

	DECLARE @idTipoCobro		VARCHAR(13),
			@idClase			VARCHAR(10),
			@IdUsuario			INT,

			@idTipoCobroDel		VARCHAR(13),
			@idClaseDel			VARCHAR(10),

			@VC_ThrowTable		VARCHAR(300) = ''

	SELECT TOP 1 @idTipoCobro=idTipoCobro, @idClase= idClase, @IdUsuario = IdUsuario FROM inserted
	SELECT TOP 1 @idTipoCobroDel = idTipoCobro, @idClaseDel = idClase FROM deleted

	BEGIN TRANSACTION 
	BEGIN TRY 
		
				SET @VC_ThrowTable = '[Cliente].[integridad].[TipoCobro]';
		UPDATE [Cliente].[integridad].[TipoCobro]
		SET idTipoCobro =  @idTipoCobro,
		idClase =  @idClase
		WHERE idTipoCobro = @idTipoCobroDel
		AND idClase = @idClaseDel

				SET @VC_ThrowTable = '[Proveedor].[integridad].[TipoCobro]';
		UPDATE [Proveedor].[integridad].[TipoCobro]
		SET idTipoCobro =  @idTipoCobro,
		idClase =  @idClase
		WHERE idTipoCobro = @idTipoCobroDel
		AND idClase = @idClaseDel

	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
	END CATCH


END
GO
