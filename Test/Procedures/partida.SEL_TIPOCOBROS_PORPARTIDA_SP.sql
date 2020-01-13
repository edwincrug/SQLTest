CREATE PROCEDURE [partida].[SEL_TIPOCOBROS_PORPARTIDA_SP] 
	@idPartida				INT,
	@idClase				VARCHAR(10),
	@idUsuario				INT,
	@err				    NVARCHAR(500) OUTPUT
AS
BEGIN
	SELECT costo, PC.idTipoCobro, PC.idPartida, TP.nombre, TP.descripcion FROM partida.PartidaCosto PC
		INNER JOIN partida.TipoCobro TP ON PC.idTipoCobro = TP.idTipoCobro AND PC.idClase = TP.idClase
		WHERE PC.idPartida = @idPartida AND PC.idClase = @idClase
	SELECT 
		PTS.[idPartida],
		PTS.[idTipoObjeto],
		PTS.[idClase],
		PTS.[idTipoSolicitud],
		PTS.[idUsuario],
		TS.nombre
	FROM [partida].[TipoSolicitud] PTS
	INNER JOIN [Solicitud].[solicitud].[TipoSolicitud] TS ON
	TS.idTipoSolicitud = PTS.idTipoSolicitud
	WHERE PTS.[idPartida] = @idPartida
END
GO
