CREATE TABLE [tipoobjeto].[TipoObjetoPropiedadClase_bk] (
		[idTipoObjeto]         [int] NOT NULL,
		[idClase]              [varchar](10) NOT NULL,
		[idPropiedadClase]     [int] NOT NULL,
		[valor]                [varchar](500) NOT NULL,
		[fechaCaducidad]       [datetime] NULL,
		[idUsuario]            [int] NOT NULL
)
GO
