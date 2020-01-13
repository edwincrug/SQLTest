            CREATE VIEW [tipoobjeto].[SEL_TIPO_OBJETO_GENERAL_VW]
AS


SELECT 
    [idTipoObjeto]
    ,[idClase]
    ,[Foto] idImagen
FROM
(
SELECT 
    TOTO.[idTipoObjeto]
    ,TOTO.[idClase]
    ,TOTOPG.[valor]
    ,TOPG.[agrupador]
FROM [Partida].[tipoobjeto].[TipoObjeto] TOTO
INNER JOIN [Partida].[tipoobjeto].[TipoObjetoPropiedadGeneral] TOTOPG
    ON TOTO.[idClase] = TOTOPG.[idClase]
    AND TOTO.[idTipoObjeto] = TOTOPG.[idTipoObjeto]
INNER JOIN [Partida].[tipoobjeto].[PropiedadGeneral] TOPG
    ON TOTOPG.[idPropiedadGeneral] = TOPG.[idPropiedadGeneral]
WHERE TOTO.[activo] = 1
    AND TOPG.[activo] = 1
    AND TOPG.[idTipoValor] = 'Unico'
) T
    PIVOT
    (	
        MAX(valor)
        FOR agrupador in ([Foto])
    ) AS resultado
GO
