
CREATE TRIGGER [partida].[DEL_TIPOCOBRO_TG] 
   ON  [partida].[TipoCobro]
   AFTER DELETE
AS 

BEGIN
	SET NOCOUNT ON;
	DECLARE @idTipoCobro		VARCHAR(13),
			@idClase			VARCHAR(10),
			@IdUsuario			INT,
			@VC_ThrowTable		VARCHAR(300) = ''

	SELECT TOP 1 @idTipoCobro=idTipoCobro, @idClase=idClase, @IdUsuario = IdUsuario FROM DELETED
	
	BEGIN TRANSACTION
	BEGIN TRY

				SET @VC_ThrowTable = '[Cliente].[integridad].[TipoCobro]';
		DELETE FROM [Cliente].[integridad].[TipoCobro]
		WHERE idTipoCobro =  @idTipoCobro
		AND idClase = @idClase

				SET @VC_ThrowTable = '[Proveedor].[integridad].[TipoCobro]';
		DELETE FROM [Proveedor].[integridad].[TipoCobro]
		WHERE idTipoCobro =  @idTipoCobro
		AND idClase = @idClase

	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
	END CATCH


END
GO
