CREATE  PROCEDURE [partida].[SEL_PROPIEDAD_ALL_SP] 
	@idClase			VARCHAR(10),
	@idCliente			INT,
	@numeroContrato		NVARCHAR(100),
	@idUsuario			INT,
	@err				NVARCHAR(500) OUTPUT
AS
BEGIN


DECLARE @propiedades AS TABLE(
								id				INT,
								idPadre			INT,
								valor			NVARCHAR(500),
								arreglo			NVARCHAR(500),
								idClase			NVARCHAR(500),
								idContrato		NVARCHAR(500),
								idTipoValor		NVARCHAR(20),
								idTipoDato		NVARCHAR(20),
								propiedad		NVARCHAR(50),
								obligatorio		BIT,
								posicion		INT,
								orden			INT,
								ordenFinal		INT
								)

	INSERT INTO @propiedades
	SELECT 
		idPropiedadGeneral	as id
		,ISNULL(idPadre,0)	 as idPadre
		,valor	
		,'' as arreglo
		,'' idClase
		,'' idContrato
		,idTipoValor
		,idTipoDato
		,'general' propiedad
		,obligatorio
		,posicion
		,orden
		,0

	FROM
	[partida].[PropiedadGeneral] 
	WHERE ISNULL(idPadre,0) = 0
	AND activo = 1

	UNION ALL

		
	SELECT 
		idPropiedadClase	as id
		,ISNULL(idPadre,0)	 as idPadre
		,valor	
		,'' as arreglo
		,idClase
		,'' idContrato
		,idTipoValor
		,idTipoDato
		,'clase' propiedad
		,obligatorio
		,posicion
		,orden
		,1
	FROM [partida].[PropiedadClase] 
	WHERE idClase = @idClase
	AND activo = 1


	UNION ALL

	SELECT 
		idPropiedadContrato	as id
		,ISNULL(idPadre,0)	 as idPadre
		,valor	
		,'' as arreglo
		,'' idClase
		,numeroContrato
		,idTipoValor
		,idTipoDato
		,'contrato' propiedad
		,obligatorio
		,posicion
		,orden
		,2
	FROM [partida].[PropiedadContrato] 
	WHERE idCliente = @idCLiente
	AND numeroContrato = @numeroContrato
	AND activo = 1

	
	SELECT *, 'Et' as [idTipoObjeto] FROM @propiedades
	ORDER BY ordenFinal, posicion, orden  


		
END
GO
