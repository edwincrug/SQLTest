
CREATE PROCEDURE partida.INS_MIGRAPARTIDAS
AS

BEGIN
	DECLARE	@v_idd		numeric(18, 0),
			@v_idUnidad numeric(18, 0),
			@v_idTipoPartida numeric(18, 0),
			@v_tipoPartida varchar(100),
			@v_idEspecialidad numeric(18, 0),
			@v_especialidad varchar(100),
			
			@v_idPartidaClasificacion numeric(18, 0),
			@v_partidaClasificacion varchar(100),

			@v_partida nvarchar(50),
			@v_marca nvarchar(200),
			@v_noParte nvarchar(200),
			@v_descripcion nvarchar(max),
			@v_foto nvarchar(500),
			@v_instructivo nvarchar(500),
			@v_idPropiedadClase  INT

	declare @txDatos TABLE(	[idd]			[numeric](18, 0) IDENTITY(1,1) NOT NULL,
							[idPartida]		[numeric](18, 0)NULL,
							[idUnidad]		[numeric](18, 0) NULL,
							[tipoPartida]   [varchar](100) NULL,
							[especialidad]	[varchar](100) NULL,
							[partidaClasificacion] [varchar](100) NULL,
							[idPartidaSubClasificacion] [numeric](18, 0) NULL,
							[partida] [nvarchar](50) NULL,
							[marca] [nvarchar](200),
							[noParte] [nvarchar](200) NOT NULL,
							[descripcion] [nvarchar](max) NULL,
							[foto] [nvarchar](500) NULL,
							[instructivo] [nvarchar](500) NULL,
							[estatus] [smallint] NULL)
		INSERT INTO @txDatos
	SELECT	TOP 5 
			part.idPartida,
			part.idUnidad,
			tipp.tipoPartida,
			espe.especialidad,
			pacl.clasificacion,
			part.idPartidaSubClasificacion,
			part.partida,
			part.marca,
			part.noParte,
			part.descripcion,
			part.foto,
			part.instructivo,
			part.estatus
	FROM [192.168.20.3].partidas.dbo.Partida part 
	INNER	JOIN  [192.168.20.3].partidas.dbo.especialidad espe			ON part.idEspecialidad			= espe.idEspecialidad
	INNER	JOIN  [192.168.20.3].partidas.dbo.tipoPartida tipp			ON part.idTipoPartida			= tipp.idTipoPartida
	INNER   JOIN  [192.168.20.3].partidas.dbo.partidaClasificacion pacl ON part.idPartidaClasificacion	= pacl.idPartidaClasificacion
	WHERE idPartida not in(SELECT idPartida FROM partida.partida.partida )

		
	SELECT * FROM @txDatos

			
	WHILE EXISTS(SELECT 1 FROM  @txDatos)
		BEGIN
			SELECT	TOP 1 
					@v_idd					=idd,
					@v_idUnidad				=idUnidad,
					@v_tipoPartida			=tipoPartida,
					@v_especialidad			=especialidad,
					@v_partidaClasificacion		=partidaClasificacion,
					@v_partida					=partida,
					@v_marca					=marca,
					@v_noParte					=noParte,
					@v_descripcion				=descripcion,
					@v_foto						=foto,
					@v_instructivo				=instructivo
			FROM	@txDatos

												SELECT	TOP 1 @v_idPropiedadClase=idPropiedadClase 
			FROM	partida.PropiedadClase 
			WHERE	agrupador	=	'Tipo de partida'
			AND     idTipoValor	=	'Catalogo' 
			AND		valor		=	@v_tipoPartida
			PRINT '@v_idPropiedadClase=>'+CAST(@v_idPropiedadClase AS VARCHAR)+' @v_tipoPartida=>'+@v_tipoPartida
			
			SELECT	TOP 1 @v_idPropiedadClase=idPropiedadClase 
			FROM	partida.PropiedadClase 
			WHERE	agrupador	=	'Especialidad' 
			AND     idTipoValor	=	'Catalogo' 
			AND		valor		=	@v_especialidad
			PRINT '@v_idPropiedadClase=>'+CAST(@v_idPropiedadClase AS VARCHAR)+' @v_especialidad=>'+@v_especialidad

			SELECT	TOP 1 @v_idPropiedadClase=idPropiedadClase 
			FROM	partida.PropiedadClase 
			WHERE	agrupador	=	'Clasificación' 
			AND     idTipoValor	=	'Agrupador' 
			AND		valor		=	@v_partidaClasificacion
			PRINT '@v_idPropiedadClase=>'+CAST(@v_idPropiedadClase AS VARCHAR)+' @v_partidaClasificacion=>'+@v_partidaClasificacion

									
			SELECT	tc.tipoCombustible,
					tu.tipo 'TipoUnidad' ,
					mar.nombre 'Marca',
					subm.nombre 'SubMarca',
					cil.cilindros,
					un.estatus 
			FROM	[192.168.20.3].partidas.dbo.Unidad un 
			INNER	JOIN  [192.168.20.3].partidas.dbo.tipoCombustible tc ON un.idTipoCombustible=tc.idTipoCombustible
			INNER	JOIN  [192.168.20.3].partidas.dbo.tipoUnidad tu		 ON un.idTipoUnidad		=tu.idTipoUnidad
			INNER   JOIN  [192.168.20.3].partidas.dbo.submarca subm		 ON un.idSubMarca		=subm.idSubMarca
			INNER   JOIN  [192.168.20.3].partidas.dbo.Marca mar			 ON subm.idMarca		=mar.idMarca 
			INNER   JOIN  [192.168.20.3].partidas.dbo.Cilindros cil		 ON cil.idCilindros		=un.idCilindros
 			where un.idUnidad=10

			SELECT *
			FROM	tipoobjeto.PropiedadClase WHERE agrupador	=	'Combustible' 
			AND     idTipoValor	=	'Catalogo' 

			SELECT *
			FROM	tipoobjeto.PropiedadClase WHERE agrupador	=	'Clase' 
			AND     idTipoValor	=	'Catalogo' 
			
			SELECT *
			FROM	tipoobjeto.PropiedadClase WHERE idTipoValor	=	'Catalogo'  
			AND		agrupador	=	'Clase' 



			SELECT  idPropiedadClase
			FROM	tipoobjeto.PropiedadClase WHERE agrupador	=	'marca' 
			AND		idTipoValor	=	'Agrupador'
			AND     valor='INTERNATIONAL'
			
			SELECT *
			FROM	tipoobjeto.PropiedadClase WHERE agrupador	=	'submarca' 
			AND		idTipoValor	=	'Agrupador'  
			AND     valor='PROSTAR / SERIE 9000'
			AND     idPadre=1681
			

					END
		PRINT 'SALIDA'
END
GO
