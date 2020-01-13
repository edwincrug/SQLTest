
CREATE TRIGGER [partida].[INS_TIPOCOBRO_TG] 
   ON  [partida].[TipoCobro]
   AFTER INSERT
AS 

BEGIN
	SET NOCOUNT ON;
	DECLARE @idTipoCobro		VARCHAR(13),
			@idClase			VARCHAR(10),
			@IdUsuario			INT,
			@VC_ThrowTable		VARCHAR(300) = ''

	SELECT TOP 1 @idTipoCobro=idTipoCobro, @idClase=idClase, @IdUsuario = IdUsuario FROM inserted
	
	BEGIN TRANSACTION;
	BEGIN TRY

				SET @VC_ThrowTable = '[Cliente].[integridad].[TipoCobro]';
		INSERT INTO [Cliente].[integridad].[TipoCobro] 
		VALUES(@idTipoCObro, @idClase)
				SET @VC_ThrowTable = '[Proveedor].[integridad].[TipoCobro]';
		insert into [Proveedor].[integridad].[TipoCobro] 
		VALUES(@idTipoCObro, @idClase)

	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
	END CATCH

END
GO
