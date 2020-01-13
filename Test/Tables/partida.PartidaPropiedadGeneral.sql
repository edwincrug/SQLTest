CREATE TABLE [partida].[PartidaPropiedadGeneral] (
		[idPartida]              [int] NOT NULL,
		[idTipoObjeto]           [int] NOT NULL,
		[idClase]                [varchar](10) NOT NULL,
		[idPropiedadGeneral]     [int] NOT NULL,
		[valor]                  [varchar](max) NOT NULL,
		[fechaCaducidad]         [datetime] NULL,
		[idUsuario]              [int] NOT NULL
)
GO
