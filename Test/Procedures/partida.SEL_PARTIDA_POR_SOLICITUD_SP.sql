CREATE PROCEDURE [partida].[SEL_PARTIDA_POR_SOLICITUD_SP]  
 @idSolicitud  INT,  
 @numeroContrato  VARCHAR(50),  
 @idCliente   INT,  
 @idClase   VARCHAR(10),  
 @idUsuario   INT,  
 @err    VARCHAR(500) OUTPUT  
AS  

BEGIN  
create table #partidas(  
 idPartida     int,
 cantidad		int,
 agrupador   varchar(500),  
 valor    varchar(250),  
 orden    int,  
 posicion   int,  
 ordenFinal   INT  
)  
  
  
;with catalogos as(  
 select   
  par.idPartida     idPartida,
  [SP].[cantidad],
  prg.agrupador     agrupador, 
  prg.valor      valor,  
  prg.idPadre      idPadre,  
  prg.orden      orden,  
  prg.posicion     posicion,  
  0        ordenFinal  
 from   
 partida.Partida par  
 inner join partida.PartidaPropiedadGeneral tpg on par.idPartida = tpg.idPartida  
 inner join partida.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral  
 inner join integridad.TipoDato tpd on tpd.idTipoDato = prg.idTipoDato   
 inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
 where   
  prg.idTipoValor in ('Catalogo','Agrupador') 
    AND [SP].[idSolicitud] = @idSolicitud  
  AND par.idClase = @idClase  
  AND par.activo = 1  
 )  
 insert into #partidas  
 select   
  cat.idPartida,
  cat.cantidad,
  cat.agrupador,  
  cat.valor,  
  cat.orden,  
  cat.posicion,  
  cat.ordenFinal  
 from catalogos cat   
 where   
  cat.idPadre is not null  
  
;with catalogos as(  
 select  
  par.idPartida     idPartida,
  [SP].[cantidad], 
  prc.agrupador     agrupador, 
  isnull(prc.valor,'')   valor,  
  prc.idPadre      idPadre,  
  prc.orden      orden,  
  prc.posicion     posicion,  
  1        ordenFinal  
 from   
 partida.Partida par  
 inner join partida.PartidaPropiedadClase tpc on par.idPartida = tpc.idPartida  
 inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase  
 inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
 where   
  prc.idTipoValor in ('Catalogo','Agrupador') 
    AND [SP].[idSolicitud] = @idSolicitud  
  AND par.idClase = @idClase  
  and par.activo = 1  
 UNION ALL   
  select  
  cat.idPartida     idPartida,
  cat.cantidad, 
  prc.agrupador     agrupador, 
  isnull(prc.valor,'')   valor,  
  prc.idPadre      idPadre,  
  prc.orden      orden,  
  prc.posicion     posicion,  
  1        ordenFinal  
 from partida.PropiedadClase prc   
 inner join catalogos cat on cat.idPadre = prc.idPropiedadClase   
 WHERE prc.activo = 1  
 )  
 insert into #partidas  
 select   
  cat.idPartida,
  cat.cantidad,
  cat.agrupador,  
  cat.valor,  
  cat.orden,  
  cat.posicion,  
  cat.ordenFinal  
 from catalogos cat   
 where   
  cat.idPadre is not null  
  
  
;with catalogos as(  
 select  
  par.idPartida     idPartida,
  [SP].[cantidad],
  prc.agrupador     agrupador, 
  isnull(prc.valor,'')   valor,  
  prc.idPadre      idPadre,  
  prc.orden      orden,  
  prc.posicion     posicion,  
  2        ordenFinal  
 from   
 partida.Partida par  
 inner join partida.PartidaPropiedadContrato tpc on par.idPartida = tpc.idPartida  
 inner join partida.PropiedadContrato prc on tpc.idPropiedadContrato = prc.idPropiedadContrato  
 inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
 where   
  prc.idTipoValor in ('Catalogo','Agrupador') 
    AND [SP].[idSolicitud] = @idSolicitud  
  and prc.numeroContrato = @numeroContrato  
  and prc.idCliente = @idCLiente  
  AND par.idClase = @idClase  
  and par.activo = 1  
 UNION ALL   
  select  
  cat.idPartida     idPartida, 
  cat.cantidad,
  prc.agrupador     agrupador, 
  isnull(prc.valor,'')   valor,  
  prc.idPadre      idPadre,  
  prc.orden      orden,  
  prc.posicion     posicion,  
  2        ordenFinal  
 from partida.PropiedadContrato prc   
 inner join catalogos cat on cat.idPadre = prc.idPropiedadContrato   
 WHERE prc.activo = 1  
 and prc.numeroContrato = @numeroContrato  
 and prc.idCliente = @idCLiente  
 )  
 insert into #partidas  
 select   
  cat.idPartida,
  cat.cantidad,
  cat.agrupador,  
  cat.valor,  
  cat.orden,  
  cat.posicion,  
  cat.ordenFinal  
 from catalogos cat   
 where   
  cat.idPadre is not null  
  
   
  
;with tags as(  
 select   
  par.idPartida     idPartida,
  [SP].[cantidad],
  prg.agrupador     agrupador, 
  prg.valor      valor,  
  prg.idPadre      idPadre,  
  prg.orden      orden,  
  prg.posicion     posicion,  
  0        ordenFinal  
 from   
 partida.Partida par  
 inner join partida.PartidaPropiedadGeneral tpg on par.idPartida = tpg.idPartida  
 inner join partida.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral  
 inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
 where prg.idTipoValor in ('Etiqueta') 
   AND [SP].[idSolicitud] = @idSolicitud  
  AND par.idClase = @idClase  
  and par.activo = 1  
 UNION ALL   
  select  
  tag.idPartida     idPartida,
  tag.cantidad,
  prg.agrupador     agrupador, 
  prg.valor      valor,  
  prg.idPadre      idPadre,  
  prg.orden      orden,  
  prg.posicion     posicion,  
  0        ordenFinal  
 from partida.PropiedadGeneral prg   
 inner join integridad.TipoDato tpd on tpd.idTipoDato = prg.idTipoDato   
 inner join tags tag on tag.idPadre = prg.idPropiedadGeneral  
 and prg.activo = 1  
 )  
 insert into #partidas  
 select distinct   
  idPartida,
  cantidad,
  agrupador,  
  (  
 SELECT STUFF(  
   
  (SELECT ', ' + valor  
  FROM tags tagsAux  
  WHERE tagsAux.idPadre is not null and tagsAux.idPartida = tags.idPartida and tagsAux.agrupador = tags.agrupador  
  FOR XML PATH ('')),  
 1,1, '') ) as valor, orden, posicion, ordenFinal from tags  
  
;with tags as(  
 select   
  par.idPartida     idPartida,
  [SP].cantidad, 
  prc.agrupador     agrupador, 
  isnull(prc.valor,'')   valor,  
  prc.idPadre      idPadre,  
  prc.orden      orden,  
  prc.posicion     posicion,  
  1        ordenFinal  
 from partida.Partida par  
 inner join partida.PartidaPropiedadClase tpc on par.idPartida = tpc.idPartida  
 inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase  
 inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
 where prc.idTipoValor in ('Etiqueta') 
   AND [SP].[idSolicitud] = @idSolicitud  
  AND par.idClase = @idClase  
  and par.activo = 1  
 UNION ALL   
  select  
  tag.idPartida     idPartida,  
  tag.cantidad,
  prc.agrupador     agrupador, 
  isnull(prc.valor,'')   valor,  
  prc.idPadre      idPadre,  
  prc.orden      orden,  
  prc.posicion     posicion,  
  1        ordenFinal  
 from partida.PropiedadClase prc   
 inner join tags tag on tag.idPadre = prc.idPropiedadClase  
 and prc.activo = 1  
 )  
 insert into #partidas  
 select distinct   
  idPartida,
  cantidad,
  agrupador,  
  (  
 SELECT STUFF(  
   
  (SELECT ', ' + valor  
  FROM tags tagsAux  
  WHERE tagsAux.idPadre is not null and tagsAux.idPartida = tags.idPartida and tagsAux.agrupador = tags.agrupador  
  FOR XML PATH ('')),  
 1,1, '') ) as valor, orden, posicion, ordenFinal from tags  
  
  
  
;with tags as(  
 select   
  par.idPartida     idPartida,
  [SP].cantidad,
  prc.agrupador     agrupador, 
  isnull(prc.valor,'')   valor,  
  prc.idPadre      idPadre,  
  prc.orden      orden,  
  prc.posicion     posicion,  
  2        ordenFinal  
 from partida.Partida par  
 inner join partida.PartidaPropiedadContrato tpc on par.idPartida = tpc.idPartida  
 inner join partida.PropiedadContrato prc on tpc.idPropiedadContrato = prc.idPropiedadContrato  
 inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
 where prc.idTipoValor in ('Etiqueta') 
   AND [SP].[idSolicitud] = @idSolicitud  
 and prc.numeroContrato = @numeroContrato  
 and prc.idCliente = @idCLiente  
 AND par.idClase = @idClase  
 and par.activo = 1  
 UNION ALL   
  select  
  tag.idPartida     idPartida,
  tag.cantidad,
  prc.agrupador     agrupador, 
  isnull(prc.valor,'')   valor,  
  prc.idPadre      idPadre,  
  prc.orden      orden,  
  prc.posicion     posicion,  
  2        ordenFinal  
 from partida.PropiedadContrato prc   
 inner join tags tag on tag.idPadre = prc.idPropiedadContrato  
 and prc.numeroContrato = @numeroContrato  
 and prc.idCliente = @idCLiente  
 and prc.activo = 1  
 )  
 insert into #partidas  
 select distinct   
  idPartida,
  cantidad,
  agrupador,  
  (  
 SELECT STUFF(  
   
  (SELECT ', ' + valor  
  FROM tags tagsAux  
  WHERE tagsAux.idPadre is not null and tagsAux.idPartida = tags.idPartida and tagsAux.agrupador = tags.agrupador  
  FOR XML PATH ('')),  
 1,1, '') ) as valor, orden, posicion, ordenFinal from tags  
  
  
INSERT INTO #partidas  
select   
 par.idPartida   idPartida, 
 [SP].cantidad,
 prg.valor    agrupador, 
 tpg.valor    valor,  
 prg.orden    orden,  
 prg.posicion   posicion,  
 0      ordenFinal  
from partida.Partida par   
inner join partida.PartidaPropiedadGeneral tpg on tpg.idPartida = par.idPartida  
inner join partida.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral  
inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
where  
 prg.idTipoValor = 'Unico'  
   AND [SP].[idSolicitud] = @idSolicitud  
 AND par.idClase = @idClase  
 and par.activo = 1  
  
INSERT INTO #partidas  
select   
 par.idPartida   idPartida,
 [SP].cantidad,
 prc.valor    agrupador, 
 tpc.valor    valor,  
 prc.orden    orden,  
 prc.posicion   posicion,  
 1      ordenFinal  
from partida.Partida par  
inner join partida.PartidaPropiedadClase tpc on tpc.idPartida = par.idPartida  
inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase  
inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
where  
 prc.idTipoValor = 'Unico'  
   AND [SP].[idSolicitud] = @idSolicitud  
 AND par.idClase = @idClase  
 and par.activo = 1  
  
INSERT INTO #partidas  
select   
 par.idPartida   idPartida,  
 [SP].cantidad,
 prc.valor    agrupador, 
 tpc.valor    valor,  
 prc.orden    orden,  
 prc.posicion   posicion,  
 2      ordenFinal  
from partida.Partida par  
inner join partida.PartidaPropiedadContrato tpc on tpc.idPartida = par.idPartida  
inner join partida.PropiedadContrato prc on tpc.idPropiedadContrato = prc.idPropiedadContrato  
inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
where  
 prc.idTipoValor = 'Unico'  
   AND [SP].[idSolicitud] = @idSolicitud  
 and prc.numeroContrato = @numeroContrato  
 AND par.idClase = @idClase  
 and prc.idCliente = @idCLiente  
 and par.activo = 1  
  
  
  
  
  
INSERT INTO #partidas  
select   
 par.idPartida    idPartida 
 ,[SP].cantidad
 ,tc.nombre     agrupador  
 ,isnull(parcos.costo,0)  valor  
 ,1       orden  
 ,3       posicion  
 ,2  
from partida.tipoobjeto.TipoObjeto tob   
inner join partida.partida par on tob.idTipoObjeto = par.idTipoObjeto  
inner join partida.partida.PartidaCosto parcos on parcos.idPartida = par.idPartida   
inner join partida.TipoCobro tc on parcos.idTipoCobro = tc.idTipoCobro  
inner join [Solicitud].[solicitud].[SolicitudPartida] AS [SP] on [SP].idPartida = par.idPartida  
WHERE par.idClase = @idClase  
AND [SP].[idSolicitud] = @idSolicitud  
and par.activo = 1  
  
  
declare   
 @columnsName varchar(max) = ''  
  
create table #propiedadesOrdenas  
 (  
  agrupador   varchar(500),  
  ordenFinal   int,  
  posicion   int,  
  orden    int  
 )  
  
insert into #propiedadesOrdenas  
select distinct   
 pr.agrupador,  
 min(pr.ordenFinal),  
 min(pr.posicion),  
 min(pr.orden)  
from #partidas pr group by pr.agrupador order by   
 min(pr.ordenFinal),  
 min(pr.posicion),  
 min(pr.orden)  
  
SET @columnsName = STUFF((SELECT ',' + QUOTENAME(prg.agrupador)   
      FROM #propiedadesOrdenas prg   
      FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
declare @query varchar(max)  
set @query = '  
 select  
  *,  
  (select sum(costo) from partida.PartidaCosto cos where cos.idPartida = resultado.idPartida) Costo,  
  ISNULL((select sum(Venta) from cliente.contrato.PartidaPrecio pre where pre.idPartida = resultado.idPartida and pre.idCliente = ' + convert(varchar,@idCliente) + ' and numeroContrato = '' + @numeroContrato + ''),0) Venta  
 from  
 (select idPartida, cantidad as cant, agrupador, isnull(valor,0) valor from #partidas) t  
 pivot  
 (   
  MAX(valor)  
  for agrupador in (' + @columnsName + ')  
 ) AS resultado'  
  
print @query  
  
execute (@query)  
drop table #partidas  
drop table #propiedadesOrdenas  
end  
GO
