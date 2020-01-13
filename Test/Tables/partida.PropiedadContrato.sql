CREATE TABLE [partida].[PropiedadContrato] (
		[idPropiedadContrato]     [int] IDENTITY(1, 1) NOT NULL,
		[rfcEmpresa]              [varchar](13) NOT NULL,
		[idCliente]               [int] NOT NULL,
		[numeroContrato]          [varchar](50) NOT NULL,
		[idPadre]                 [int] NULL,
		[idTipoValor]             [varchar](10) NOT NULL,
		[idTipoDato]              [varchar](10) NOT NULL,
		[agrupador]               [varchar](250) NOT NULL,
		[valor]                   [varchar](250) NOT NULL,
		[obligatorio]             [bit] NULL,
		[orden]                   [int] NULL,
		[posicion]                [int] NULL,
		[activo]                  [bit] NOT NULL,
		[idUsuario]               [int] NOT NULL
)
GO
