CREATE PROCEDURE [partida].[SEL_PARTIDAS_SP]
(
    @rfcEmpresa         VARCHAR(13)        
    ,@idCliente         INT
    ,@numeroContrato    VARCHAR(10)
    ,@idClase           VARCHAR(10)
    ,@idTipoSolicitud   VARCHAR(10)
    ,@idTipoObjeto     INT
	,@idUsuario			INT=NULL
	,@err				NVARCHAR(500) = '' OUTPUT
)
AS

BEGIN

    SELECT 
        PP.[idPartida]
        ,PP.[idTipoObjeto]
        ,PP.[idClase]
        ,STS.[nombre] tipoSolicitud
        ,SPGV.[partida]
        ,SPGV.[idImagen]
        ,SPGV.[noParte]
        ,SPGV.[instructivo]
        ,SPGV.[descripcion]
        ,COALESCE(SPCV.[costo], 0) costo
        ,COALESCE(SPCV.[IVA], 0) costoIVA
        ,COALESCE(SPCV.[costoTotal], 0) costoTotal
        ,COALESCE(SPPV.[venta], 0) venta
        ,COALESCE(SPPV.[IVA], 0) ventaIVA
        ,COALESCE(SPPV.[ventaTotal], 0) ventaTotal
    FROM [Partida].[partida].[Partida] PP
    INNER JOIN [Partida].[partida].[SEL_PARTIDAS_GENERAL_VW] SPGV
        ON PP.[idPartida] = SPGV.[idPartida]
        AND PP.[idTipoObjeto] = SPGV.[idTipoObjeto]
        AND PP.[idClase] = SPGV.[idClase]
    LEFT JOIN [Partida].[partida].[SEL_PARTIDAS_COSTO_VW] SPCV
        ON PP.[idPartida] = SPCV.[idPartida]
        AND PP.[idTipoObjeto] = SPCV.[idTipoObjeto]
        AND PP.[idClase] = SPCV.[idClase]
    LEFT JOIN [Cliente].[contrato].[SEL_PARTIDAS_PRECIO_VW] SPPV
        ON SPPV.[idPartida] = PP.[idPartida]
        AND SPPV.[idClase] = PP.[idClase]
        AND SPPV.rfcEmpresa = @rfcEmpresa
        AND SPPV.idCliente = @idCliente
        AND SPPV.numeroContrato = @numeroContrato
    INNER JOIN [Partida].[partida].[TipoSolicitud] PTS
        ON PTS.[idPartida] = PP.[idPartida]
        AND PTS.[idTipoObjeto] = PP.[idTipoObjeto]
        AND PTS.[idClase] = PP.[idClase]
    INNER JOIN [Solicitud].[solicitud].[TipoSolicitud] STS
        ON STS.[idTipoSolicitud] = PTS.[idTipoSolicitud]
        AND STS.[idClase] = PTS.[idClase]
    WHERE PP.idClase = @idClase
        AND PP.idTipoObjeto = @idTipoObjeto
        AND PP.[activo] = 1
        AND STS.[aplicaMovil] = 1
        AND STS.idClase = @idClase
        AND STS.idTipoSolicitud = @idTipoSolicitud

END
GO
