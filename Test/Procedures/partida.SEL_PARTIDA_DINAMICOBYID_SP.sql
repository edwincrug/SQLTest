CREATE  PROCEDURE [partida].[SEL_PARTIDA_DINAMICOBYID_SP] 
	@idPartida				int,
	@idUsuario				INT,
	@idClase				VARCHAR(10),
	@err					nvarchar(500)OUTPUT
AS


BEGIN

create table #propiedades(
	propiedad		varchar(MAX),
	idPropiedad		varchar(MAX),
	valor			varchar(MAX),
	idTipoDato		varchar(250),
	idPadre			int
)


	;with catalogos as(
		select 
		(Select valor from partida.PropiedadGeneral where idPropiedadGeneral = pg.idpadre) as propiedad,
		CAST(TPG.idPropiedadGeneral AS VARCHAR(250)) as idPropiedad,
		pg.valor,
		idPadre,
		pg.idTipoDato
		from partida.PartidaPropiedadGeneral TPG
		LEFT JOIN partida.PropiedadGeneral PG ON PG.idpropiedadGeneral = TPG.idpropiedadGeneral and pg.activo = 1 
		where idTipoValor in  ('Catalogo','Agrupador')
		and TPG.idPartida = @idPartida
		AND TPG.idClase = @idClase

		UNION ALL	
		select
			prg.valor,
			cat.idPropiedad,
			cat.valor,
			prg.idPadre,
			cat.idTipoDato
		from partida.PropiedadGeneral prg 
		inner join catalogos cat on cat.idPadre = prg.idPropiedadGeneral
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
		(Select valor from partida.PropiedadClase where idPropiedadClase = pc.idpadre) as propiedad,
		CAST(tpc.idPropiedadClase AS VARCHAR(250)) as idPropiedad,
		pc.valor,
		idPadre,
		pc.idTipoDato
		from partida.PartidaPropiedadClase TPC
		LEFT JOIN partida.PropiedadClase PC ON PC.idpropiedadClase = tpc.idpropiedadclase and pc.activo = 1
		where idTipoValor in  ('Catalogo','Agrupador')
		and TPC.idPartida = @idPartida
		AND TPC.idClase = @idClase
		
		UNION ALL	
			select
			prc.valor,
			cat.idPropiedad,
			cat.valor,
			prc.idPadre,
			cat.idTipoDato
		from partida.PropiedadClase prc 
		inner join catalogos cat on cat.idPadre = prc.idPropiedadClase 
		

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
		(Select valor from partida.PropiedadContrato where idPropiedadContrato = pc.idpadre) as propiedad,
		CAST(tpc.idPropiedadContrato AS VARCHAR(250)) as idPropiedad,
		pc.valor,
		idPadre,
		pc.idTipoDato
		from partida.PartidaPropiedadContrato TPC
		LEFT JOIN partida.PropiedadContrato PC ON PC.idpropiedadContrato = tpc.idPropiedadContrato and pc.activo = 1
		where idTipoValor in  ('Catalogo','Agrupador')
		and TPC.idPartida = @idPartida
		AND TPC.idClase = @idClase
		
		UNION ALL	
			select
			prc.valor,
			cat.idPropiedad,
			cat.valor,
			prc.idPadre,
			cat.idTipoDato
		from partida.PropiedadContrato prc 
		inner join catalogos cat on cat.idPadre = prc.idPropiedadContrato 
		

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
		(Select valor from partida.PropiedadGeneral where idPropiedadGeneral = pg.idpadre) as propiedad,
		CAST(tpg.idPropiedadGeneral AS VARCHAR(250)) as idPropiedad,
		pg.valor,
		idPadre,
		pg.idTipoDato
		from partida.PartidaPropiedadGeneral TPG
		LEFT JOIN partida.PropiedadGeneral PG ON PG.idpropiedadGeneral = tpg.idpropiedadGeneral and pg.activo = 1
		where idTipoValor ='Etiqueta'
		and TPG.idPartida = @idPartida
		and TPG.idClase = @idClase
		
		UNION ALL	
		select
			prg.valor,
			tag.idPropiedad,
			tag.valor,
			prg.idPadre,
			tag.idTipoDato
		from partida.PropiedadGeneral prg 
		inner join tags tag on tag.idPadre = prg.idPropiedadGeneral
		
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
		(Select valor from partida.PropiedadClase where idPropiedadClase = pc.idpadre) as propiedad,
		CAST(tpc.idPropiedadClase AS VARCHAR(250)) as idPropiedad,
		pc.valor,
		idPadre,
		pc.idTipoDato
		from partida.PartidaPropiedadClase TPC
		LEFT JOIN partida.PropiedadClase PC ON PC.idpropiedadClase = tpc.idpropiedadclase and pc.activo = 1
		where idTipoValor ='Etiqueta'
		and TPC.idPartida = @idPartida
		AND TPC.idClase = @idClase
				
		
		UNION ALL	
		select
			prc.valor,
			tag.idPropiedad,
			tag.valor,
			prc.idPadre,
			tag.idTipoDato
		from partida.PropiedadClase prc 
		inner join tags tag on tag.idPadre = prc.idPropiedadClase 
		

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
		(Select valor from partida.PropiedadContrato where idPropiedadContrato = pc.idpadre) as propiedad,
		CAST(tpc.idPropiedadContrato AS VARCHAR(250)) as idPropiedad,
		pc.valor,
		idPadre,
		pc.idTipoDato
		from partida.PartidaPropiedadContrato TPC
		LEFT JOIN partida.PropiedadContrato PC ON PC.idPropiedadContrato = tpc.idPropiedadContrato and pc.activo = 1
		where idTipoValor ='Etiqueta'
		and TPC.idPartida = @idPartida
		AND TPC.idClase = @idClase
				
		
		UNION ALL	
		select
			prc.valor,
			tag.idPropiedad,
			tag.valor,
			prc.idPadre,
			tag.idTipoDato
		from partida.PropiedadContrato prc 
		inner join tags tag on tag.idPadre = prc.idPropiedadContrato 
		

	 )

		insert into #propiedades
		select 
			propiedad,
			idPropiedad,
			(
			SELECT STUFF(
	
				(SELECT ', ' + valor
				FROM tags tagsAux
				WHERE tagsAux.idPadre is null 
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
		from partida.PartidaPropiedadGeneral TPG
		LEFT JOIN partida.PropiedadGeneral PG ON PG.idpropiedadGeneral = tpg.idpropiedadGeneral and pg.activo = 1
		where idTipoValor ='Unico'
		and TPG.idPartida = @idPartida
		AND TPG.idClase = @idClase
		
		
		UNION ALL	
		select
			prg.valor,
			idPropiedad,
			fijo.valor,
			prg.idPadre,
			fijo.idTipoDato
		from partida.PropiedadGeneral prg 
		inner join fijos fijo on fijo.idPadre = prg.idPropiedadGeneral
		
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
		from partida.PartidaPropiedadClase TPC
		LEFT JOIN partida.PropiedadClase PC ON PC.idpropiedadClase = tpc.idpropiedadclase and pc.activo = 1
		where idTipoValor ='Unico'
		and TPC.idPartida = @idPartida
		AND TPC.idClase = @idClase
		
		UNION ALL	
		select
			prc.valor,
			idPropiedad,
			fijo.valor,
			prc.idPadre,
			fijo.idTipoDato
		from partida.PropiedadClase prc 
		inner join fijos fijo on fijo.idPadre = prc.idPropiedadClase 
		

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
		from partida.PartidaPropiedadContrato TPC
		LEFT JOIN partida.PropiedadContrato PC ON PC.idPropiedadContrato = tpc.idPropiedadContrato and pc.activo = 1
		where idTipoValor ='Unico'
		and TPC.idPartida = @idPartida
		AND TPC.idClase = @idClase
		
		UNION ALL	
		select
			prc.valor,
			idPropiedad,
			fijo.valor,
			prc.idPadre,
			fijo.idTipoDato
		from partida.PropiedadContrato prc 
		inner join fijos fijo on fijo.idPadre = prc.idPropiedadContrato  
		

	 )

		insert into #propiedades
		select 
			propiedad,
			idPropiedad,
			valor,
			idTipoDato,
			idPadre
		from fijos fijos 

	select 
		propiedad,
		idPropiedad,
		valor,
		idTipoDato
	from #propiedades
	where idPadre is null

	 drop table #propiedades
END

GO
