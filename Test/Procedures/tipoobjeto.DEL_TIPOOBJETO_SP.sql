CREATE  PROCEDURE [tipoobjeto].[DEL_TIPOOBJETO_SP] 
@data					XML,
@idUsuario				INT,
@idClase				VARCHAR(10),
@err				    NVARCHAR(500) OUTPUT
AS
BEGIN
	
	DECLARE @idTipoObjeto	AS INT
    DECLARE @tbl_propiedades AS TABLE(
        idTipoObjeto			INT
    )


    INSERT INTO @tbl_propiedades
    SELECT
        I.N.value('.','int')
        FROM @data.nodes('/Ids/idTipoObjeto') AS I(N)

	UPDATE tipoobjeto.tipoObjeto 
	SET activo = 0 
	WHERE idTipoObjeto in (SELECT idTipoObjeto 
							FROM @tbl_propiedades)
	AND idClase = @idClase

END
GO
