CREATE TABLE [partida].[PartidaContratoPropiedadContrato] (
		[idPartidaContrato]       [int] NOT NULL,
		[idTipoObjeto]            [int] NOT NULL,
		[idClase]                 [varchar](10) NOT NULL,
		[rfcEmpresa]              [varchar](13) NOT NULL,
		[idCliente]               [int] NOT NULL,
		[numeroContrato]          [varchar](50) NOT NULL,
		[idPropiedadContrato]     [int] NOT NULL,
		[valor]                   [varchar](500) NOT NULL,
		[fechaCaducidad]          [datetime] NULL,
		[idUsuario]               [int] NOT NULL
)
GO
