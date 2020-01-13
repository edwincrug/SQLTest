CREATE PROCEDURE [tipoobjeto].[SEL_PROPERTYLISTBYORDER_SP]
	@ClassType			NVARCHAR(20),
	@OrderId			INT,
	@err				NVARCHAR(500) OUTPUT
AS

BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE @VI_ZERO	INT = 0,
			@VI_ONE		INT = 1,
			@VI_TWO		INT = 2

	;WITH [ObjectTypeCTE] AS (
																																						SELECT 
			 [PC].[idPropiedadClase] AS [id]
			,ISNULL([PC].[idPadre], @VI_ZERO) AS [idPadre]
			,[PC].[valor]
			,'' AS [arreglo]
			,'' AS [idClase]
			,[PC].[idTipoValor]
			,[PC].[idTipoDato]
			,'general' AS [propiedad]
			,@VI_TWO AS [idPropiedad]
			,[PC].[obligatorio]
			,[PC].[posicion]
			,[PC].[orden]
		FROM [tipoobjeto].[PropiedadClase]  AS [PC]
		WHERE 
			[PC].[idClase] = @ClassType 
			AND [PC].[activo] = @VI_ONE
	)
	SELECT
		 [CTE].[id]
		,[CTE].[idPadre]
		,[CTE].[valor]
		,[CTE].[arreglo]
		,[CTE].[idClase]
		,[CTE].[idTipoValor]
		,[CTE].[idTipoDato]
		,[CTE].[propiedad]
		,[CTE].[idPropiedad]
		,[CTE].[obligatorio]
		,[CTE].[posicion]
		,[CTE].[orden]
	FROM [ObjectTypeCTE] AS [CTE]
	INNER JOIN [Cliente].[contrato].[TipoUnidades] AS [TU]
		ON [TU].[idTipoObjeto] = [CTE].[id] 
	WHERE [CTE].[idTipoValor] = 'Agrupador'

	SET NOCOUNT OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END
GO
