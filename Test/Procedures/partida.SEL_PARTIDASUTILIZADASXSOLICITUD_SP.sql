CREATE PROCEDURE partida.SEL_PARTIDASUTILIZADASXSOLICITUD_SP
	@idSolicitud INT,
	@numeroContrato VARCHAR(50),
	@idCliente INT,
	@idClase VARCHAR(10),
	@idUsuario INT = NULL,
	@err VARCHAR(MAX) = NULL OUTPUT
AS

BEGIN
	SELECT idSolicitud
		, idPartida
		, SUM(cantidad) AS total
	FROM Solicitud.solicitud.SolicitudCotizacionPartida
	WHERE idSolicitud = @idSolicitud
	AND numeroContrato = @numeroContrato
	AND idCliente = @idCliente
	AND idClase = @idClase
	GROUP BY idSolicitud, idPartida 
END
GO
