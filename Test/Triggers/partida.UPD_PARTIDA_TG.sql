

CREATE TRIGGER [partida].[UPD_PARTIDA_TG] 
   ON  [partida].[Partida]
   AFTER UPDATE
AS 

BEGIN
		DECLARE @IdUsuario			INT,
			@idPartida			INT,
			@idTipoObjeto		INT,
			@idClase			VARCHAR(10),
			@idPartidaDel		INT,
			@idTipoObjetoDel	INT,
			@idClaseDel			VARCHAR(10),
			@VC_ThrowTable		VARCHAR(300) = '';


	SELECT TOP 1 @idPartida=idPartida,@idTipoObjeto=idTipoObjeto,@idClase=idClase, @IdUsuario = IdUsuario FROM INSERTED
	SELECT TOP 1 @idPartidaDel=idPartida,@idTipoObjetoDel=idTipoObjeto,@idClaseDel=idClase, @IdUsuario = IdUsuario FROM DELETED
	BEGIN TRANSACTION
		BEGIN TRY 
						SET @VC_ThrowTable = '[Cliente].[integridad].[Partida]';
			UPDATE	[Cliente].[integridad].[Partida]
			SET		idPartida		=	@idPartida,
					idTipoObjeto	=	@idTipoObjeto,
					idClase			=	@idClase
			WHERE	idPartida		=	@idPartidaDel
			AND		idTipoObjeto	=	@idTipoObjetoDel
			AND		idClase			=	@idClaseDel

						SET @VC_ThrowTable = '[Proveedor].[integridad].[Partida]';
			UPDATE	[Proveedor].[integridad].[Partida]
			SET		idPartida		=	@idPartida,
					idTipoObjeto	=	@idTipoObjeto,
					idClase			=	@idClase
			WHERE	idPartida		=	@idPartidaDel
			AND		idTipoObjeto	=	@idTipoObjetoDel
			AND		idClase			=	@idClaseDel

						SET @VC_ThrowTable = '[Solicitud].[integridad].[Partida]';
			UPDATE  [Solicitud].[integridad].[Partida]
			SET		idPartida		=	@idPartida,
					idTipoObjeto	=	@idTipoObjeto,
					idClase			=	@idClase
			WHERE	idPartida		=	@idPartidaDel
			AND		idTipoObjeto	=	@idTipoObjetoDel
			AND		idClase			=	@idClaseDel
			
			COMMIT TRANSACTION;
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION;
			EXECUTE [Common].[log].[INS_Trigger_Error_SP] @VC_ThrowTable, @IdUsuario
		END CATCH
END
GO
