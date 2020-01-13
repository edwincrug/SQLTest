
CREATE  PROCEDURE [partida].[INS_PARTIDA_CLONAR_SP] 
@xmlPartidas			XML,
@xmlTiposObjetos		XML,
@idUsuario				INT,
@idClase				VARCHAR(10),
@err				    NVARCHAR(500) OUTPUT
AS

BEGIN 
	BEGIN TRANSACTION

		DECLARE @tbl_idPartidas AS TABLE(
				_row                    INT IDENTITY(1,1),
				idPartida				INT
			)

		DECLARE @tbl_idTipoObjetos AS TABLE(
				_row                    INT IDENTITY(1,1),
				idTipoObjeto			INT
			)

	
		INSERT INTO @tbl_idPartidas
		SELECT
		idPartidasValues.col.value('idPartida[1]','int')
		FROM @xmlPartidas.nodes('propiedadesPartidas/ids') AS idPartidasValues(col)


	

		INSERT INTO @tbl_idTipoObjetos
		SELECT
		idTiposObjetosValues.col.value('idTipoObjeto[1]','int')
		FROM @xmlTiposObjetos.nodes('propiedadesTiposObjetos/ids') AS idTiposObjetosValues(col)

				
		DECLARE @contTipoObjeto INT = 1
	
	

		WHILE ((SELECT COUNT (*) FROM @tbl_idTipoObjetos) >= @contTipoObjeto)
			BEGIN
				DECLARE @idTipoObjeto	INT

				SELECT @idTipoObjeto = idTipoObjeto 
				FROM @tbl_idTipoObjetos 
				WHERE _row = @contTipoObjeto

				
				DECLARE @contPartida INT = 1

	
				WHILE ((SELECT COUNT(*) FROM @tbl_idPartidas) >= @contPartida)
					BEGIN
						DECLARE @idPartida			INT,
								@idPartidaNueva		INT,
								@partida			VARCHAR(MAX)

						SELECT @idPartida = idPartida 
						FROM @tbl_idPartidas
						WHERE _row =  @contPartida

						
			SELECT 
				@partida = valor 
			from partida.PartidaPropiedadGeneral 
			WHERE  idPropiedadGeneral = 1 
			AND idPartida = @idPartida

						IF NOT EXISTS(SELECT * from partida.PartidaPropiedadGeneral PG
										INNER JOIN partida.partida P ON P.idPartida = PG.idPartida
										 WHERE PG.idTipoObjeto = @idTipoObjeto
										 AND PG.valor = @partida
										 AND P.activo = 1
										 AND idPropiedadGeneral = 1)
							BEGIN


			
								INSERT INTO partida.partida
								SELECT
								@idTipoObjeto,
								@idClase,
								1,
								@idUsuario

								SET @idPartidaNueva = @@IDENTITY

			
								INSERT INTO partida.PartidaPropiedadGeneral
								SELECT
								@idPartidaNueva,
								@idTipoObjeto,
								idClase,
								idPropiedadGeneral,
								valor,
								fechaCaducidad,
								@idUsuario
								FROM partida.PartidaPropiedadGeneral
								WHERE idPartida = @idPartida
								and idClase = @idClase

			
								INSERT INTO partida.PartidaPropiedadClase
								SELECT
								@idPartidaNueva,
								@idTipoObjeto,
								idClase,
								idPropiedadClase,
								valor,
								fechaCaducidad,
								@idUsuario
								FROM partida.PartidaPropiedadClase
								WHERE idPartida = @idPartida
								and idClase = @idClase

			
								INSERT INTO partida.PartidaPropiedadContrato
								SELECT
								@idPartidaNueva,
								@idTipoObjeto,
								idClase,
								idPropiedadContrato,
								rfcEmpresa,
								idCliente,
								numeroContrato,
								valor,
								fechaCaducidad,
								@idUsuario
								FROM partida.PartidaPropiedadContrato
								WHERE idPartida = @idPartida
								and idClase = @idClase



											
								INSERT INTO [partida].[TipoSolicitud] (
									idPartida,
									idTipoObjeto,
									idClase,
									idTipoSolicitud,
									idUsuario		            
								)
								SELECT 
									@idPartidaNueva,
									idTipoObjeto,
									idClase,
									idTipoSolicitud,
									idUsuario
								FROM [partida].[TipoSolicitud]
								where idPartida = @idPartida
																																																																																																																															END

						SET @contPartida = @contPartida + 1
					END

				SET @contTipoObjeto = @contTipoObjeto + 1
			END
	COMMIT
END 

GO
