CREATE  PROCEDURE [partida].[INS_TIPOSOLICITUDPARTIDA_SP] 
@idPartida				INT,
@idTipoObjeto			INT,
@idClase				varchar(10),
@idUsuario				int,
@idTipoSolicitud		xml,
@err				    NVARCHAR(500) = NULL OUTPUT
AS
BEGIN TRY
	BEGIN TRANSACTION
	DECLARE
		@VI_One				INT = 1,
		@VI_Zero			INT = 0,
		@VC_ErrorMessage	VARCHAR(4000)	= '',
		@VC_ThrowMessage	VARCHAR(100)	= 'Ocurrio un error en el stored: [INS_TIPOSOLICITUD_SP]:',
		@VC_ErrorSeverity	INT = 0,
		@VC_ErrorState		INT = 0,
		@VI_ResultCount		INT = 0,
		@VI_Result			BIT = 0
	DECLARE @temTipoSolicitud TABLE (
			idPartida INT,
			idTipoObjeto INT,
			idClase VARCHAR(10),
			idTipoSolicitud VARCHAR(10),
			idUsuario INT			            
        )
        INSERT INTO @temTipoSolicitud (
			idPartida,
			idTipoObjeto,
			idClase,
			idTipoSolicitud,
			idUsuario		            
        )
        SELECT @idPartida,
			   @idTipoObjeto,
			   @idClase,
			   ParamValues.col.value('idTipoSolicitud[1]','VARCHAR(10)'),
			   @idUsuario
        FROM @idTipoSolicitud.nodes('/solicitudes') AS ParamValues(col)
        MERGE [partida].[TipoSolicitud] AS TARGET
        USING  @temTipoSolicitud AS SOURCE
        ON TARGET.idPartida = SOURCE.idPartida
        AND TARGET.idTipoObjeto = SOURCE.idTipoObjeto
        AND TARGET.idClase = SOURCE.idClase
        AND TARGET.idTipoSolicitud = SOURCE.idTipoSolicitud
                                WHEN NOT MATCHED BY TARGET THEN
            INSERT (
				idPartida,
				idTipoObjeto,
				idClase,
				idTipoSolicitud,
				idUsuario
				)
            VALUES (
			idPartida,
			idTipoObjeto,
			idClase,
			idTipoSolicitud,
			idUsuario
			)
        WHEN NOT MATCHED BY SOURCE 
		AND TARGET.idPartida = @idPartida 
		THEN DELETE;
	COMMIT
	END TRY
	
	BEGIN CATCH
				
		ROLLBACK TRANSACTION
				
	END CATCH




GO
