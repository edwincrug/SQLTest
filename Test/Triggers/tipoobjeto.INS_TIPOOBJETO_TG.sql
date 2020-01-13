
CREATE TRIGGER [tipoobjeto].[INS_TIPOOBJETO_TG] 
   ON  [tipoobjeto].[TipoObjeto]
   AFTER INSERT
AS 

BEGIN
	SET NOCOUNT ON;
	DECLARE @idClase			VARCHAR(10),
			@idTipoObjeto		INT,
			@IdUsuario			INT,
			@VC_ThrowTable		VARCHAR(300) = ''

	SELECT TOP 1 @idClase= idClase, @idTipoObjeto= idTipoObjeto, @IdUsuario = IdUsuario FROM inserted

	BEGIN TRANSACTION;
	BEGIN TRY

						SET @VC_ThrowTable = '[Cliente].[integridad].[TipoObjeto]';
		insert into [Cliente].[integridad].[TipoObjeto] 
		VALUES(@idClase, @idTipoObjeto)

				SET @VC_ThrowTable = '[Objeto].[integridad].[TipoObjeto]';
		insert into [Objeto].[integridad].[TipoObjeto] 
		VALUES(@idClase, @idTipoObjeto)

				SET @VC_ThrowTable = '[Solicitud].[integridad].[TipoObjeto] ';
		insert into [Solicitud].[integridad].[TipoObjeto] 
		VALUES( @idTipoObjeto, @idClase)

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
	END CATCH
END
GO
