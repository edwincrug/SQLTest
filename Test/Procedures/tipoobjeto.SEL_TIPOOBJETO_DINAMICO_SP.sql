CREATE  PROCEDURE [tipoobjeto].[SEL_TIPOOBJETO_DINAMICO_SP] 
	@idClase		VARCHAR(10),
	@idUsuario		INT,
	@err			nvarchar(500) OUTPUT
AS
BEGIN
create table #propiedades(
	idTipoObjeto		int,
	agrupador			varchar(500),
	valor				varchar(250),
	orden				int,
	posicion			int,
	ordenFinal			INT
)

;with catalogos as(
	select	
		tob.idTipoObjeto				idTipoObjeto,
		prg.agrupador					agrupador, 
		prg.valor						valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from 
	tipoobjeto.TipoObjeto tob
	inner join tipoobjeto.TipoObjetoPropiedadGeneral tpg on tob.idTipoObjeto = tpg.idTipoObjeto
	inner join tipoobjeto.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral and prg.activo = 1 
	inner join integridad.TipoDato tpd on tpd.idTipoDato = prg.idTipoDato 
	where 
		prg.idTipoValor in ('Catalogo','Agrupador') 
		and tob.idClase = @idClase
		and tob.activo = 1
	UNION ALL	
		select
		cat.idTipoObjeto				idTipoObjeto,
		prg.agrupador					agrupador, 
		prg.valor						valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from tipoobjeto.PropiedadGeneral prg 
	inner join integridad.TipoDato tpd on tpd.idTipoDato = prg.idTipoDato 
	inner join catalogos cat on cat.idPadre = prg.idPropiedadGeneral
	and prg.activo = 1
	)
	insert into #propiedades
	select 
		cat.idTipoObjeto,
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
		tob.idTipoObjeto				idTipoObjeto,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from 
	tipoobjeto.TipoObjeto tob
	inner join tipoobjeto.TipoObjetoPropiedadClase tpc on tob.idTipoObjeto = tpc.idTipoObjeto
	inner join tipoobjeto.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase and prc.activo = 1 and prc.idClase = @idClase
	where 
		prc.idTipoValor in ('Catalogo','Agrupador') 
		and tob.idClase = @idClase
		and tob.activo = 1
	UNION ALL	
		select
		cat.idTipoObjeto				idTipoObjeto,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from tipoobjeto.PropiedadClase prc 
	inner join catalogos cat on cat.idPadre = prc.idPropiedadClase 
	WHERE prc.activo = 1
	)
	insert into #propiedades
	select 
		cat.idTIpoObjeto,
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
		tob.idTipoObjeto				idTipoObjeto,
		prg.agrupador					agrupador, 
		isnull(prg.valor,'')			valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from 
	tipoobjeto.TipoObjeto tob
	inner join tipoobjeto.TipoObjetoPropiedadGeneral tpg on tob.idTipoObjeto = tpg.idTipoObjeto
	inner join tipoobjeto.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral and prg.activo = 1
	where prg.idTipoValor in ('Etiqueta') 
	and tob.idClase = @idClase
	and tob.activo = 1
	UNION ALL	
		select
		tag.idTipoObjeto				idTipoObjeto,
		prg.agrupador					agrupador, 
		isnull(prg.valor,'')			valor,
		prg.idPadre						idPadre,
		prg.orden						orden,
		prg.posicion					posicion,
		0								ordenFinal
	from tipoobjeto.PropiedadGeneral prg 
	inner join tags tag on tag.idPadre = prg.idPropiedadGeneral
	WHERE prg.activo = 1
	)
	insert into #propiedades
	select distinct 
		idTipoObjeto,
		agrupador,
		(
	SELECT STUFF(
	
		(SELECT ', ' + valor
		FROM tags tagsAux
		WHERE tagsAux.idPadre is not null and tagsAux.idTipoObjeto = tags. idTipoObjeto and tagsAux.agrupador = tags.agrupador
		FOR XML PATH ('')),
	1,1, '') ) as valor, orden, posicion, ordenFinal from tags

;with tags as(
	select	
		tob.idTipoObjeto				idTipoObjeto,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from tipoobjeto.TipoObjeto tob
	inner join tipoobjeto.TipoObjetoPropiedadClase tpc on tob.idTipoObjeto = tpc.idTipoObjeto
	inner join tipoobjeto.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase and prc.activo = 1 and prc.idClase = @idClase
	where prc.idTipoValor in ('Etiqueta') 
	and tob.idClase = @idClase
	and tob.activo = 1
	UNION ALL	
		select
		tag.idTipoObjeto				idTipoObjeto,
		prc.agrupador					agrupador, 
		isnull(prc.valor,'')			valor,
		prc.idPadre						idPadre,
		prc.orden						orden,
		prc.posicion					posicion,
		1								ordenFinal
	from tipoobjeto.PropiedadClase prc 
	inner join tags tag on tag.idPadre = prc.idPropiedadClase
	and prc.activo = 1
	)
	insert into #propiedades
	select distinct 
		idTipoObjeto,
		agrupador,
		(
	SELECT STUFF(
	
		(SELECT ', ' + valor
		FROM tags tagsAux
		WHERE tagsAux.idPadre is not null and tagsAux.idTipoObjeto = tags.idTipoObjeto and tagsAux.agrupador = tags.agrupador
		FOR XML PATH ('')),
	1,1, '') ) as valor, orden, posicion, ordenFinal from tags

INSERT INTO #propiedades
select 
	pto.idTipoObjeto		idTipoObjeto,
	prg.valor				agrupador, 
	tpg.valor				valor,
	prg.orden						orden,
	prg.posicion					posicion,
	0								ordenFinal
from tipoobjeto.TipoObjeto pto 
inner join tipoobjeto.TipoObjetoPropiedadGeneral tpg on tpg.idTipoObjeto = pto.idTipoObjeto
inner join tipoobjeto.PropiedadGeneral prg on tpg.idPropiedadGeneral = prg.idPropiedadGeneral and prg.activo = 1
where
	prg.idTipoValor = 'Unico'
	and pto.idClase = @idClase
	and pto.activo = 1

INSERT INTO #propiedades
select 
	pto.idTipoObjeto				idTipoObjeto,
	prc.valor				agrupador, 
	tpc.valor				valor,
	prc.orden						orden,
	prc.posicion					posicion,
	1								ordenFinal
from tipoobjeto.TipoObjeto pto 
inner join tipoobjeto.TipoObjetoPropiedadClase tpc on tpc.idTipoObjeto = pto.idTipoObjeto
inner join tipoobjeto.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase and prc.activo = 1 and prc.idClase = @idClase
where
	prc.idTipoValor = 'Unico'
	and pto.idClase = @idClase
	and pto.activo = 1



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
from #propiedades pr group by pr.agrupador order by 
	min(pr.ordenFinal),
	min(pr.posicion),
	min(pr.orden)


SET @columnsName = STUFF((SELECT ',' + QUOTENAME(prg.agrupador) 
						FROM #propiedadesOrdenas prg 
						FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'')

declare @query varchar(max)
DECLARE @columnas VARCHAR(1000), @tmp int
	;with cols as( select distinct top 2 agrupador, posicion from [partida].[tipoobjeto].[PropiedadClase]
		where idClase = @idClase and activo = 1
		order by posicion
	)
	select  @columnas = COALESCE(@columnas + '+ ' , '+ ', '') + agrupador from cols
		set @query = '
			select
				*
				,(select count(*) from 
					partida.partida.partida par 
					where par.idTipoObjeto = resultado.idTipoObjeto and par.activo=1 ) as TotalPartidas
				,'+@columnas+' as marcaSub
			from
			(select idTipoObjeto, agrupador, valor from #propiedades) t  
			pivot
			(	
				max(valor)
				for agrupador in (' + @columnsName + ')
			) AS resultado'
	


execute (@query)
drop table #propiedades
drop table #propiedadesOrdenas
end

GO
