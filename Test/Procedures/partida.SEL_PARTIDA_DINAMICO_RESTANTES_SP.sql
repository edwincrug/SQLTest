CREATE PROCEDURE [partida].[SEL_PARTIDA_DINAMICO_RESTANTES_SP] 
	@idTipoObjeto		INT,
	@numeroContrato		VARCHAR(50),
	@idCliente			INT,
	@idUsuario			INT = NULL,
	@idClase			VARCHAR(10),
	@err				VARCHAR(500) = NULL OUTPUT,
	@idTipoSolicitud	VARCHAR(10) = null,
	@idSolicitud		INT
AS

BEGIN
create table #partidas(
	idPartida					int,
	agrupador			varchar(500),
	valor				varchar(250),
	orden				int,
	posicion			int,
	ordenFinal			INT
)

;with catalogos as(
	select	
		par.idPartida					idPartida,
		prg.agrupador					agrupador, 
		prg.valor						valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from 
	partida.Partida par
	left join Solicitud.solicitud.SolicitudPartida solpar
	on par.idPartida = solpar.idPartida
	and par.idClase = solpar.idClase
	and par.idTipoObjeto = solpar.idTipoObjeto
	and solpar.idSolicitud = @idSolicitud
	inner join partida.PartidaPropiedadGeneral tpg on par.idPartida = tpg.idPartida
	inner join partida.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral and prg.activo = 1
	inner join integridad.TipoDato tpd on tpd.idTipoDato = prg.idTipoDato 
	where 
		prg.idTipoValor in ('Catalogo','Agrupador') 
		AND par.idTipoObjeto = @idTipoObjeto
		AND par.idClase = @idClase
		AND par.activo = 1
		and solpar.idSolicitud is null
	UNION ALL	
		select
		cat.idPartida					idPartida,
		prg.agrupador					agrupador, 
		prg.valor						valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from partida.PropiedadGeneral prg 
	inner join integridad.TipoDato tpd on tpd.idTipoDato = prg.idTipoDato 
	inner join catalogos cat on cat.idPadre = prg.idPropiedadGeneral
	and prg.activo = 1
	)
	insert into #partidas
	select 
		cat.idPartida,
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
		par.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from 
	partida.Partida par
	left join Solicitud.solicitud.SolicitudPartida solpar
	on par.idPartida = solpar.idPartida
	and par.idClase = solpar.idClase
	and par.idTipoObjeto = solpar.idTipoObjeto
	and solpar.idSolicitud = @idSolicitud
	inner join partida.PartidaPropiedadClase tpc on par.idPartida = tpc.idPartida
	inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase and prc.activo = 1 and prc.idClase = @idClase
	where 
		prc.idTipoValor in ('Catalogo','Agrupador') 
		and par.idTipoObjeto = @idTipoObjeto
		AND par.idClase = @idClase
		and par.activo = 1
		and solpar.idSolicitud is null
	UNION ALL	
		select
		cat.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from partida.PropiedadClase prc 
	inner join catalogos cat on cat.idPadre = prc.idPropiedadClase 
	WHERE prc.activo = 1
	)
	insert into #partidas
	select 
		cat.idPartida,
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
		par.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		2								ordenFinal
	from 
	partida.Partida par
	left join Solicitud.solicitud.SolicitudPartida solpar
	on par.idPartida = solpar.idPartida
	and par.idClase = solpar.idClase
	and par.idTipoObjeto = solpar.idTipoObjeto
	and solpar.idSolicitud = @idSolicitud
	inner join partida.PartidaPropiedadContrato tpc on par.idPartida = tpc.idPartida
	inner join partida.PropiedadContrato prc on tpc.idPropiedadContrato = prc.idPropiedadContrato and prc.activo = 1 and prc.idCliente = @idCLiente  and prc.numeroContrato = @numeroContrato
	where 
		prc.idTipoValor in ('Catalogo','Agrupador') 
		and par.idTipoObjeto = @idTipoObjeto
		and par.activo = 1
		AND par.idClase = @idClase
		and solpar.idSolicitud is null
	UNION ALL	
		select
		cat.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		2								ordenFinal
	from partida.PropiedadContrato prc 
	inner join catalogos cat on cat.idPadre = prc.idPropiedadContrato 
	WHERE prc.activo = 1
	and prc.numeroContrato = @numeroContrato
	and prc.idCliente = @idCLiente
	)
	insert into #partidas
	select 
		cat.idPartida,
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
		par.idPartida					idPartida,
		prg.agrupador					agrupador, 
		prg.valor						valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from 
	partida.Partida par
	left join Solicitud.solicitud.SolicitudPartida solpar
	on par.idPartida = solpar.idPartida
	and par.idClase = solpar.idClase
	and par.idTipoObjeto = solpar.idTipoObjeto
	and solpar.idSolicitud = @idSolicitud
	inner join partida.PartidaPropiedadGeneral tpg on par.idPartida = tpg.idPartida
	inner join partida.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral and prg.activo = 1
	where prg.idTipoValor in ('Etiqueta') 
	and par.idTipoObjeto = @idTipoObjeto
	AND par.idClase = @idClase
	and par.activo = 1
	and solpar.idSolicitud is null
	UNION ALL	
		select
		tag.idPartida					idPartida,
		prg.agrupador					agrupador, 
		prg.valor						valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from partida.PropiedadGeneral prg 
	inner join integridad.TipoDato tpd on tpd.idTipoDato = prg.idTipoDato 
	inner join tags tag on tag.idPadre = prg.idPropiedadGeneral
	and prg.activo = 1
	)
	insert into #partidas
	select distinct 
		idPartida,
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
		par.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from partida.Partida par
	left join Solicitud.solicitud.SolicitudPartida solpar
	on par.idPartida = solpar.idPartida
	and par.idClase = solpar.idClase
	and par.idTipoObjeto = solpar.idTipoObjeto
	and solpar.idSolicitud = @idSolicitud
	inner join partida.PartidaPropiedadClase tpc on par.idPartida = tpc.idPartida
	inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase and prc.activo = 1 and prc.idClase = @idClase
	where prc.idTipoValor in ('Etiqueta') 
	and par.idTipoObjeto = @idTipoObjeto
	AND par.idClase = @idClase
	and par.activo = 1
	and solpar.idSolicitud is null
	UNION ALL	
		select
		tag.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from partida.PropiedadClase prc 
	inner join tags tag on tag.idPadre = prc.idPropiedadClase
	and prc.activo = 1
	)
	insert into #partidas
	select distinct 
		idPartida,
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
		par.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		2								ordenFinal
	from partida.Partida par
	left join Solicitud.solicitud.SolicitudPartida solpar
	on par.idPartida = solpar.idPartida
	and par.idClase = solpar.idClase
	and par.idTipoObjeto = solpar.idTipoObjeto
	and solpar.idSolicitud = @idSolicitud
	inner join partida.PartidaPropiedadContrato tpc on par.idPartida = tpc.idPartida
	inner join partida.PropiedadContrato prc on tpc.idPropiedadContrato = prc.idPropiedadContrato and prc.activo = 1 and prc.idCliente = @idCLiente  and prc.numeroContrato = @numeroContrato
	where prc.idTipoValor in ('Etiqueta') 
	and par.idTipoObjeto = @idTipoObjeto
	and prc.numeroContrato = @numeroContrato
	and prc.idCliente = @idCLiente
	AND par.idClase = @idClase
	and par.activo = 1
	and solpar.idSolicitud is null
	UNION ALL	
		select
		tag.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		2								ordenFinal
	from partida.PropiedadContrato prc 
	inner join tags tag on tag.idPadre = prc.idPropiedadContrato
	and prc.numeroContrato = @numeroContrato
	and prc.idCliente = @idCLiente
	and prc.activo = 1
	)
	insert into #partidas
	select distinct 
		idPartida,
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
	par.idPartida			idPartida,
	prg.valor				agrupador, 
	tpg.valor				valor,
	prg.orden				orden,
	prg.posicion			posicion,
	0						ordenFinal
from partida.Partida par
left join Solicitud.solicitud.SolicitudPartida solpar
on par.idPartida = solpar.idPartida
and par.idClase = solpar.idClase
and par.idTipoObjeto = solpar.idTipoObjeto
and solpar.idSolicitud = @idSolicitud
inner join partida.PartidaPropiedadGeneral tpg on tpg.idPartida = par.idPartida
inner join partida.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral and prg.activo = 1 
where
	prg.idTipoValor = 'Unico'
	and par.idTipoObjeto = @idTipoObjeto
	AND par.idClase = @idClase
	and par.activo = 1
	and solpar.idSolicitud is null
INSERT INTO #partidas
select 
	par.idPartida			idPartida,
	prc.valor				agrupador, 
	tpc.valor				valor,
	prc.orden				orden,
	prc.posicion			posicion,
	1						ordenFinal
from partida.Partida par
left join Solicitud.solicitud.SolicitudPartida solpar
on par.idPartida = solpar.idPartida
and par.idClase = solpar.idClase
and par.idTipoObjeto = solpar.idTipoObjeto
and solpar.idSolicitud = @idSolicitud
inner join partida.PartidaPropiedadClase tpc on tpc.idPartida = par.idPartida
inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase and prc.activo = 1 and prc.idClase = @idClase
where
	prc.idTipoValor = 'Unico'
	and par.idTipoObjeto = @idTipoObjeto
	AND par.idClase = @idClase
	and par.activo = 1
	and solpar.idSolicitud is null
INSERT INTO #partidas
select 
	par.idPartida			idPartida,
	prc.valor				agrupador, 
	tpc.valor				valor,
	prc.orden				orden,
	prc.posicion			posicion,
	2						ordenFinal
from partida.Partida par
left join Solicitud.solicitud.SolicitudPartida solpar
on par.idPartida = solpar.idPartida
and par.idClase = solpar.idClase
and par.idTipoObjeto = solpar.idTipoObjeto
and solpar.idSolicitud = @idSolicitud
inner join partida.PartidaPropiedadContrato tpc on tpc.idPartida = par.idPartida
inner join partida.PropiedadContrato prc on tpc.idPropiedadContrato = prc.idPropiedadContrato and prc.activo = 1 and prc.idCliente = @idCLiente  and prc.numeroContrato = @numeroContrato
where
	prc.idTipoValor = 'Unico'
	and par.idTipoObjeto = @idTipoObjeto
	and prc.numeroContrato = @numeroContrato
	AND par.idClase = @idClase
	and prc.idCliente = @idCLiente
	and par.activo = 1
	and solpar.idSolicitud is null



INSERT INTO #partidas
select 
	par.idPartida				idPartida
	,tc.nombre					agrupador
	,isnull(parcos.costo,0)		valor
	,1							orden
	,3							posicion
	,2
from partida.tipoobjeto.TipoObjeto tob 
inner join partida.partida par on tob.idTipoObjeto = par.idTipoObjeto
left join Solicitud.solicitud.SolicitudPartida solpar
on par.idPartida = solpar.idPartida
and par.idClase = solpar.idClase
and par.idTipoObjeto = solpar.idTipoObjeto
and solpar.idSolicitud = @idSolicitud
inner join partida.partida.PartidaCosto parcos on parcos.idPartida = par.idPartida 
inner join partida.TipoCobro tc on parcos.idTipoCobro = tc.idTipoCobro
WHERE par.idClase = @idClase
and tob.idtipoobjeto = @idTipoObjeto
and par.activo = 1
and solpar.idSolicitud is null

IF isnull(@idTipoSolicitud,'') != ''
BEGIN
	DECLARE @partidasTmp TABLE (
		idPartida			int,
		agrupador			varchar(500),
		valor				varchar(250),
		orden				int,
		posicion			int,
		ordenFinal			INT
	)
	INSERT INTO @partidasTmp
		SELECT 
			p.idPartida,
			agrupador,
			valor,
			orden,
			posicion,
			ordenFinal
		FROM #partidas AS P
		INNER JOIN partida.TipoSolicitud AS T ON P.idPartida = T.idPartida 
		AND T.idTipoObjeto = @idTipoObjeto
		AND T.idClase = @idClase
		WHERE idTipoSolicitud = @idTipoSolicitud

	DELETE FROM #partidas;
	
	INSERT INTO #partidas
	SELECT * FROM @partidasTmp


END


declare 
	@columnsName varchar(max) = ''

create table #propiedadesOrdenas
	(
		agrupador			varchar(500),
		ordenFinal			int,
		posicion			int,
		orden				int
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
	(select idPartida, agrupador, isnull(valor,0) valor from #partidas) t
	pivot
	(	
		MAX(valor)
		for agrupador in (' + @columnsName + ')
	) AS resultado'


execute (@query)
drop table #partidas
drop table #propiedadesOrdenas
end

GO
