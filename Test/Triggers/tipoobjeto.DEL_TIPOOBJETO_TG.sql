
CREATE TRIGGER [tipoobjeto].[DEL_TIPOOBJETO_TG] 
   ON  [tipoobjeto].[TipoObjeto]
   AFTER DELETE
AS 

BEGIN
	SET NOCOUNT ON;

	DECLARE @idClase			VARCHAR(10),
			@idTipoObjeto		INT,
			@IdUsuario			INT,
			@VC_ThrowTable		VARCHAR(300) = ''

	SELECT TOP 1 @idClase= idClase, @idTipoObjeto= idTipoObjeto, @IdUsuario = IdUsuario FROM deleted

	BEGIN TRANSACTION
	BEGIN TRY 
		
				SET @VC_ThrowTable = '[Cliente].[integridad].[TipoObjeto]';
		DELETE FROM [Cliente].[integridad].[TipoObjeto]
		WHERE idClase = @idClase
		AND idTipoObjeto =  @idTipoObjeto

				SET @VC_ThrowTable = '[Objeto].[integridad].[TipoObjeto]';
		DELETE FROM [Objeto].[integridad].[TipoObjeto]
		WHERE idClase = @idClase
		AND idTipoObjeto =  @idTipoObjeto

				SET @VC_ThrowTable = '[Solicitud].[integridad].[TipoObjeto] ';
		DELETE FROM [solicitud].[integridad].[TipoObjeto] 
		WHERE idClase = @idClase
		AND idTipoObjeto =  @idTipoObjeto

	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
	END CATCH


END
GO
