                        CREATE VIEW [partida].[SEL_PARTIDAS_COSTO_VW]
AS


SELECT 
    [idPartida]
    ,[idTipoObjeto]
    ,[idClase]
    ,COALESCE(SUM([costo]), 0) costo
    ,COALESCE(SUM([costo]) * .16, 0) IVA
    ,COALESCE(SUM([costo]) + (SUM([costo]) * .16), 0) costoTotal
FROM [Partida].[partida].[PartidaCosto]
GROUP BY [idPartida]
    ,[idTipoObjeto]
    ,[idClase]
GO
