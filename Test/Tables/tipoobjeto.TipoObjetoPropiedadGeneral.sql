CREATE TABLE [tipoobjeto].[TipoObjetoPropiedadGeneral] (
		[idTipoObjeto]           [int] NOT NULL,
		[idClase]                [varchar](10) NOT NULL,
		[idPropiedadGeneral]     [int] NOT NULL,
		[valor]                  [varchar](500) NOT NULL,
		[fechaCaducidad]         [datetime] NULL,
		[idUsuario]              [int] NOT NULL
)
GO
