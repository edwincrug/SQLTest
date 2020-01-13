

CREATE PROCEDURE [tipoobjeto].[SEL_TIPOOBJETO_PORCONTRATO_SP]
	@idUsuario		int,
	@busqueda		varchar(250),
	@idClase		varchar(10),
	@contratos		XML,
		@err			VARCHAR(max) OUTPUT
AS

BEGIN
	CREATE TABLE #tbl_contratos(
	_row                    INT IDENTITY(1,1),
	rfcEmpresa				VARCHAR(13),
	idCliente				INT,
	numeroContrato			VARCHAR(100))

	CREATE TABLE #tbl_genericos(
	id				int identity not null,
	campo			varchar(100),
	idClase			varchar(10),
	tipoPropiedad	varchar(50))

	CREATE TABLE #tbl_salidaGenerica(
	id				int identity not null,
	rfcEmpresa		varchar(13),
	idCliente		int,
	numeroContrato	varchar(50),
	idObjeto		int,
	idTipoObjeto	int,
	foto			varchar(max),
	idCentroCosto	int)

	CREATE TABLE #tbl_salidaCamposObjeto(
	idObjeto		int,
	valor			varchar(500),
	propiedad		varchar(500))
	
	INSERT #tbl_contratos
	SELECT	ParamValues.col.value('rfcEmpresa[1]','varchar(13)'),
			ParamValues.col.value('idCliente[1]','int'),
			ParamValues.col.value('numeroContrato[1]','varchar(100)')
	FROM	@contratos.nodes('contratos/contrato') AS ParamValues(col)

	IF (@idClase='Automovil')
		BEGIN
			SELECT	DISTINCT
																									ix.idTipoObjeto, 
					ix.Foto,
					ix.Marca,
					ix.Submarca,
					ix.Modelo
																												FROM (
					SELECT	DISTINCT
							conobj.rfcEmpresa				rfcEmpresa,
							conobj.idCliente				idCliente,
							conobj.numeroContrato			numeroContrato,
							conobj.idObjeto					idObjeto,
							tob.idTipoObjeto				idTipoObjeto,
							ISNULL((	SELECT	[path] 
										FROM	FileServer.documento.documento 
										WHERE	idDocumento		= Objeto.objeto.getPropiedadObjeto(conobj.idObjeto,'Foto Principal','documentoGeneral',@idClase)
									),
									(	SELECT	[path] 
										FROM	FileServer.documento.documento 
										WHERE	idDocumento = Objeto.objeto.getPropiedadObjeto(tob.idTipoObjeto,'Foto','tipoGeneral',@idClase)
									)) Foto,
							Objeto.objeto.getPropiedadObjeto(tob.idTipoObjeto,'Marca','tipoClase',@idClase) as Marca,
							Objeto.objeto.getPropiedadObjeto(tob.idTipoObjeto,'Submarca','tipoClase',@idClase) as Submarca,
							Objeto.objeto.getPropiedadObjeto(tob.idTipoObjeto,'Modelo','tipoClase',@idClase) as Modelo,
							Objeto.objeto.getPropiedadObjeto(conobj.idObjeto,'VIN','Clase',@idClase) as VIN,
							Objeto.objeto.getPropiedadObjeto(conobj.idObjeto,'Placa','documentoClase',@idClase) as Placas,
							Objeto.objeto.getPropiedadObjeto(conobj.idObjeto,'Numero Economico','Contrato',@idClase) as numeroEconomico,
							conobj.idCentroCosto,
							objgen.valor 'objgen_valor',progen.valor 'progen_valor',
							objcla.valor 'objcla_valor',procla.valor 'procla_valor',
							objcon.valor 'objcon_valor',procon.valor 'procon_valor',
							patotopg.valor 'patotopg_valor',patopg.valor 'patopg_valor',
							patotopc.valor 'patotopc_valor',patocla.valor 'patocla_valor',
							objcla.activo
					FROM	Cliente.contrato.Objeto conobj 
					INNER	JOIN #tbl_contratos tbl 
					ON 		tbl.rfcEmpresa		=	conobj.rfcEmpresa
					AND		tbl.idCliente		=	conobj.idCliente 
					AND		tbl.numeroContrato	=	conobj.numeroContrato

					INNER	JOIN Objeto.objeto.Objeto obj 
					ON 		obj.idObjeto		=	conobj.idObjeto
			
					INNER	JOIN Partida.tipoobjeto.TipoObjeto tob 
					ON 		tob.idTipoObjeto	=	obj.idTipoObjeto

					INNER	JOIN CLIENTE.Cliente.Contrato con 
					ON		con.rfcEmpresa		=	tbl.rfcEmpresa
					AND		con.idCliente		=	tbl.idCliente
					AND		con.numeroContrato	=	tbl.numeroContrato
					AND		con.idClase			=	@idClase

										LEFT	JOIN Objeto.objeto.ObjetoPropiedadGeneral objgen 
					ON		objgen.idObjeto = obj.idObjeto AND objgen.activo = 1
					LEFT	JOIN Objeto.objeto.PropiedadGeneral progen 
					ON		progen.idPropiedadGeneral = objgen.idPropiedadGeneral AND progen.activo	= 1

										LEFT	JOIN Objeto.objeto.ObjetoPropiedadClase objcla 
					ON		objcla.idObjeto			= obj.idObjeto AND objcla.activo = 1
					LEFT	JOIN Objeto.objeto.PropiedadClase procla 
					ON		procla.idPropiedadClase = objcla.idPropiedadClase AND procla.activo = 1

										LEFT	JOIN Objeto.objeto.ObjetoPropiedadContrato objcon 
					ON		objcon .idObjeto	= obj.idObjeto AND objcon.activo = 1
					LEFT	JOIN Objeto.objeto.PropiedadContrato procon 
					ON		procon.idPropiedadContrato = objcon.idPropiedadContrato and procon.activo = 1

										LEFT	JOIN partida.tipoobjeto.tipoObjetoPropiedadGeneral patotopg 
					ON		patotopg.idtipoObjeto		= obj.idTipoObjeto 
			
					LEFT	JOIN partida.tipoobjeto.PropiedadGeneral patopg 
					ON		patopg.idPropiedadGeneral	= patotopg.idPropiedadGeneral 
					
										LEFT	JOIN partida.tipoobjeto.tipoobjetoPropiedadClase patotopc 
					ON		patotopc.idtipoObjeto		= obj.idtipoObjeto 

					LEFT	JOIN partida.tipoobjeto.PropiedadClase patocla 
					ON		patocla.idPropiedadClase	= patotopc.idPropiedadClase  

					WHERE	con.idClase		= @idClase
					AND		obj.activo		= 1
					AND		con.activo		= 1
					AND		conobj.activo	= 1)ix
		WHERE 
			(
				(ix.objgen_valor like '%' + @busqueda + '%' or ix.progen_valor like '%' + @busqueda + '%') OR
				(ix.objcla_valor like '%' + @busqueda + '%' or ix.procla_valor like '%' + @busqueda + '%') OR
				(ix.objcon_valor like '%' + @busqueda + '%' or ix.procon_valor like '%' + @busqueda + '%') 
			) OR
			(
				(ix.patotopg_valor like '%' + @busqueda + '%' or ix.patopg_valor like '%' + @busqueda + '%') OR 
				(ix.patotopc_valor like '%' + @busqueda + '%' or ix.patocla_valor like '%' + @busqueda + '%')OR
				(ix.Marca		   like '%' + @busqueda + '%')
			) 
		END
	ELSE
		BEGIN
			DECLARE @i INT = 1,	@j INT = 1
			INSERT INTO #tbl_genericos
			SELECT * FROM Common.objeto.BannerGenerico WHERE idClase = @idClase		

						INSERT INTO #tbl_salidaGenerica
			SELECT	DISTINCT
					conobj.rfcEmpresa				rfcEmpresa,
					conobj.idCliente				idCliente,
					conobj.numeroContrato			numeroContrato,
					conobj.idObjeto				idObjeto,
					tob.idTipoObjeto				idTipoObjeto,
					ISNULL((SELECT	[path] 
							FROM	FileServer.documento.documento 
							WHERE	idDocumento		= Objeto.objeto.getPropiedadObjeto(conobj.idObjeto,'Foto Principal','documentoGeneral',@idClase)),
						   (SELECT	[path] 
							FROM	FileServer.documento.documento 
							WHERE	idDocumento		= Objeto.objeto.getPropiedadObjeto(tob.idTipoObjeto,'Foto','tipoGeneral',@idClase))) Foto,
					conobj.idCentroCosto
			FROM	Cliente.contrato.Objeto conobj
			INNER	JOIN #tbl_contratos tbl 
			ON		tbl.rfcEmpresa		=	conobj.rfcEmpresa
			AND		tbl.idCliente		=	conobj.idCliente 
			AND		tbl.numeroContrato	=	conobj.numeroContrato
			
			INNER	JOIN Objeto.objeto.Objeto obj 
			ON		obj.idObjeto			=	conobj.idObjeto
			
			INNER	JOIN Partida.tipoobjeto.TipoObjeto tob 
			ON		tob.idTipoObjeto		=	obj.idTipoObjeto

			INNER JOIN Cliente.Contrato con 
			ON		con.rfcEmpresa			=	tbl.rfcEmpresa
			AND		con.idCliente			=	tbl.idCliente
			AND		con.numeroContrato		=	tbl.numeroContrato
			AND		con.idClase				=	@idClase
	
						LEFT	JOIN Objeto.objeto.ObjetoPropiedadGeneral objgen 
			ON		objgen.idObjeto = obj.idObjeto and objgen.activo = 1
			LEFT	JOIN Objeto.objeto.PropiedadGeneral progen 
			ON		progen.idPropiedadGeneral = objgen.idPropiedadGeneral and progen.activo = 1


						LEFT	JOIN Objeto.objeto.ObjetoPropiedadClase objcla 
			ON		objcla.idObjeto			= obj.idObjeto 
			AND		objcla.activo			= 1
			LEFT	JOIN Objeto.objeto.PropiedadClase procla 
			ON		procla.idPropiedadClase = objcla.idPropiedadClase 
			AND		procla.activo			= 1

						LEFT	JOIN Objeto.objeto.ObjetoPropiedadContrato objcon 
			ON		objcon .idObjeto			= obj.idObjeto 
			AND		objcon.activo				= 1
			
			LEFT	JOIN Objeto.objeto.PropiedadContrato procon 
			ON		procon.idPropiedadContrato	= objcon.idPropiedadContrato 
			AND		procon.activo				= 1

						LEFT	JOIN Objeto.documento.DocumentoObjetoGeneral docgen 
			ON		docgen.idObjeto				= obj.idObjeto
			
			LEFT	JOIN Objeto.documento.DocumentoGeneral prodocgen 
			ON		prodocgen.idDocumentoGeneral= docgen.idDocumentoGeneral 
			AND		prodocgen.activo			= 1

						LEFT	JOIN Objeto.documento.DocumentoObjetoClase doccla 
			ON		doccla.idObjeto				= obj.idObjeto
			
			LEFT	JOIN Objeto.documento.DocumentoClase prodoccla 
			ON		prodoccla.idDocumentoClase	= doccla.idDocumentoClase 
			AND		prodoccla.activo			= 1

						LEFT	JOIN Objeto.documento.DocumentoObjetoContrato doccon 
			ON		doccon.idObjeto = obj.idObjeto

			LEFT	JOIN Objeto.documento.DocumentoContrato prodoccon 
			ON		prodoccon.idDocumentoContrato = doccon.idDocumentoContrato 
			AND		prodoccon.activo = 1
	
			WHERE 
			(
				(objgen.valor LIKE '%' + @busqueda + '%' OR progen.valor LIKE '%' + @busqueda + '%') OR
				(objcla.valor LIKE '%' + @busqueda + '%' OR procla.valor LIKE '%' + @busqueda + '%') OR
				(objcon.valor LIKE '%' + @busqueda + '%' OR procon.valor LIKE '%' + @busqueda + '%') 
			) OR
			(
				(docgen.valor LIKE '%' + @busqueda + '%' OR prodocgen.valor LIKE '%' + @busqueda + '%') OR
				(doccla.valor LIKE '%' + @busqueda + '%' OR prodoccla.valor LIKE '%' + @busqueda + '%') OR
				(doccon.valor LIKE '%' + @busqueda + '%' OR prodoccon.valor LIKE '%' + @busqueda + '%')
			)
			AND 
			objcla.activo = 1

			SET @i = 0
			SET @j = 0
			WHILE (@i<(SELECT COUNT(1) FROM #tbl_salidaGenerica))
				BEGIN
					WHILE (@j<(SELECT COUNT(1) FROM #tbl_genericos))
						BEGIN
							INSERT INTO #tbl_salidaCamposObjeto
							SELECT	idObjeto,
									Objeto.objeto.getPropiedadObjeto(s.idObjeto,g.campo,g.tipoPropiedad,@idClase) valor,
									g.campo AS Propiedad
							FROM	#tbl_salidaGenerica s,
									#tbl_genericos g
							WHERE	s.id = @i+1 and 
									g.id=@j +1
						
							SET @j = @j+1
						END
					SET @j = 0
					SET @i = @i+1			
				END

			DECLARE @columnsName VARCHAR(MAX) = ''
			SET @columnsName = STUFF((	SELECT DISTINCT ',' + QUOTENAME(prg.propiedad) 
										FROM #tbl_salidaCamposObjeto prg
										FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'') 
	
			DECLARE @query VARCHAR(MAX) = '
		
			select * from (
			select 
				s.rfcEmpresa,
				s.idCliente,
				s.numeroContrato,
				s.idObjeto,
				s.idTipoObjeto,
				s.foto,
				s.idCentroCosto,
				o.valor,
				o.propiedad
			from #tbl_salidaGenerica s
			inner join #tbl_salidaCamposObjeto o on s.idObjeto = o.idObjeto
			) res		
			pivot (
				max(valor) FOR propiedad in (' + @columnsName +' )
			) as Resultado'
		
			EXECUTE (@query)
	END
	
	SELECT [campo] FROM [Common].[objeto].[BannerGenerico]
	WHERE [idClase] = @idClase
END
GO
