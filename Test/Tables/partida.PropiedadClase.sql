CREATE TABLE [partida].[PropiedadClase] (
		[idPropiedadClase]     [int] IDENTITY(1, 1) NOT NULL,
		[idClase]              [varchar](10) NOT NULL,
		[idPadre]              [int] NULL,
		[idTipoValor]          [varchar](10) NOT NULL,
		[idTipoDato]           [varchar](10) NOT NULL,
		[agrupador]            [varchar](250) NOT NULL,
		[valor]                [varchar](500) NOT NULL,
		[obligatorio]          [bit] NULL,
		[orden]                [int] NULL,
		[posicion]             [int] NULL,
		[activo]               [bit] NOT NULL,
		[idUsuario]            [int] NOT NULL
)
GO
