CREATE TABLE [partida].[PartidaCosto] (
		[idPartida]        [int] NOT NULL,
		[idTipoObjeto]     [int] NOT NULL,
		[idClase]          [varchar](10) NOT NULL,
		[idTipoCobro]      [varchar](10) NOT NULL,
		[costo]            [float] NOT NULL,
		[idUsuario]        [int] NOT NULL
)
GO
