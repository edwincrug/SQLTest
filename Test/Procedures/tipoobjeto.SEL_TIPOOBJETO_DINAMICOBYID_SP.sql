CREATE  PROCEDURE [tipoobjeto].[SEL_TIPOOBJETO_DINAMICOBYID_SP] 
	@idTipoObjeto			int,
	@idUsuario				INT,
	@idClase				VARCHAR(10),
	@err					nvarchar(500) OUTPUT
AS


BEGIN

create table #propiedades(
	propiedad		varchar(500),
	idPropiedad		varchar(250),
	valor			varchar(250),
	idTipoDato		varchar(250),
	idPadre			int
)


	;with catalogos as(
		select 
		(Select valor from tipoobjeto.PropiedadGeneral where idPropiedadGeneral = pg.idpadre) as propiedad,
		CAST(tpg.idPropiedadGeneral AS VARCHAR(250)) as idPropiedad,
		pg.valor,
		idPadre,
		pg.idTipoDato
		from tipoobjeto.TipoObjetoPropiedadGeneral TPG
		LEFT JOIN tipoobjeto.PropiedadGeneral PG ON PG.idpropiedadGeneral = tpg.idpropiedadGeneral and pg.activo = 1
		where idTipoValor in  ('Catalogo','Agrupador')
		and idTIpoObjeto = @idTipoObjeto
		and TPG.idClase = @idClase

		UNION ALL	
		select
			prg.valor,
			cat.idPropiedad,
			cat.valor,
			prg.idPadre,
			cat.idTipoDato
		from tipoobjeto.PropiedadGeneral prg 
		inner join catalogos cat on cat.idPadre = prg.idPropiedadGeneral
		WHERE prg.activo = 1
		)

		insert into #propiedades
		select 
			propiedad,
			idPropiedad,
			valor,
			idTipoDato,
			idPadre
		from catalogos cat 

	
	;with catalogos as(

		select 
		(Select valor from tipoobjeto.PropiedadClase where idPropiedadClase = pc.idpadre) as propiedad,
		CAST(tpc.idPropiedadClase AS VARCHAR(250)) as idPropiedad,
		pc.valor,
		idPadre,
		pc.idTipoDato
		from tipoobjeto.TipoObjetoPropiedadClase TPC
		LEFT JOIN tipoobjeto.PropiedadClase PC ON PC.idpropiedadClase = tpc.idpropiedadclase and pc.activo = 1 and pc.idClase = @idClase
		where idTipoValor in  ('Catalogo','Agrupador')
		and idTIpoObjeto = @idTipoObjeto
		and TPC.idClase = @idClase

		UNION ALL	
			select
			prc.valor,
			cat.idPropiedad,
			cat.valor,
			prc.idPadre,
			cat.idTipoDato
		from tipoobjeto.PropiedadClase prc 
		inner join catalogos cat on cat.idPadre = prc.idPropiedadClase 
		WHERE prc.activo = 1


	 )

		insert into #propiedades
		select 
			propiedad,
			idPropiedad,
			valor,
			idTipoDato,
			idPadre
		from catalogos cat 


			
	
	;with tags as(

		select 
		(Select valor from tipoobjeto.PropiedadGeneral where idPropiedadGeneral = pg.idpadre) as propiedad,
		CAST(tpg.idPropiedadGeneral AS VARCHAR(250)) as idPropiedad,
		pg.valor,
		idPadre,
		pg.idTipoDato
		from tipoobjeto.TipoObjetoPropiedadGeneral TPG
		LEFT JOIN tipoobjeto.PropiedadGeneral PG ON PG.idpropiedadGeneral = tpg.idpropiedadGeneral and pg.activo = 1
		where idTipoValor ='Etiqueta'
		and idTIpoObjeto = @idTipoObjeto
		and TPG.idClase = @idClase

		UNION ALL	
		select
			prg.valor,
			tag.idPropiedad,
			tag.valor,
			prg.idPadre,
			tag.idTipoDato
		from tipoobjeto.PropiedadGeneral prg 
		inner join tags tag on tag.idPadre = prg.idPropiedadGeneral
		WHERE prg.activo = 1

	 )

		insert into #propiedades
		select 
			propiedad,
			idPropiedad,
			(
			SELECT STUFF(
	
				(SELECT ', ' + valor
				FROM tags tagsAux
				WHERE tagsAux.idPadre is null and tags.idPropiedad = idPropiedad
				FOR XML PATH ('')),
			1,1, '') ) as valor,
			idTipoDato,
			idPadre
		from tags tags 

		;with tags as(

		select 
		(Select valor from tipoobjeto.PropiedadClase where idPropiedadClase = pc.idpadre) as propiedad,
		CAST(tpc.idPropiedadClase AS VARCHAR(250)) as idPropiedad,
		pc.valor,
		idPadre,
		pc.idTipoDato
		from tipoobjeto.TipoObjetoPropiedadClase TPC
		LEFT JOIN tipoobjeto.PropiedadClase PC ON PC.idpropiedadClase = tpc.idpropiedadclase and pc.activo = 1 and pc.idClase = @idClase
		where idTipoValor ='Etiqueta'
		and idTIpoObjeto = @idTipoObjeto
		and TPC.idClase = @idClase
		
		
		UNION ALL	
		select
			prc.valor,
			tag.idPropiedad,
			tag.valor,
			prc.idPadre,
			tag.idTipoDato
		from tipoobjeto.PropiedadClase prc 
		inner join tags tag on tag.idPadre = prc.idPropiedadClase 
		WHERE prc.activo = 1


	 )

		insert into #propiedades
		select 
			propiedad,
			idPropiedad,
			(
			SELECT STUFF(
	
				(SELECT ', ' + valor
				FROM tags tagsAux
				WHERE tagsAux.idPadre is null and tags.idPropiedad = idPropiedad
				FOR XML PATH ('')),
			1,1, '') ) as valor,
			idTipoDato,
			idPadre
		from tags tags 
	
			
	
	;with fijos as(

		select 
		pg.valor propiedad,
		tpg.valor as idPropiedad,
		tpg.valor as valor,
		idPadre,
		pg.idTipoDato
		from tipoobjeto.TipoObjetoPropiedadGeneral TPG
		LEFT JOIN tipoobjeto.PropiedadGeneral PG ON PG.idpropiedadGeneral = tpg.idpropiedadGeneral and pg.activo = 1
		where idTipoValor ='Unico'
		and idTIpoObjeto = @idTipoObjeto
		and TPG.idClase = @idClase

		
		UNION ALL	
		select
			prg.valor,
			idPropiedad,
			fijo.valor,
			prg.idPadre,
			fijo.idTipoDato
		from tipoobjeto.PropiedadGeneral prg 
		inner join fijos fijo on fijo.idPadre = prg.idPropiedadGeneral
		WHERE prg.activo = 1

	 )

	 insert into #propiedades
		select 
			propiedad,
			idPropiedad,
			valor,
			idTipoDato,
			idPadre
		from fijos fijos 

	
	;with fijos as(

		select 
		pc.valor propiedad,
		tpc.valor as idPropiedad,
		tpc.valor as valor,
		idPadre,
		pc.idTipoDato
		from tipoobjeto.TipoObjetoPropiedadClase TPC
		LEFT JOIN tipoobjeto.PropiedadClase PC ON PC.idpropiedadClase = tpc.idpropiedadclase and pc.activo = 1 and pc.idClase = @idClase
		where idTipoValor ='Unico'
		and idTIpoObjeto = @idTipoObjeto
		and TPC.idClase = @idClase

		UNION ALL	
		select
			prc.valor,
			idPropiedad,
			fijo.valor,
			prc.idPadre,
			fijo.idTipoDato
		from tipoobjeto.PropiedadClase prc 
		inner join fijos fijo on fijo.idPadre = prc.idPropiedadClase 
		WHERE prc.activo = 1


	 )

		insert into #propiedades
		select 
			propiedad,
			idPropiedad,
			valor,
			idTipoDato,
			idPadre
		from fijos fijos 

	select distinct
		propiedad,
		idPropiedad,
		valor,
		idTipoDato
	from #propiedades
	where idPadre is null

	 drop table #propiedades
END

GO
