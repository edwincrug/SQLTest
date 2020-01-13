CREATE FUNCTION [tipoobjeto].[SEL_TIPOOBJETO_NOMBRE_FN]
(
	@idObjeto INT,
	@propiedad	VARCHAR(50),
	@idClase	VARCHAR(50)
)
RETURNS VARCHAR(500)
AS

BEGIN
	DECLARE 
		@VC_RESULT VARCHAR(500) = ''

	;WITH [TipoObjetoCET] AS(
		SELECT
			isnull(prc.valor,'')			valor,
			prc.idPadre						idPadre,
			prc.orden						orden,
			prc.posicion					posicion,
			1								ordenFinal
		FROM tipoobjeto.TipoObjeto tob
		inner join tipoobjeto.TipoObjetoPropiedadClase tpc on tob.idTipoObjeto = tpc.idTipoObjeto
		inner join tipoobjeto.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase
		WHERE 
			prc.idTipoValor in ('Catalogo','Agrupador')
			and tob.idClase = @idClase
			and tob.activo = 1
			and prc.agrupador = @propiedad
			and tob.idTipoObjeto = @idObjeto
		UNION ALL
		SELECT
			isnull(prc.valor,'')			valor,
			prc.idPadre						idPadre,
			prc.orden						orden,
			prc.posicion					posicion,
			1								ordenFinal
		FROM tipoobjeto.PropiedadClase prc 
		inner join [TipoObjetoCET] cat on cat.idPadre = prc.idPropiedadClase 
		WHERE prc.activo = 1 
	)
	SELECT @VC_RESULT = STUFF((SELECT  '/' + CAST(valor AS VARCHAR(10))
	FROM [TipoObjetoCET] AS p 
	WHERE p.idPadre is not null order by p.ordenFinal, p.posicion, p.orden FOR XML PATH('')),1,1,'') 

	RETURN @VC_RESULT;
END
GO
