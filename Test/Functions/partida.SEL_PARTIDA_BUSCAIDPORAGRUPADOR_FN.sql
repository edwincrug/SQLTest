CREATE FUNCTION [partida].[SEL_PARTIDA_BUSCAIDPORAGRUPADOR_FN]
(
	@idTipoObjeto				int,
	@idPartida					int,
	@idClase					varchar(10),
	@agrupador					varchar(250),
	@idTipoValor				varchar(10)
)
RETURNS INT
AS

BEGIN
	DECLARE @idPropiedad as int
	
	if (@idTipoValor = 'General')
	BEGIN
		;with catalogos as(
		select
			tob.idTipoObjeto				idTipoObjeto,
			prc.agrupador					agrupador, 
			isnull(prc.valor,'')			valor,
			prc.idPadre						idPadre,
			tpc.idPropiedadGeneral			idPropiedadGeneral,
			prc.orden						orden,
			prc.posicion					posicion,
			1								ordenFinal
		from tipoobjeto.tipoobjeto tob
		inner join partida.Partida par on tob.idTipoObjeto =par.idTipoObjeto 	
		inner join partida.PartidaPropiedadGeneral tpc on tob.idTipoObjeto = tpc.idTipoObjeto
		inner join partida.PropiedadGeneral prc on tpc.idPropiedadGeneral = prc.idPropiedadGeneral
		where 
			prc.idTipoValor in ('Catalogo','Agrupador') 
			and tob.idClase = @idClase
			and tob.activo = 1
			and tob.idTipoObjeto = @idTipoObjeto
			and par.idPartida = @idPartida
		UNION ALL	
				select
			cat.idTipoObjeto				idTipoObjeto,
			prc.agrupador					agrupador, 
			isnull(prc.valor,'')			valor,
			prc.idPadre						idPadre,
			cat.idPropiedadGeneral			idPropiedadGeneral,
			prc.orden						orden,
			prc.posicion					posicion,
			1								ordenFinal
		from partida.PropiedadGeneral prc 
		inner join catalogos cat on cat.idPadre = prc.idPropiedadGeneral
		WHERE prc.activo = 1
		)
		select 
			@idPropiedad = idPropiedadGeneral
		from catalogos cat 
		where 
			idPadre is not null 
			and cat.agrupador = @agrupador
	
	END
	ELSE IF (@idTipoValor = 'Clase')
	BEGIN
		;with catalogos as(
		select
			tob.idTipoObjeto				idTipoObjeto,
			prc.agrupador					agrupador, 
			isnull(prc.valor,'')			valor,
			prc.idPadre						idPadre,
			tpc.idPropiedadClase			idPropiedadClase,
			prc.orden						orden,
			prc.posicion					posicion,
			1								ordenFinal
		from tipoobjeto.tipoobjeto tob
		inner join partida.Partida par on tob.idTipoObjeto =par.idTipoObjeto 	
		inner join partida.PartidaPropiedadClase tpc on tob.idTipoObjeto = tpc.idTipoObjeto
		inner join partida.PropiedadClase prc on tpc.idPropiedadClase = prc.idPropiedadClase
		where 
			prc.idTipoValor in ('Catalogo','Agrupador') 
			and tob.idClase = @idClase
			and tob.activo = 1
			and tob.idTipoObjeto = @idTipoObjeto
			and par.idPartida = @idPartida
		UNION ALL	
				select
			cat.idTipoObjeto				idTipoObjeto,
			prc.agrupador					agrupador, 
			isnull(prc.valor,'')			valor,
			prc.idPadre						idPadre,
			cat.idPropiedadClase			idPropiedadClase,
			prc.orden						orden,
			prc.posicion					posicion,
			1								ordenFinal
		from partida.PropiedadClase prc 
		inner join catalogos cat on cat.idPadre = prc.idPropiedadClase 
		WHERE prc.activo = 1
		)
		select 
			@idPropiedad = idPropiedadClase
		from catalogos cat 
		where 
			idPadre is not null 
			and cat.agrupador = @agrupador
	END
	ELSE IF (@idTipoValor = 'Contrato')
	BEGIN
		;with catalogos as(
		select
			tob.idTipoObjeto				idTipoObjeto,
			prc.agrupador					agrupador, 
			isnull(prc.valor,'')			valor,
			prc.idPadre						idPadre,
			tpc.idPropiedadContrato			idPropiedadContrato,
			prc.orden						orden,
			prc.posicion					posicion,
			1								ordenFinal
		from tipoobjeto.tipoobjeto tob
		inner join partida.Partida par on tob.idTipoObjeto =par.idTipoObjeto 	
		inner join partida.PartidaPropiedadContrato tpc on tob.idTipoObjeto = tpc.idTipoObjeto
		inner join partida.PropiedadClase prc on tpc.idPropiedadContrato = prc.idPropiedadClase
		where 
			prc.idTipoValor in ('Catalogo','Agrupador') 
			and tob.idClase = @idClase
			and tob.activo = 1
			and tob.idTipoObjeto = @idTipoObjeto
			and par.idPartida = @idPartida
		UNION ALL	
				select
			cat.idTipoObjeto				idTipoObjeto,
			prc.agrupador					agrupador, 
			isnull(prc.valor,'')			valor,
			prc.idPadre						idPadre,
			cat.idPropiedadContrato			idPropiedadClase,
			prc.orden						orden,
			prc.posicion					posicion,
			1								ordenFinal
		from partida.PropiedadClase prc 
		inner join catalogos cat on cat.idPadre = prc.idPropiedadClase 
		WHERE prc.activo = 1
		)
		select 
			@idPropiedad = idPropiedadContrato
		from catalogos cat 
		where 
			idPadre is not null 
			and cat.agrupador = @agrupador
	END

		RETURN @idPropiedad
END
GO
