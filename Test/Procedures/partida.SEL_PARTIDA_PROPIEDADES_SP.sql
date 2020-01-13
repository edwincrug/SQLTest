

CREATE PROCEDURE [partida].[SEL_PARTIDA_PROPIEDADES_SP]
	@idClase			varchar(10),
	@idCliente			int = null,
    @numeroContrato		varchar(50) = null,
	@idUsuario			int = null,
	@err				NVARCHAR(500) = '' OUTPUT
AS

BEGIN

SELECT [idPropiedadGeneral] AS id
	  ,'general' AS propiedad
      ,[idPadre]
      ,[idTipoValor]
      ,[idTipoDato]
      ,[agrupador]
      ,[valor]
      ,[obligatorio]
      ,[orden]
      ,[posicion]
      ,[activo]
      ,[idUsuario]
  FROM [Partida].[partida].[PropiedadGeneral]
	WHERE activo = 1
	ORDER BY idPropiedadGeneral asc,posicion asc, orden desc 


SELECT [idPropiedadClase] AS id
	  ,'clase' AS propiedad
      ,[idClase]
      ,[idPadre]
      ,[idTipoValor]
      ,[idTipoDato]
      ,[agrupador]
      ,[valor]
      ,[obligatorio]
      ,[orden]
      ,[posicion]
      ,[activo]
      ,[idUsuario]
  FROM [Partida].[partida].[PropiedadClase]
	WHERE idClase = @idClase AND activo = 1
	ORDER BY idPropiedadClase asc,posicion asc, orden desc 

SELECT [idPropiedadContrato]  AS id
	  ,'contrato' AS propiedad
      ,[rfcEmpresa]
      ,[idCliente]
      ,[numeroContrato]
      ,[idPadre]
      ,[idTipoValor]
      ,[idTipoDato]
      ,[agrupador]
      ,[valor]
      ,[obligatorio]
      ,[orden]
      ,[posicion]
      ,[activo]
      ,[idUsuario]
  FROM [Partida].[partida].[PropiedadContrato]
		WHERE idCliente = @idCliente AND numeroContrato = @numeroContrato AND activo = 1
		ORDER BY idPropiedadContrato asc,posicion asc, orden desc 

END
GO
