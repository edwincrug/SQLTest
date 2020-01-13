CREATE  PROCEDURE [partida].[INS_PARTIDA_MASIVA_SP] 
@idTipoObjeto			INT,
@idClase				varchar(10),
@idUsuario				int,
@rfc					varchar(13),
@idCliente				int,
@numeroContrato			varchar(50),
@idTipoAccion			varchar(20),
@propiedades			XML,
@err				    NVARCHAR(500) OUTPUT
AS

	DECLARE @idPartida	AS INT 
    DECLARE @tbl_propiedades AS TABLE(
        _row                    INT IDENTITY(1,1),
		[index]					INT,
		propiedadDesc			NVARCHAR(250),
        valor                   NVARCHAR(500),
		fechaCaducidad			DATETIME,
		id						INT
    )

    INSERT INTO @tbl_propiedades([index],
								propiedadDesc,
                                valor,
								fechaCaducidad,
								id)

    SELECT
		ParamValues.col.value('index[1]','int'),
		ParamValues.col.value('propiedadDesc[1]','nvarchar(250)'),
        ParamValues.col.value('valor[1]','nvarchar(500)'),
		ParamValues.col.value('fechaCaducidad[1]','datetime'),
		CASE WHEN @idTipoAccion = 'Actualizar' THEN ParamValues.col.value('id[1]','int')
		ELSE 0 END
        FROM @propiedades.nodes('propiedades/propiedad') AS ParamValues(col)
		WHERE ParamValues.col.value('propiedadDesc[1]','nvarchar(250)') != 'index'


    DECLARE @cont		INT = 1,
			@index		INT = 0

	select * from @tbl_propiedades

		if (@idTipoAccion = 'Reemplazar')
	begin
				delete pro
		from partida.PartidaPropiedadGeneral pro
		inner join partida.partida p on pro.idTipoObjeto = p.idTipoObjeto
		where p.idTipoObjeto = @idTipoObjeto AND pro.idClase = @idClase
		delete pro
		from partida.PartidaPropiedadClase pro
		inner join partida.partida p on pro.idTipoObjeto = p.idTipoObjeto
		where p.idTipoObjeto = @idTipoObjeto AND pro.idClase = @idClase
		delete pro
		from partida.PartidaPropiedadContrato pro
		inner join partida.partida p on pro.idTipoObjeto = p.idTipoObjeto
		where p.idTipoObjeto = @idTipoObjeto AND pro.idClase = @idClase
				delete from partida.Partida where idTipoObjeto = @idTipoObjeto AND idClase = @idClase
				set @idTipoAccion = 'Concatenar'
	end


		IF(@idTipoAccion = 'Concatenar')
	BEGIN
		INSERT INTO partida.Partida 
		SELECT TOP 1
			@idTipoObjeto,
			@idClase,
			1,
			@idUsuario
		FROM @tbl_propiedades

		SET @idPartida = @@IDENTITY
	END

   WHILE((SELECT COUNT(*) FROM @tbl_propiedades)>= @cont)

    BEGIN
        DECLARE 
		@propiedad		NVARCHAR(250),
		@idTipoValor	NVARCHAR(250),
		@idPropiedad	INT,
		@valor			NVARCHAR(500),
		@id				INT


		IF(@index != (Select [index] from @tbl_propiedades WHERE _row = @cont))
			BEGIN
				SET @index = @index + 1
				IF(@idTipoAccion = 'Concatenar')
				BEGIN
				INSERT INTO partida.Partida 
				SELECT TOP 1
					@idTipoObjeto,
					@idClase,
					1,
					@idUsuario
				FROM @tbl_propiedades

				SET @idPartida = @@IDENTITY
				END				
			END		
		
		SELECT 
		@id = id,
		@propiedad = 
					CASE
					WHEN propiedadDesc IN (SELECT valor FROM partida.propiedadGeneral) THEN 'general'
					WHEN propiedadDesc IN (SELECT valor FROM partida.propiedadClase) THEN 'clase'
					ELSE 'contrato' END,
		@idTipoValor = (SELECT TOP 1 * FROM (
											SELECT idTipoValor 
											FROM [partida].[PropiedadGeneral]
											WHERE agrupador = prop.propiedadDesc
											UNION ALL
											SELECT idTipoValor 
											FROM [partida].[PropiedadClase]
											WHERE agrupador = prop.propiedadDesc
											UNION ALL
											SELECT idTipoValor 
											FROM [partida].[PropiedadContrato]
											WHERE agrupador = 'Clasificación'
											) as tbl1
						),
		@valor = (	SELECT  idPropiedadGeneral from [partida].[PropiedadGeneral] WHERE valor = prop.valor
					UNION ALL
					SELECT idPropiedadClase  from [partida].[PropiedadClase] WHERE valor = prop.valor
					UNION ALL
					SELECT idPropiedadContrato from [partida].[PropiedadContrato] WHERE valor = prop.valor
				),
		@idPropiedad = (SELECT  idPropiedadGeneral from [partida].[PropiedadGeneral] WHERE valor = prop.propiedadDesc
						UNION ALL
						SELECT idPropiedadClase  from [partida].[PropiedadClase] WHERE valor = prop.propiedadDesc
						UNION ALL
						SELECT idPropiedadContrato from [partida].[PropiedadContrato] WHERE valor = prop.propiedadDesc
						)
		FROM @tbl_propiedades prop
        WHERE _row = @cont 

		IF(@propiedad = 'general')
			BEGIN
				if (@idTipoAccion = 'Concatenar')
				begin
					INSERT INTO partida.PartidaPropiedadGeneral 
					SELECT
						@idPartida idPartida,
						@idTipoObjeto idObjeto,
						@idClase,
						CASE
							WHEN (@idTipoValor != 'Unico') THEN @valor
							ELSE @idPropiedad
							END idPropiedadGeneral,
						CASE 
							WHEN (@idTipoValor != 'Unico') THEN ''
							ELSE valor
							END valor,
						fechaCaducidad,
						@idUsuario
					FROM @tbl_propiedades 
					WHERE _row = @cont
				END
				if (@idTipoAccion = 'Actualizar')
				begin
					if (@idTipoValor = 'Unico')
					begin
						update pro 
							set pro.valor = (select valor FROM @tbl_propiedades where _row = @cont)
						from partida.PartidaPropiedadGeneral pro
						where
							pro.idPartida = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadGeneral = @idPropiedad
							and idClase = @idClase
							
					end
					else if (@idTipoValor = 'Catalogo' or @idTipoValor = 'Agrupador')
					BEGIN
																		select 
							@idPropiedad = [partida].[SEL_PARTIDA_BUSCAIDPORAGRUPADOR_FN](@idTipoObjeto,@id,@idClase,propiedadDesc,@propiedad)
						from @tbl_propiedades where _row = @cont

						update pro 
							set
								pro.idPropiedadGeneral = @valor,
								pro.valor = ''
						from partida.PartidaPropiedadGeneral pro
						where
							pro.idPartida = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadGeneral = @idPropiedad
							and idClase = @idClase

					END
				end
			END
        ELSE IF(@propiedad = 'clase')
            BEGIN
				if (@idTipoAccion = 'Concatenar')
				begin
					INSERT INTO partida.PartidaPropiedadClase
					SELECT
						@idPartida idPartida,
						@idTipoObjeto idTipoObjeto,
						@idClase,
						CASE
							WHEN (@idTipoValor != 'Unico') THEN @valor
							ELSE @idPropiedad
							END idPropiedadClase,
						CASE 
							WHEN (@idTipoValor != 'Unico') THEN ''
							ELSE valor
							END valor,
						fechaCaducidad,
						@idUsuario
					FROM @tbl_propiedades prop
					WHERE _row = @cont
				end
				if (@idTipoAccion = 'Actualizar')
				begin
					if (@idTipoValor = 'Unico')
					begin
						update pro 
							set pro.valor = (select valor FROM @tbl_propiedades where _row = @cont)
						from partida.PartidaPropiedadClase pro
						where
							pro.idPartida = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadClase = @idPropiedad
							and pro.idClase = @idClase
							
					end
					else if (@idTipoValor = 'Catalogo' or @idTipoValor = 'Agrupador')
					BEGIN
																		
						select 
							@idPropiedad = [partida].[SEL_PARTIDA_BUSCAIDPORAGRUPADOR_FN](@idTipoObjeto,@id,@idClase,propiedadDesc,@propiedad)
						from @tbl_propiedades where _row = @cont

						update pro 
							set
								pro.idPropiedadClase = @valor,
								pro.valor = ''
						from partida.PartidaPropiedadClase pro
						where
							pro.idPartida = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadClase = @idPropiedad
							and pro.idClase = @idClase
					end
				end

            END

		ELSE IF(@propiedad = 'contrato')
            BEGIN
				if (@idTipoAccion = 'Concatenar')
				begin
					INSERT INTO partida.PartidaPropiedadContrato
					SELECT
						@idPartida idPartida,
						@idTipoObjeto idTipoObjeto,
						@idClase,
						CASE
							WHEN (@idTipoValor != 'Unico') THEN @valor
							ELSE @idPropiedad
							END idPropiedadContrato,
						@rfc,
						@idCliente,
						@numeroContrato,
						CASE 
							WHEN (@idTipoValor != 'Unico') THEN ''
							ELSE valor
							END valor,
						fechaCaducidad,
						@idUsuario
					FROM @tbl_propiedades
					WHERE _row = @cont
				end
				if (@idTipoAccion = 'Actualizar')
				begin
					if (@idTipoValor = 'Unico')
					begin
						update pro 
							set pro.valor = (select valor FROM @tbl_propiedades where _row = @cont)
						from partida.PartidaPropiedadContrato pro
						where
							pro.idPartida = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadContrato = @idPropiedad
							and pro.idClase = @idClase
							
					end
					else if (@idTipoValor = 'Catalogo' or @idTipoValor = 'Agrupador')
					BEGIN
																		select 
							@idPropiedad = [partida].[SEL_PARTIDA_BUSCAIDPORAGRUPADOR_FN](@idTipoObjeto,@id,'Automovil',propiedadDesc,@propiedad)
						from @tbl_propiedades where _row = @cont

						update pro 
							set
								pro.idPropiedadContrato = @valor,
								pro.valor = ''
						from partida.PartidaPropiedadContrato pro
						where
							pro.idPartida = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadContrato = @idPropiedad
							and pro.idClase = @idClase

					end
				end

            END

        SET @cont = @cont + 1
    END
GO
