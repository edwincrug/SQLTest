CREATE TABLE [tipoobjeto].[TipoObjeto] (
		[idTipoObjeto]     [int] IDENTITY(1, 1) NOT NULL,
		[idClase]          [varchar](10) NOT NULL,
		[activo]           [bit] NOT NULL,
		[idUsuario]        [int] NOT NULL
)
GO
