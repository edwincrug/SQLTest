CREATE  PROCEDURE [partida].[INS_PARTIDACONTRATO_MASIVA_SP] 
@idTipoObjeto			INT,
@numeroContrato			VARCHAR(50),
@idCliente				INT,	
@rfc					varchar(13),		
@propiedades			XML,
@idTipoAccion			varchar(20),
@idUsuario				INT,
@idClase				VARCHAR(10),
@err				    NVARCHAR(500) OUTPUT
AS

	DECLARE @idPartida	AS INT 
    DECLARE @tbl_propiedades AS TABLE(
        _row                    INT IDENTITY(1,1),
		[index]					INT,
		idClase					VARCHAR(10),
		propiedadDesc			NVARCHAR(250),
        valor                   NVARCHAR(500),
		fechaCaducidad			DATETIME,
		id						int
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

		if (@idTipoAccion = 'Reemplazar')
	begin
				delete pro
		from partida.PartidaContratoPropiedadGeneral pro
		inner join partida.partidaContrato p on pro.idTipoObjeto = p.idTipoObjeto
		where p.idTipoObjeto = @idTipoObjeto 
		AND pro.idClase = @idClase
		AND pro.rfcEmpresa = @rfc
		AND pro.idCliente = @idCliente
		AND pro.numeroContrato = @numeroContrato
		delete pro
		from partida.PartidaContratoPropiedadClase pro
		inner join partida.partidaContrato p on pro.idTipoObjeto = p.idTipoObjeto
		where p.idTipoObjeto = @idTipoObjeto
		AND pro.idClase = @idClase
		AND pro.rfcEmpresa = @rfc
		AND pro.idCliente = @idCliente
		AND pro.numeroContrato = @numeroContrato
		delete pro
		from partida.PartidaContratoPropiedadContrato pro
		inner join partida.partida p on pro.idTipoObjeto = p.idTipoObjeto
		where p.idTipoObjeto = @idTipoObjeto
		AND pro.idClase = @idClase
		AND pro.rfcEmpresa = @rfc
		AND pro.idCliente = @idCliente
		AND pro.numeroContrato = @numeroContrato
				delete from partida.PartidaContrato where idTipoObjeto = @idTipoObjeto
		AND idClase = @idClase
		AND rfcEmpresa = @rfc
		AND idCliente = @idCliente
		AND numeroContrato = @numeroContrato
				set @idTipoAccion = 'Concatenar'
	end


		IF(@idTipoAccion = 'Concatenar')
	BEGIN
		INSERT INTO partida.PartidaContrato 
		SELECT TOP 1
			@idTipoObjeto,
			@idClase,
			@rfc,
			@idCliente,
			@numeroContrato,
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
				INSERT INTO partida.PartidaContrato 
				SELECT TOP 1
					@idTipoObjeto,
					@idClase,
					@rfc,
					@idCliente,
					@numeroContrato,
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
		print @propiedad
		IF(@propiedad = 'general')
			BEGIN
				if (@idTipoAccion = 'Concatenar')
				begin
					INSERT INTO partida.PartidaContratoPropiedadGeneral 
					SELECT
						@idPartida idPartida,
						@idTipoObjeto idObjeto,
						@idClase,
						@rfc,
						@idCliente,
						@numeroContrato,
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
						from partida.PartidaContratoPropiedadGeneral pro
						where
							pro.idPartidaContrato = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadGeneral = @idPropiedad
							AND pro.idClase = @idClase
							AND pro.rfcEmpresa = @rfc
							AND pro.idCliente = @idCliente
							AND pro.numeroContrato = @numeroContrato
							
					end
					else if (@idTipoValor = 'Catalogo' or @idTipoValor = 'Agrupador')
					BEGIN
																		select 
							@idPropiedad = [partida].[SEL_PARTIDAPROPIA_BUSCAIDPORAGRUPADOR_FN](@idTipoObjeto,@id,@idClase,propiedadDesc,@propiedad)
						from @tbl_propiedades where _row = @cont
						print(@idPropiedad)
						update pro 
							set
								pro.idPropiedadGeneral = @valor,
								pro.valor = ''
						from partida.PartidaContratoPropiedadGeneral pro
						where
							pro.idPartidaContrato = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadGeneral = @idPropiedad
							AND pro.idClase = @idClase
							AND pro.rfcEmpresa = @rfc
							AND pro.idCliente = @idCliente
							AND pro.numeroContrato = @numeroContrato

					END
				end
			END
        ELSE IF(@propiedad = 'clase')
            BEGIN
				if (@idTipoAccion = 'Concatenar')
				begin
					INSERT INTO partida.PartidaContratoPropiedadClase
					SELECT
						@idPartida idPartida,
						@idTipoObjeto idObjeto,
						@idClase,
						@rfc,
						@idCliente,
						@numeroContrato,
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
						from partida.PartidaContratoPropiedadClase pro
						where
							pro.idPartidaContrato = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadClase = @idPropiedad
							AND pro.idClase = @idClase
							AND pro.rfcEmpresa = @rfc
							AND pro.idCliente = @idCliente
							AND pro.numeroContrato = @numeroContrato
							
					end
					else if (@idTipoValor = 'Catalogo' or @idTipoValor = 'Agrupador')
					BEGIN
																		
						select 
							@idPropiedad = [partida].[SEL_PARTIDAPROPIA_BUSCAIDPORAGRUPADOR_FN](@idTipoObjeto,@id,'Automovil',propiedadDesc,@propiedad)
						from @tbl_propiedades where _row = @cont
						print(@idPropiedad)
						update pro 
							set
								pro.idPropiedadClase = @valor,
								pro.valor = ''
						from partida.PartidaContratoPropiedadClase pro
						where
							pro.idPartidaContrato = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadClase = @idPropiedad
							AND pro.idClase = @idClase
							AND pro.rfcEmpresa = @rfc
							AND pro.idCliente = @idCliente
							AND pro.numeroContrato = @numeroContrato
					end
				end

            END

		ELSE IF(@propiedad = 'contrato')
            BEGIN
				if (@idTipoAccion = 'Concatenar')
				begin
					INSERT INTO partida.PartidaContratoPropiedadContrato
					SELECT
						@idPartida idPartida,
						@idTipoObjeto idObjeto,
						@idClase,
						@rfc,
						@idCliente,
						@numeroContrato,
						CASE
							WHEN (@idTipoValor != 'Unico') THEN @valor
							ELSE @idPropiedad
							END idPropiedadContrato,
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
						from partida.PartidaContratoPropiedadContrato pro
						where
							pro.idPartidaContrato = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadContrato = @idPropiedad
							AND pro.idClase = @idClase
							AND pro.rfcEmpresa = @rfc
							AND pro.idCliente = @idCliente
							AND pro.numeroContrato = @numeroContrato
							
					end
					else if (@idTipoValor = 'Catalogo' or @idTipoValor = 'Agrupador')
					BEGIN
																		select 
							@idPropiedad = [partida].[SEL_PARTIDAPROPIA_BUSCAIDPORAGRUPADOR_FN](@idTipoObjeto,@id,'Automovil',propiedadDesc,@propiedad)
						from @tbl_propiedades where _row = @cont
						print('contrato')
						print(@idPropiedad)
						update pro 
							set
								pro.idPropiedadContrato = @valor,
								pro.valor = ''
						from partida.PartidaContratoPropiedadContrato pro
						where
							pro.idPartidaContrato = @id
							and pro.idTipoObjeto = @idTipoObjeto
							and idPropiedadContrato = @idPropiedad
							AND pro.idClase = @idClase
							AND pro.rfcEmpresa = @rfc
							AND pro.idCliente = @idCliente
							AND pro.numeroContrato = @numeroContrato

					end
				end

            END

        SET @cont = @cont + 1
    END
GO
