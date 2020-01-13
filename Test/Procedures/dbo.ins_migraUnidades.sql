
CREATE PROCEDURE ins_migraUnidades
AS

BEGIN
	DECLARE	@v_idd		numeric(18, 0),
			@v_idPropiedadClase  INT,
			@v_idPropiedadClaseAux  INT,

			@v_idTipoObjeto INT,
			@v_tipoCombustible	VARCHAR(200),
			@v_tipoUnidad		VARCHAR(200),
			@v_marca			VARCHAR(200),
			@v_submarca			VARCHAR(200),
			@v_cilindros		VARCHAR(200),
			@v_estatus			INT,
			@v_idUsuario		INT=7777

	declare @txDatos TABLE(	[idd]				[numeric](18, 0) IDENTITY(1,1) NOT NULL,
							[tipoCombustible]	[varchar](100) NULL,
							[tipoUnidad]		[varchar](100) NULL,
							[marca]				[varchar](100) NULL,
							[submarca]			[varchar](100) NULL,
							[cilindros]			[varchar](100) NULL,
							[estatus]			[smallint] NULL)
		INSERT INTO @txDatos
	SELECT	tc.tipoCombustible,
			tu.tipo,			
			mar.nombre,			
			subm.nombre,		
			cil.cilindros,		
			un.estatus			
						FROM	[192.168.20.3].partidas.dbo.Unidad un 
			INNER	JOIN  [192.168.20.3].partidas.dbo.tipoCombustible tc ON un.idTipoCombustible=tc.idTipoCombustible
			INNER	JOIN  [192.168.20.3].partidas.dbo.tipoUnidad tu		 ON un.idTipoUnidad		=tu.idTipoUnidad
			INNER   JOIN  [192.168.20.3].partidas.dbo.submarca subm		 ON un.idSubMarca		=subm.idSubMarca
			INNER   JOIN  [192.168.20.3].partidas.dbo.Marca mar			 ON subm.idMarca		=mar.idMarca 
			INNER   JOIN  [192.168.20.3].partidas.dbo.Cilindros cil		 ON cil.idCilindros		=un.idCilindros
	
	WHILE EXISTS(SELECT 1 FROM  @txDatos)
		BEGIN
												SELECT	TOP 1 
					@v_idd				= idd,
					@v_tipoCombustible	= tipoCombustible,
					@v_tipoUnidad		= tipoUnidad,	
					@v_marca			= marca,		
					@v_subMarca			= submarca,		
					@v_cilindros		= cilindros,	
					@v_estatus			= estatus		
			FROM	@txDatos

			
						
			SELECT TOP 1 @v_idPropiedadClase=idPropiedadClase
						FROM	partida.tipoobjeto.PropiedadClase 
			WHERE	agrupador	=	'Combustible' 
			AND		idTipoValor	=	'catalogo'
			AND     valor		=	@v_tipoCombustible
			AND     idPadre		IS	NOT NULL
			INSERT INTO partida.tipoobjeto.TipoObjetoPropiedadClase(idTipoObjeto,idClase,idPropiedadClase,idUsuario) VALUES(@v_idTipoObjeto,'Automovil',@v_idPropiedadClase,@v_idUsuario)
			
			
			SELECT  TOP 1 @v_idPropiedadClase=idPropiedadClase
						FROM	partida.tipoobjeto.PropiedadClase 
			WHERE	agrupador	=	'clase' 
			AND		idTipoValor	=	'catalogo'
			AND     valor		=	@v_tipoUnidad
			AND     idPadre		IS	NOT NULL
			INSERT INTO partida.tipoobjeto.TipoObjetoPropiedadClase(idTipoObjeto,idClase,idPropiedadClase,idUsuario) VALUES(@v_idTipoObjeto,'Automovil',@v_idPropiedadClase,@v_idUsuario)


			SELECT  TOP 1 @v_idPropiedadClase=idPropiedadClase
						FROM	partida.tipoobjeto.PropiedadClase 
			WHERE	agrupador	=	'Cilindros' 
			AND		idTipoValor	=	'catalogo'
			AND     valor		=	@v_cilindros
			AND     idPadre		IS	NOT NULL
			INSERT INTO partida.tipoobjeto.TipoObjetoPropiedadClase(idTipoObjeto,idClase,idPropiedadClase,idUsuario) VALUES(@v_idTipoObjeto,'Automovil',@v_idPropiedadClase,@v_idUsuario)

			SELECT  TOP 1 @v_idPropiedadClase=idPropiedadClase
						FROM	partida.tipoobjeto.PropiedadClase 
			WHERE	agrupador	=	'marca' 
			AND		idTipoValor	=	'Agrupador'
			AND     valor		=	@v_marca
			AND     idPadre		IS	NOT NULL
			INSERT INTO partida.tipoobjeto.TipoObjetoPropiedadClase(idTipoObjeto,idClase,idPropiedadClase,idUsuario) VALUES(@v_idTipoObjeto,'Automovil',@v_idPropiedadClase,@v_idUsuario)
			
			SELECT  TOP 1 @v_idPropiedadClaseAux=idPropiedadClase
						FROM	partida.tipoobjeto.PropiedadClase 
			WHERE	agrupador	=	'submarca' 
			AND		idTipoValor	=	'Agrupador'  
			AND     valor		=	@v_submarca
			AND     idPadre		=	@v_idPropiedadClase 
			INSERT INTO partida.tipoobjeto.TipoObjetoPropiedadClase(idTipoObjeto,idClase,idPropiedadClase,idUsuario) VALUES(@v_idTipoObjeto,'Automovil',@v_idPropiedadClaseAux,@v_idUsuario)
			
			DELETE FROM @txDatos WHERE idd=@v_idd
		END
END


GO
