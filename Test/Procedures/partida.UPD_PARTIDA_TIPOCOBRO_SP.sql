CREATE PROCEDURE [partida].[UPD_PARTIDA_TIPOCOBRO_SP]
@idTipoObjeto			INT,
@costos                 XML,
@idClase				VARCHAR(10),
@idUsuario              int,
@err				    NVARCHAR(500) OUTPUT
AS
BEGIN

	DECLARE @tbl_costos AS TABLE(
		_row INT IDENTITY(1, 1)
		,idTipoCobro VARCHAR(10)
		,costo FLOAT
		,idPartida	INT
	)

	INSERT INTO @tbl_costos
	SELECT 
	 ParamValues.col.value('idTipoCobro[1]','varchar(10)')
	,ParamValues.col.value('costo[1]','float')
	,ParamValues.col.value('idPartida[1]','int')
	FROM @costos.nodes('tiposCostos/tipocosto') AS ParamValues(col)

		
	DECLARE @cont INT= 1;
	WHILE(@cont <= (SELECT COUNT(*) FROM @tbl_costos))
	BEGIN
		IF((SELECT COUNT(*) FROM partida.PartidaCosto WHERE idPartida = (SELECT idPartida FROM @tbl_costos WHERE _row = @cont) AND idClase = @idClase) > 0)
		BEGIN
			
			UPDATE partida.PartidaCosto
			SET costo = (SELECT costo FROM @tbl_costos WHERE _row = @cont),
			idUsuario = @idUsuario
			WHERE idPartida = (SELECT idPartida FROM @tbl_costos WHERE _row = @cont)
			AND idClase = @idClase
			AND idTipoCobro = (SELECT idTipoCobro FROM @tbl_costos WHERE _row = @cont)
		END	
		ELSE 
		BEGIN
			EXECUTE [partida].[INS_PARTIDACOSTO_SP] @costos, @idTipoObjeto, @idClase, @idUsuario, @err out
		END
		SET @cont = @cont + 1
	END	
END
GO
