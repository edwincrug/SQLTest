CREATE TABLE [partida].[TipoCobro] (
		[idTipoCobro]     [varchar](10) NOT NULL,
		[idClase]         [varchar](10) NOT NULL,
		[nombre]          [varchar](250) NULL,
		[descripcion]     [varchar](500) NULL,
		[activo]          [bit] NOT NULL,
		[idUsuario]       [int] NOT NULL
)
GO
