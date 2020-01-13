CREATE  PROCEDURE [partida].[SEL_PARTIDACONTRATO_DINAMICOBYID_SP] 
	@idPartida				int,
	@idClase				VARCHAR(10),
	@idUsuario				INT,
	@rfc					varchar(13),
	@idCliente				int,
	@numeroContrato			varchar(50),
	@err					nvarchar(500)OUTPUT
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
		(Select valor from partida.PropiedadGeneral where idPropiedadGeneral = pg.idpadre) as propiedad,
		CAST(TPG.idPropiedadGeneral AS VARCHAR(250)) as idPropiedad,
		pg.valor,
		idPadre,
		pg.idTipoDato
		from partida.PartidaContratoPropiedadGeneral TPG
		LEFT JOIN partida.PropiedadGeneral PG ON PG.idpropiedadGeneral = TPG.idpropiedadGeneral AND pg.activo = 1
		where idTipoValor in  ('Catalogo','Agrupador')
		and TPG.idPartidaContrato = @idPartida
		and TPG.idClase = @idClase
		and TPG.rfcEmpresa = @rfc
		and TPG.idCliente = @idCLiente
		and TPG.numeroContrato = @numeroContrato

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
		from partida.PartidaContratoPropiedadClase TPC
		LEFT JOIN partida.PropiedadClase PC ON PC.idpropiedadClase = tpc.idpropiedadclase AND pc.activo = 1 and pc.idClase = @idClase
		where idTipoValor in  ('Catalogo','Agrupador')
		and TPC.idPartidaContrato = @idPartida
		and TPC.idClase = @idClase
		and TPC.rfcEmpresa = @rfc
		and TPC.idCliente = @idCLiente
		and TPC.numeroContrato = @numeroContrato

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
		from partida.PartidaContratoPropiedadContrato TPC
		LEFT JOIN partida.PropiedadContrato PC ON PC.idPropiedadContrato = tpc.idPropiedadContrato AND pc.activo = 1 and pc.numeroContrato = @numeroContrato and pc.idCliente = @idCLiente
		where idTipoValor in  ('Catalogo','Agrupador')
		and TPC.idPartidaContrato = @idPartida
		and TPC.idClase = @idClase
		and TPC.rfcEmpresa = @rfc
		and TPC.idCliente = @idCLiente
		and TPC.numeroContrato = @numeroContrato

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
		from partida.PartidaContratoPropiedadGeneral TPG
		LEFT JOIN partida.PropiedadGeneral PG ON PG.idpropiedadGeneral = tpg.idpropiedadGeneral AND pg.activo = 1 
		where idTipoValor ='Etiqueta'
		and TPG.idPartidaContrato = @idPartida
		and TPG.idClase = @idClase
		and TPG.rfcEmpresa = @rfc
		and TPG.idCliente = @idCLiente
		and TPG.numeroContrato = @numeroContrato

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
				WHERE tagsAux.idPadre is null 
				AND tags.idPropiedad = idPropiedad
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
		from partida.PartidaContratoPropiedadClase TPC
		LEFT JOIN partida.PropiedadClase PC ON PC.idpropiedadClase = tpc.idpropiedadclase AND pc.activo = 1 and pc.idClase = @idClase 
		where idTipoValor ='Etiqueta'
		and TPC.idPartidaContrato = @idPartida
		and TPC.idClase = @idClase
		and TPC.rfcEmpresa = @rfc
		and TPC.idCliente = @idCLiente
		and TPC.numeroContrato = @numeroContrato
		
		
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
				WHERE tagsAux.idPadre is null 
				AND tags.idPropiedad = idPropiedad
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
		from partida.PartidaContratoPropiedadContrato TPC
		LEFT JOIN partida.PropiedadContrato PC ON PC.idpropiedadContrato = tpc.idPropiedadContrato AND pc.activo = 1 and pc.numeroContrato = @numeroContrato and pc.idCliente = @idCLiente
		where idTipoValor ='Etiqueta'
		and TPC.idPartidaContrato = @idPartida
		and TPC.idClase = @idClase
		and TPC.rfcEmpresa = @rfc
		and TPC.idCliente = @idCLiente
		and TPC.numeroContrato = @numeroContrato
		
		
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
				AND tags.idPropiedad = idPropiedad
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
		from partida.PartidaContratoPropiedadGeneral TPG
		LEFT JOIN partida.PropiedadGeneral PG ON PG.idpropiedadGeneral = tpg.idpropiedadGeneral AND pg.activo = 1
		where idTipoValor ='Unico'
		and TPG.idPartidaContrato = @idPartida
		and TPG.idClase = @idClase
		and TPG.rfcEmpresa = @rfc
		and TPG.idCliente = @idCLiente
		and TPG.numeroContrato = @numeroContrato
		
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
		from partida.PartidaContratoPropiedadClase TPC
		LEFT JOIN partida.PropiedadClase PC ON PC.idpropiedadClase = tpc.idpropiedadclase AND pc.activo = 1 and pc.idClase = @idClase 
		where idTipoValor ='Unico'
		and TPC.idPartidaContrato = @idPartida
		and TPC.idClase = @idClase
		and TPC.rfcEmpresa = @rfc
		and TPC.idCliente = @idCLiente
		and TPC.numeroContrato = @numeroContrato

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
		from partida.PartidaContratoPropiedadContrato TPC
		LEFT JOIN partida.PropiedadContrato PC ON PC.idPropiedadContrato = tpc.idPropiedadContrato AND pc.activo = 1 and pc.numeroContrato = @numeroContrato and pc.idCliente = @idCLiente
		where idTipoValor ='Unico'
		and TPC.idPartidaContrato = @idPartida
		and TPC.idClase = @idClase
		and TPC.rfcEmpresa = @rfc
		and TPC.idCliente = @idCLiente
		and TPC.numeroContrato = @numeroContrato

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
