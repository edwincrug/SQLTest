
CREATE TRIGGER [partida].[UPD_PARTIDACOSTO_TG] 
   ON  [partida].[PartidaCosto]
   AFTER UPDATE
AS 

BEGIN
	SET NOCOUNT ON;
	
	DECLARE 
		@idPartida			INT,
		@idTipoCobro		VARCHAR(10), 
		@IdClase			VARCHAR(10), 
		@idUsuario			INT,

		@idPartidaDel		INT,
		@idTipoCobroDel		VARCHAR(10), 
		@IdClaseDel			VARCHAR(10), 


		@VC_ThrowTable		VARCHAR(300) = ''

	SELECT TOP 1 @idPartida=idPartida, @idTipoCobro= idTipoCobro, @IdClase=IdClase, @idUsuario = idUsuario  FROM inserted
	SELECT TOP 1 @idPartidaDel=idPartida, @idTipoCobroDel= idTipoCobro, @IdClaseDel=IdClase FROM deleted

		BEGIN TRANSACTION 
	BEGIN TRY 
		SET @VC_ThrowTable = '[Cliente].[integridad].[PartidaCosto]';
		UPDATE [Cliente].[integridad].[PartidaCosto]
			SET idPartida =  @idPartida,
			idTipoCobro =  @idTipoCobro,
			idClase =  @IdClase
		WHERE idPartida = @idPartidaDel
			AND idTipoCobro = @idTipoCobroDel
			AND idClase = @IdClaseDel
		
	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
	END CATCH

END
GO
