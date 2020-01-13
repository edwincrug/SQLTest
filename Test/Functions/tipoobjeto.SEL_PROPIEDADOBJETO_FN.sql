CREATE FUNCTION tipoobjeto.SEL_PROPIEDADOBJETO_FN 
(
	@idTipoObjeto INT, @idClase VARCHAR(10), @idPropiedadGeneral INT 
)
RETURNS VARCHAR(500)
AS

BEGIN
	DECLARE @valor VARCHAR(500)

	SELECT @valor = valor
	FROM tipoobjeto.TipoObjetoPropiedadGeneral
	WHERE idTipoObjeto = @idTipoObjeto
	AND idClase = @idClase
	AND idPropiedadGeneral = @idPropiedadGeneral

	RETURN @valor

END
GO
