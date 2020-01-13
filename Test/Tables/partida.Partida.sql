CREATE TABLE [partida].[Partida] (
		[idPartida]        [int] IDENTITY(1, 1) NOT NULL,
		[idTipoObjeto]     [int] NOT NULL,
		[idClase]          [varchar](10) NOT NULL,
		[activo]           [bit] NOT NULL,
		[idUsuario]        [int] NOT NULL
)
GO
