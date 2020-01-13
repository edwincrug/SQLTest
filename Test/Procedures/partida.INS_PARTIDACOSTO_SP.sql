  
CREATE PROCEDURE [partida].[INS_PARTIDACOSTO_SP]  
@costos     XML,  
@idTipoObjeto   INT,
@idClase	varchar(10),  
@idUsuario    INT,  
@err        NVARCHAR(500) = '' OUTPUT  
AS  
BEGIN  
   
 INSERT INTO partida.PartidaCosto( costo, idPartida, idTipoCobro, idClase, idUsuario, idTipoObjeto)  
 SELECT  
  ParamValues.col.value('costo[1]','varchar(250)'),  
  ParamValues.col.value('idPartida[1]','int'),  
  ParamValues.col.value('idTipoCobro[1]','varchar(10)'),
  @idClase,
  @idusuario,
  @idTipoObjeto  
 FROM @costos.nodes('tiposCostos/tipocosto') AS ParamValues(col)  
END  
GO
