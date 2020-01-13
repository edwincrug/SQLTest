
CREATE TRIGGER [partida].[INS_PARTIDA_TG] 
   ON  [partida].[Partida]
   AFTER INSERT
AS 

BEGIN
		DECLARE @IdUsuario			INT,
		@idPartida				INT,
			@idTipoObjeto		INT,
			@idClase			VARCHAR(10),
			@VC_ThrowTable		VARCHAR(300) = '';


	SELECT TOP 1 @idPartida=idPartida,@idTipoObjeto=idTipoObjeto,@idClase=idClase, @IdUsuario = IdUsuario FROM INSERTED
									SET @VC_ThrowTable = '[Cliente].[integridad].[Partida]';
			INSERT INTO [Cliente].[integridad].[Partida] VALUES(@idPartida,@idTipoObjeto,@idClase)
						SET @VC_ThrowTable = '[Proveedor].[integridad].[Partida]';
			INSERT INTO [Proveedor].[integridad].[Partida] VALUES(@idPartida,@idTipoObjeto,@idClase)
						SET @VC_ThrowTable = '[Solicitud].[integridad].[Partida]';
			INSERT INTO [Solicitud].[integridad].[Partida] VALUES(@idPartida,@idTipoObjeto,@idClase)

												END
GO
