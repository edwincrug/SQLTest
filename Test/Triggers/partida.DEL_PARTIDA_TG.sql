
CREATE TRIGGER [partida].[DEL_PARTIDA_TG] 
   ON  [partida].[Partida]
   AFTER DELETE
AS	

BEGIN
		DECLARE @IdUsuario			INT,
			@idPartida			INT,
			@idTipoObjeto		INT,
			@idClase			VARCHAR(10),
			@VC_ThrowTable		VARCHAR(300) = '';


	SELECT TOP 1 @idPartida=idPartida,@idTipoObjeto=idTipoObjeto,@idClase=idClase, @IdUsuario = IdUsuario FROM DELETED
	BEGIN TRANSACTION
		BEGIN TRY 
						SET @VC_ThrowTable = '[Cliente].[integridad].[Partida]';
			DELETE FROM [Cliente].[integridad].[Partida]
			WHERE idPartida		=  @idPartida
			AND idTipoObjeto	=  @idTipoObjeto
			AND idClase			=  @idClase

						SET @VC_ThrowTable = '[Proveedor].[integridad].[Partida]';
			DELETE FROM [Proveedor].[integridad].[Partida]
			WHERE idPartida		=  @idPartida
			AND idTipoObjeto	=  @idTipoObjeto
			AND idClase			=  @idClase

						SET @VC_ThrowTable = '[solicitud].[integridad].[Partida]';
			DELETE FROM [solicitud].[integridad].[Partida] 
			WHERE idPartida		=  @idPartida
			AND idTipoObjeto	=  @idTipoObjeto
			AND idClase			=  @idClase

			COMMIT TRANSACTION;

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION;
			EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
		END CATCH
END
GO
