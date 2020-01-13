

                                CREATE VIEW [partida].[SEL_PARTIDAS_GENERAL_VW]
AS


SELECT 
    [idPartida]
    , [idTipoObjeto]
    , [idClase]
    , [Partida] partida
    , [Foto] idImagen
    , [noParte]
    , [Instructivo] instructivo
    , [Descripción] descripcion
	
FROM
(SELECT 
    PP.[idPartida]
    ,PP.[idTipoObjeto]
    ,PP.[idClase]
    ,PPG.[agrupador]
    ,PPPG.[valor]
	
FROM [Partida].[partida].[Partida] PP
INNER JOIN [Partida].[partida].[PartidaPropiedadGeneral] PPPG
    ON PP.[idPartida] = PPPG.[idPartida]
    AND PP.[idTipoObjeto] = PPPG.[idTipoObjeto]
    AND PP.[idClase] = PPPG.[idClase]
INNER JOIN [Partida].[partida].[PropiedadGeneral] PPG
    ON PPPG.[idPropiedadGeneral] = PPG.[idPropiedadGeneral]

WHERE PP.[activo] = 1
) T
    PIVOT
    (	
        MAX(valor)
        FOR agrupador in (
            [Partida]
            , [Foto]
            , [noParte]
            , [Instructivo]
            , [Descripción])
    ) AS resultado
GO
