CREATE FUNCTION [partida].[SEL_PROPIEDADTIPOOBJETO_FN]
(
@idClase VARCHAR(10),
@agrupador VARCHAR(250),
@idTipoObjeto INT

)
RETURNS VARCHAR(250)
AS	

BEGIN
	DECLARE @ret VARCHAR(250)='fsdf'

	select @ret=prc.valor
		from partida.tipoobjeto.TipoObjeto pto 
	inner join partida.tipoobjeto.TipoObjetoPropiedadClase tpc on tpc.idTipoObjeto = pto.idTipoObjeto
	inner join partida.tipoobjeto.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase
	where pto.idClase	=	@idClase
	and agrupador		=	@agrupador
	and pto.activo		=	1
	and pto.idTipoObjeto=	@idTipoObjeto

	return @ret

END
GO
