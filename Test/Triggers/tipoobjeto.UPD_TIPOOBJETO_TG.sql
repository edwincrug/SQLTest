
CREATE TRIGGER [tipoobjeto].[UPD_TIPOOBJETO_TG] 
   ON  [tipoobjeto].[TipoObjeto]
   AFTER UPDATE
AS 

BEGIN
	SET NOCOUNT ON;

	DECLARE @idClase			VARCHAR(10),
			@idTipoObjeto		INT,
			@IdUsuario			INT,

			@idClaseDel			VARCHAR(10),
			@idTipoObjetoDel	INT,
			@VC_ThrowTable		VARCHAR(300) = ''

	SELECT TOP 1 @idClase= idClase, @idTipoObjeto= idTipoObjeto, @IdUsuario = IdUsuario FROM inserted
	SELECT TOP 1 @idClaseDel= idClase, @idTipoObjetoDel= idTipoObjeto  FROM deleted

	BEGIN TRANSACTION 
	BEGIN TRY 

		
				SET @VC_ThrowTable = '[Cliente].[integridad].[TipoObjeto]';
		UPDATE [Cliente].[integridad].[TipoObjeto]
		SET idClase =  @idClase,
		idTipoObjeto =  @idTipoObjeto
		WHERE idClase = @idClaseDel
		AND idTipoObjeto = @idTipoObjetoDel

				SET @VC_ThrowTable = '[Objeto].[integridad].[TipoObjeto]';
		UPDATE [Objeto].[integridad].[TipoObjeto]
		SET idClase =  @idClase,
		idTipoObjeto =  @idTipoObjeto
		WHERE idClase = @idClaseDel
		AND idTipoObjeto = @idTipoObjetoDel

				SET @VC_ThrowTable = '[Solicitud].[integridad].[TipoObjeto] ';
		UPDATE [Solicitud].[integridad].[TipoObjeto]
		SET idClase =  @idClase,
		idTipoObjeto =  @idTipoObjeto
		WHERE idClase = @idClaseDel
		AND idTipoObjeto = @idTipoObjetoDel

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
	END CATCH


END
GO
