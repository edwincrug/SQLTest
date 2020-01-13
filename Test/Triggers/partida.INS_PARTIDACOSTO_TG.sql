
CREATE TRIGGER [partida].[INS_PARTIDACOSTO_TG] 
   ON  [partida].[PartidaCosto]
   AFTER INSERT
AS 

BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@idPartida			INT,
		@idTipoCobro		VARCHAR(10), 
		@IdClase			VARCHAR(10), 
		@idUsuario			INT,
		@VC_ThrowTable		VARCHAR(300) = ''

	SELECT TOP 1 @idPartida=idPartida, @idTipoCobro= idTipoCobro, @IdClase=IdClase, @idUsuario = idUsuario 
	FROM inserted

	BEGIN TRANSACTION
	BEGIN TRY
				SET @VC_ThrowTable = '[Cliente].[integridad].[PartidaCosto]';
		INSERT INTO
		[Cliente].[integridad].[PartidaCosto] 
		VALUES (@idPartida, @idTipoCobro, @idClase)
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
	END CATCH

END
GO
