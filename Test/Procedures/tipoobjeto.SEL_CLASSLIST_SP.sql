CREATE PROCEDURE [tipoobjeto].[SEL_CLASSLIST_SP]
	@Class		VARCHAR(10) = '',
	@Type		VARCHAR(10) = ''
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	SELECT
		  [PC].[idPropiedadClase]
		, [PC].[idPadre]
		, [PC].[idTipoValor]
		, [PC].[idTipoDato]
		, [PC].[agrupador]
		, [PC].[valor]
		, [PC].[orden]
		, [PC].[activo]
		, [PC].[obligatorio]
	 FROM [tipoobjeto].[PropiedadClase]  AS [PC]
	 WHERE 
		[PC].[idClase] = @Class AND
		[PC].[idTipoValor] = @Type


  	SET NOCOUNT OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END
GO
