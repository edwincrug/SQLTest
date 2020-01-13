CREATE FUNCTION [tipoobjeto].[SEL_TIPOOBJETO_ALIAS_FN]
(
	@idTipoObjeto int
)
RETURNS VARCHAR(500)
AS

BEGIN
	DECLARE @alias VARCHAR(500) = isnull(
	(	 SELECT TOP 1 
			PC.valor 
		FROM 
			[Partida].[tipoobjeto].[PropiedadClase] AS PC
		INNER JOIN 
			[Partida].[tipoobjeto].[TipoObjetoPropiedadClase] AS TP ON TP.idPropiedadClase = PC.idPropiedadClase
		WHERE TP.idTipoObjeto = @idTipoObjeto AND 
			  PC.agrupador ='Submarca' AND 
			  PC.activo = 1 
	),'');

	SET @alias += ' / ' + isnull(
	(	 SELECT TOP 1 
			PC.valor 
		FROM 
			[Partida].[tipoobjeto].[PropiedadClase] AS PC
		INNER JOIN 
			[Partida].[tipoobjeto].[TipoObjetoPropiedadClase] AS TP ON TP.idPropiedadClase = PC.idPropiedadClase
		WHERE TP.idTipoObjeto = @idTipoObjeto AND 
			  PC.agrupador ='Combustible' AND 
			  PC.activo = 1
	),'');


	SET @alias += ' / ' + isnull(
	(	 SELECT TOP 1 
			PC.valor 
		FROM 
			[Partida].[tipoobjeto].[PropiedadClase] AS PC
		INNER JOIN 
			[Partida].[tipoobjeto].[TipoObjetoPropiedadClase] AS TP ON TP.idPropiedadClase = PC.idPropiedadClase
		WHERE TP.idTipoObjeto = @idTipoObjeto AND 
			  PC.agrupador ='Cilindros' AND 
			  PC.activo = 1
	),'');

	RETURN @alias
END
GO
