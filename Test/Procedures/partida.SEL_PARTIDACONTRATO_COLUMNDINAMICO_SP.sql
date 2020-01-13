CREATE  PROCEDURE [partida].[SEL_PARTIDACONTRATO_COLUMNDINAMICO_SP] 
	@idTipoObjeto			INT,
	@numeroContrato			VARCHAR(50),
	@idCliente				INT,
	@idUsuario				INT,
	@idClase				VARCHAR(10),
	@rfc					VARCHAR(13),
	@err					nvarchar(500) OUTPUT
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
		par.idPartidaContrato			idPartida,
		prg.agrupador					agrupador, 
		prg.valor						valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal	
	from 
	partida.PartidaContrato par
	inner join partida.PartidaContratoPropiedadGeneral tpg on par.idPartidaContrato = tpg.idPartidaContrato
	inner join partida.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral AND prg.activo = 1
	inner join integridad.TipoDato tpd on tpd.idTipoDato = prg.idTipoDato 
	where 
		prg.idTipoValor in ('Catalogo','Agrupador') 
		and par.idTipoObjeto = @idTipoObjeto
		and par.activo = 1
		AND par.idClase = @idClase
		AND par.rfcEmpresa = @rfc
		AND par.idCliente = @idCliente
		AND par.numeroCOntrato = @numeroContrato
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
		par.idPartidaContrato					idPartida,
		prc.agrupador					agrupador, 
		isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from 
	partida.PartidaContrato par
	inner join partida.PartidaContratoPropiedadClase tpc on par.idPartidaContrato = tpc.idPartidaContrato
	inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase AND prc.activo = 1 AND prc.idClase = @idClase
	where 
		prc.idTipoValor in ('Catalogo','Agrupador') 
		and par.idTipoObjeto = @idTipoObjeto
		and par.activo = 1
		AND par.idClase = @idClase
		AND par.rfcEmpresa = @rfc
		AND par.idCliente = @idCliente
		AND par.numeroCOntrato = @numeroContrato
	UNION ALL	
		select
		cat.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
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
		par.idPartidaContrato					idPartida,
		prc.agrupador					agrupador, 
		isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		2								ordenFinal
	from 
	partida.PartidaContrato par
	inner join partida.PartidaContratoPropiedadContrato tpc on par.idPartidaContrato = tpc.idPartidaContrato
	inner join partida.PropiedadContrato prc on tpc.idPropiedadContrato = prc.idPropiedadContrato AND prc.activo = 1 and prc.numeroContrato = @numeroContrato and prc.idCliente = @idCLiente
	where 
		prc.idTipoValor in ('Catalogo','Agrupador') 
		and par.idTipoObjeto = @idTipoObjeto
		and par.activo = 1
		AND par.idClase = @idClase
		AND par.rfcEmpresa = @rfc

	UNION ALL	
		select
		cat.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
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
		par.idPartidaContrato					idPartida,
		prg.agrupador					agrupador, 
		isnull(CAST(prg.idTipoDato AS VARCHAR(250)),'')			valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from 
	partida.PartidaContrato par
	inner join partida.PartidaContratoPropiedadGeneral tpg on par.idPartidaContrato = tpg.idPartidaContrato
	inner join partida.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral AND prg.activo = 1 
	where prg.idTipoValor in ('Etiqueta') 
	and par.idTipoObjeto = @idTipoObjeto
	and par.activo = 1
	AND par.idClase = @idClase
	AND par.rfcEmpresa = @rfc
	AND par.idCliente = @idCliente
	AND par.numeroCOntrato = @numeroContrato
	UNION ALL	
		select
		tag.idPartida					idPartida,
		prg.agrupador					agrupador, 
		isnull(CAST(prg.idTipoDato AS VARCHAR(250)),'')			valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from partida.PropiedadGeneral prg 
	inner join tags tag on tag.idPadre = prg.idPropiedadGeneral
	WHERE prg.activo = 1
	)
	insert into #partidas
	select distinct 
		idPartida,
		agrupador,
		(
	SELECT STUFF(
	
		(SELECT ', ' + valor
		FROM tags tagsAux
		WHERE tagsAux.idPadre is not null and tagsAux.idPartida = tags. idPartida and tagsAux.agrupador = tags.agrupador
		FOR XML PATH ('')),
	1,1, '') ) as valor, orden, posicion, ordenFinal from tags

;with tags as(
	select	
		par.idPartidaContrato			idPartida,
		prc.agrupador					agrupador, 
		isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from partida.PartidaCOntrato par
	inner join partida.PartidaContratoPropiedadClase tpc on par.idPartidaContrato = tpc.idPartidaContrato
	inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase AND prc.activo = 1 and prc.idClase = @idClase
	where prc.idTipoValor in ('Etiqueta') 
	and par.idTipoObjeto = @idTipoObjeto
	and par.activo = 1
	AND par.idClase = @idClase
	AND par.rfcEmpresa = @rfc
	AND par.idCliente = @idCliente
	AND par.numeroCOntrato = @numeroContrato
	UNION ALL	
		select
		tag.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
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
		par.idPartidaContrato			idPartida,
		prc.agrupador					agrupador, 
		isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		2								ordenFinal
	from partida.PartidaContrato par
	inner join partida.PartidaContratoPropiedadContrato tpc on par.idPartidaContrato = tpc.idPartidaContrato
	inner join partida.PropiedadContrato prc on tpc.idPropiedadContrato = prc.idPropiedadContrato AND prc.activo = 1 and prc.numeroContrato = @numeroContrato and prc.idCliente = @idCLiente
	where prc.idTipoValor in ('Etiqueta') 
	and par.idTipoObjeto = @idTipoObjeto
	and prc.numeroContrato = @numeroContrato
	and prc.idCliente = @idCLiente
	and par.activo = 1
	AND par.idClase = @idClase
	AND par.rfcEmpresa = @rfc
	UNION ALL	
		select
		tag.idPartida					idPartida,
		prc.agrupador					agrupador, 
		isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		2								ordenFinal
	from partida.PropiedadContrato prc 
	inner join tags tag on tag.idPadre = prc.idPropiedadContrato
	and prc.activo = 1
	and prc.numeroContrato = @numeroContrato
	and prc.idCliente = @idCLiente
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
	par.idPartidaContrato			idPartida,
	prg.valor				agrupador, 
	isnull(CAST(prg.idTipoDato AS VARCHAR(250)),'')			valor,
	prg.orden						orden,
	prg.posicion					posicion,
	0								ordenFinal
from partida.PartidaContrato par
inner join partida.PartidaContratoPropiedadGeneral tpg on tpg.idPartidaContrato = par.idPartidaContrato
inner join partida.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral AND prg.activo = 1
where
	prg.idTipoValor = 'Unico'
	and par.idTipoObjeto = @idTipoObjeto
	and par.activo = 1
	AND par.idClase = @idClase
	AND par.rfcEmpresa = @rfc
	AND par.idCliente = @idCliente
	AND par.numeroCOntrato = @numeroContrato

INSERT INTO #partidas
select 
	par.idPartidaContrato	idPartida,
	prc.valor				agrupador, 
	isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
	prc.orden						orden,
	prc.posicion					posicion,
	1								ordenFinal
from partida.PartidaContrato par
inner join partida.PartidaContratoPropiedadClase tpc on tpc.idPartidaContrato = par.idPartidaContrato
inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase AND prc.activo = 1 and prc.idClase = @idClase
where
	prc.idTipoValor = 'Unico'
	and par.idTipoObjeto = @idTipoObjeto
	and par.activo = 1
	AND par.idClase = @idClase
	AND par.rfcEmpresa = @rfc
	AND par.idCliente = @idCliente
	AND par.numeroCOntrato = @numeroContrato


INSERT INTO #partidas
select 
	par.idPartidaContrato			idPartida,
	prc.valor				agrupador, 
	isnull(CAST(prc.idTipoDato AS VARCHAR(250)),'')			valor,
	prc.orden						orden,
	prc.posicion					posicion,
	2								ordenFinal
from partida.PartidaContrato par
inner join partida.PartidaCOntratoPropiedadContrato tpc on tpc.idPartidaContrato = par.idPartidaContrato
inner join partida.PropiedadContrato prc on tpc.idPropiedadContrato = prc.idPropiedadContrato AND prc.activo = 1 and prc.numeroContrato = @numeroContrato and prc.idCliente = @idCLiente
where
	prc.idTipoValor = 'Unico'
	and par.idTipoObjeto = @idTipoObjeto
	and prc.numeroContrato = @numeroContrato
	and prc.idCliente = @idCLiente
	and par.activo = 1
	AND par.idClase = @idClase
	AND par.rfcEmpresa = @rfc


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
		*
	from
	(select idPartida, agrupador, valor from #partidas) t
	pivot
	(	
		max(valor)
		for agrupador in (' + @columnsName + ')
	) AS resultado'

execute (@query)
drop table #partidas
end

GO
