CREATE  PROCEDURE [tipoobjeto].[SEL_PROPIEDAD_ALL_SP] 
	@idClase			nvarchar(250) ,
	@idUsuario			INT,	
	@err				nvarchar(500) OUTPUT
AS
BEGIN

DECLARE @propiedades AS TABLE(
								id				INT,
								idPadre			INT,
								valor			NVARCHAR(500),
								arreglo			NVARCHAR(500),
								idClase			NVARCHAR(500),
								idTipoValor		NVARCHAR(20),
								idTipoDato		NVARCHAR(20),
								propiedad		NVARCHAR(50),
								idPropiedad		INT,
								obligatorio		BIT,
								posicion		INT,
								orden			INT
															)

	INSERT INTO @propiedades
	SELECT 
		idPropiedadGeneral	as id
		,ISNULL(idPadre,0)	 as idPadre
		,valor	
		,'' as arreglo
		,'' idClase
		,idTipoValor
		,idTipoDato
		,'general' propiedad
		,1 idPropiedad
		,obligatorio
		,posicion
		,orden
	FROM
	[tipoobjeto].[PropiedadGeneral] 
	WHERE 
	activo=1

	UNION ALL

		
	SELECT 
		idPropiedadClase	as id
		,ISNULL(idPadre,0)	 as idPadre
		,valor	
		,'' as arreglo
		,idClase
		,idTipoValor
		,idTipoDato
		,'clase' propiedad
		,2 idPropiedad
		,obligatorio
		,posicion
		,orden
	FROM [tipoobjeto].[PropiedadClase] 
	WHERE idClase = @idClase 
	AND	activo=1

	SELECT * FROM @propiedades
	ORDER BY idClase,posicion, orden asc

		
END

GO
