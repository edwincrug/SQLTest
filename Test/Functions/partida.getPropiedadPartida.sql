    
CREATE FUNCTION [partida].[getPropiedadPartida]    
 (    
  @idPartida int,    
  @propiedad varchar(max),    
  @tipoPropiedad varchar(20)    
)    
RETURNS varchar(500)    
AS    

BEGIN    
 DECLARE @result varchar(500)    
  
 IF @tipoPropiedad  = 'general'    
  BEGIN    
	   SET @result = (    
		SELECT    
	  CASE WHEN idTipoValor = 'Unico' THEN    
	   OpG.valor    
	  ELSE    
	   PG.valor    
	  END as valor    
		FROM [partida].[PartidaPropiedadGeneral] Opg
		inner join  [partida].[PropiedadGeneral] Pg on Pg.idPropiedadGeneral = opg.idPropiedadGeneral    
		where idPartida = @idPartida AND agrupador = @propiedad    
		);    
  END    
  
  IF @tipoPropiedad  = 'clase'    
  BEGIN    
	   SET @result = (    
		SELECT    
	  CASE WHEN idTipoValor = 'Unico' THEN    
	   Opc.valor    
	  ELSE    
	   CASE WHEN  PC.valor = @propiedad THEN  
		''  
	   ELSE  
		PC.valor    
	   END  
	  END as valor    
		FROM [partida].[PartidaPropiedadClase] Opc
		inner join  [partida].[PropiedadClase] Pc on PC.idPropiedadClase = opc.idPropiedadClase    
		where idPartida = @idPartida AND agrupador = @propiedad    
		);    
  END    
  
  IF @tipoPropiedad  = 'contrato'    
  BEGIN    
   SET @result = (    
    SELECT    
  CASE WHEN idTipoValor = 'Unico' THEN    
   Opc.valor    
  ELSE    
   PC.valor    
  END as valor    
    FROM [partida].[PartidaPropiedadContrato] Opc
		inner join  [partida].[PropiedadContrato] pc on PC.idPropiedadContrato = opc.idPropiedadContrato    
    where idPartida = @idPartida AND agrupador = @propiedad    
    );    
  END        
  RETURN @result    
    
END 
GO
