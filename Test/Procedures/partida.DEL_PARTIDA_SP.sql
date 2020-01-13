CREATE  PROCEDURE [partida].[DEL_PARTIDA_SP] 
@data					XML,
@idUsuario				INT,
@idClase				VARCHAR(10),
@err				    NVARCHAR(500) OUTPUT
AS
BEGIN
	
	DECLARE @idPartida	AS INT
    DECLARE @tbl_propiedades AS TABLE(
        idPartida			INT
    )


    INSERT INTO @tbl_propiedades
    SELECT
        I.N.value('.','int')
        FROM @data.nodes('/Ids/idPartida') AS I(N)



	UPDATE partida.Partida 
	SET activo = 0 
	WHERE idPartida in (SELECT idPartida 
							FROM @tbl_propiedades)
	AND idClase = @idClase

END
GO
