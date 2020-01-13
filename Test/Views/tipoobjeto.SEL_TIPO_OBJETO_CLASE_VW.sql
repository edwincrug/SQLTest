
                            CREATE VIEW [tipoobjeto].[SEL_TIPO_OBJETO_CLASE_VW]
AS


SELECT
    [idClase]
    ,[idTipoObjeto]
    ,[Combustible] combustible
    ,[Cilindros] cilindros
    ,[Clase] clase
    ,[Marca] marca
    ,[Submarca] submarca
	,[Kilometraje Servicio] ks
	,[Tiempo Servicio] ts
FROM
(
SELECT
    TOTO.[idClase]
    ,TOTO.[idTipoObjeto]
    ,TOPC.[agrupador]
    ,TOPC.[valor]
FROM [Partida].[tipoobjeto].[TipoObjeto] TOTO
INNER JOIN [Partida].[tipoobjeto].[TipoObjetoPropiedadClase] TOTOPC
    ON TOTO.[idTipoObjeto] = TOTOPC.[idTipoObjeto]
    AND TOTO.[idClase] = TOTOPC.[idClase]
INNER JOIN [Partida].[tipoobjeto].[PropiedadClase] TOPC
    ON TOTOPC.[idClase] = TOPC.[idClase]
    AND TOTOPC.[idPropiedadClase] = TOPC.[idPropiedadClase]
WHERE TOTO.[activo] = 1

UNION

SELECT
    TOTO.[idClase]
    ,TOTO.[idTipoObjeto]
    ,PP.[agrupador]
    ,PP.[valor]
FROM [Partida].[tipoobjeto].[TipoObjeto] TOTO
INNER JOIN [Partida].[tipoobjeto].[TipoObjetoPropiedadClase] TOTOPC
    ON TOTO.[idTipoObjeto] = TOTOPC.[idTipoObjeto]
    AND TOTO.[idClase] = TOTOPC.[idClase]
INNER JOIN [Partida].[tipoobjeto].[PropiedadClase] TOPC
    ON TOTOPC.[idClase] = TOPC.[idClase]
    AND TOTOPC.[idPropiedadClase] = TOPC.[idPropiedadClase]
INNER JOIN partida.tipoobjeto.PropiedadClase PP 
    ON TOPC.idPadre = PP.idPropiedadClase
WHERE TOPC.[agrupador] IN ('Submarca')
    AND TOTO.[activo] = 1
) T
    PIVOT
    (	
        MAX(valor)
        FOR agrupador in ([Marca],[Combustible],[Cilindros],[Clase],[Submarca],[Kilometraje Servicio],[Tiempo Servicio])
    ) AS resultado
GO
