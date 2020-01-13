CREATE  PROCEDURE [partida].[DEL_PARTIDACONTRATO_SP] 
@data					XML,
@idUsuario				INT,
@idClase				VARCHAR(10),
@numeroContrato			VARCHAR(50),
@idCliente				INT,
@rfc					VARCHAR(13),
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

	UPDATE partida.PartidaContrato 
	SET activo = 0 
	WHERE idPartidaContrato in (SELECT idPartida 
							FROM @tbl_propiedades)
	AND idClase = @idClase
	AND numeroContrato = @numeroContrato
	AND rfcEmpresa = @rfc
	AND idCliente = @idCliente

END
GO
