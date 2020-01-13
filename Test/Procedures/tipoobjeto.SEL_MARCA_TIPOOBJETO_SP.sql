CREATE  PROCEDURE [tipoobjeto].[SEL_MARCA_TIPOOBJETO_SP] 
	@idUsuario	int,
	@idClase NVARCHAR(250),
	@err nvarchar(500) OUTPUT
AS
BEGIN
	SET @err = '';

		DECLARE @data table (
		id int,
		idPadre int,
		valor varchar(max),
		arreglo varchar(max),
		idClase varchar(max),
		idTipoValor  varchar(max),
		idTipoDato  varchar(max),
		propiedad  varchar(max),
		idPropuedad int,
		obligatorio bit,
		posicion int,
		orden int,
		idTipoObjeto int
	);

	INSERT INTO @data
		SELECT 
			CASE WHEN isnull(tp.idTipoObjeto,0)=0 THEN
				pc.idPropiedadClase	
			ELSE
				tp.idTipoObjeto
			END as id
			,ISNULL(pc.idPadre,0)	 as idPadre,
			CASE WHEN isnull(tp.idTipoObjeto,0)=0 THEN
				pc.valor
			ELSE
				Partida.[tipoobjeto].[SEL_TIPOOBJETO_ALIAS_FN](tp.idTipoObjeto)
			END as valor
			,'' as arreglo
			,pc.idClase
			,pc.idTipoValor
			,pc.idTipoDato
			,'clase' propiedad
			,2 idPropiedad
			,pc.obligatorio
			,pc.posicion
			,pc.orden
			,tp.idTipoObjeto
		FROM [tipoobjeto].[PropiedadClase] AS pc
		LEFT JOIN [tipoobjeto].[TipoObjetoPropiedadClase] AS tp ON tp.idPropiedadClase = pc.idPropiedadClase
		LEFT JOIN [tipoobjeto].[TipoObjeto] AS tob ON tob.idTipoObjeto = tp.idTipoObjeto
		WHERE pc.idClase = @idClase AND (agrupador = 'Marca' OR agrupador = 'Submarca') 
		AND isnull(tob.activo,1) = 1
		order by Id;

		SELECT * FROM @data
			WHERE 
				idPadre = (SELECT id FROM @data WHERE idPadre = 0) or idPadre = 0 or isnull(idTipoObjeto,0) != 0 
		;

end

GO
