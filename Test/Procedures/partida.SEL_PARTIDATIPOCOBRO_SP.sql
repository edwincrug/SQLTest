CREATE PROCEDURE [partida].[SEL_PARTIDATIPOCOBRO_SP]
@idClase            varchar(250),
@idUsuario			int,
@err				nvarchar(500) = '' OUTPUT

AS

BEGIN
	SELECT idTipoCobro, nombre, descripcion FROM partida.tipocobro where idClase = @idClase and activo = 1
END
GO
