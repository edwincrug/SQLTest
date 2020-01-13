

CREATE VIEW [partida].[SEL_PARTIDAS_GENERAL_CLASIFICACION_VW]
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
	, [valorP] clasificacion
	, [idPropiedadClase] idClasificacion
FROM
(SELECT 
    PP.[idPartida]
    ,PP.[idTipoObjeto]
    ,PP.[idClase]
    ,PPG.[agrupador]
    ,PPPG.[valor]
	,PPC.[valor] valorP
	,PPPC.[idPropiedadClase]
FROM [Partida].[partida].[Partida] PP
INNER JOIN [Partida].[partida].[PartidaPropiedadGeneral] PPPG
    ON PP.[idPartida] = PPPG.[idPartida]
    AND PP.[idTipoObjeto] = PPPG.[idTipoObjeto]
    AND PP.[idClase] = PPPG.[idClase]
INNER JOIN [Partida].[partida].[PropiedadGeneral] PPG
    ON PPPG.[idPropiedadGeneral] = PPG.[idPropiedadGeneral]
inner join [Partida].[partida].[PartidaPropiedadClase] PPPC ON PPPC.idPartida = PP.idPartida
INNER JOIN [Partida].[partida].[PropiedadClase] PPC ON PPC.idPropiedadClase = PPPC.idPropiedadClase
WHERE PP.[activo] = 1 and PPC.idPadre = 2
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
