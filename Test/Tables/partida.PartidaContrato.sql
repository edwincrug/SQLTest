CREATE TABLE [partida].[PartidaContrato] (
		[idPartidaContrato]     [int] IDENTITY(1, 1) NOT NULL,
		[idTipoObjeto]          [int] NOT NULL,
		[idClase]               [varchar](10) NOT NULL,
		[rfcEmpresa]            [varchar](13) NOT NULL,
		[idCliente]             [int] NOT NULL,
		[numeroContrato]        [varchar](50) NOT NULL,
		[activo]                [bit] NOT NULL,
		[idUsuario]             [int] NOT NULL
)
GO
