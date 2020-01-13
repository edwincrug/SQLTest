CREATE PROCEDURE [partida].[INS_PARTIDACOSTO_MASIVO_SP]
@costos					XML,
@idTipoObjeto			INT,
@idUsuario				INT,
@idClase				VARCHAR(10),
@err				    NVARCHAR(500) = '' OUTPUT
AS
BEGIN
	DECLARE @tbl_costos AS TABLE(
		_row INT IDENTITY(1, 1)
		,tipoCobro VARCHAR(100)
		,costo FLOAT
		,idPartida INT
	)
	DECLARE @idTipoCobro VARCHAR(10)
	DECLARE @idPartida INT

	declare @tbl_errores as table(
		fila int not null identity(1,1),
		error varchar(max) not null
	);

	INSERT INTO @tbl_costos
	SELECT 
	 ParamValues.col.value('tipoCobro[1]','varchar(100)')
	,ParamValues.col.value('costo[1]','float')
	,ParamValues.col.value('idPartida[1]','int')
	FROM @costos.nodes('tiposCostos/tipocosto') AS ParamValues(col)

	DECLARE @cont INT= 1;
	declare @idPartidaTmp int = 0
		
	WHILE(@cont <= (SELECT COUNT(*) FROM @tbl_costos))
	BEGIN
		SELECT @idTipoCobro = idTipoCobro FROM [partida].[TipoCobro] WHERE nombre = (SELECT tipoCobro FROM @tbl_costos WHERE _row = @cont)
		SELECT @idPartida = idPartida FROM @tbl_costos WHERE _row = @cont

				If exists (SELECT 1 FROM partida.PartidaCosto 
						WHERE idPartida = @idPartida 
							AND idClase = @idClase
							AND idTipoObjeto = @idTipoObjeto
							AND idTipoCobro = @idTipoCobro)
		BEGIN
			UPDATE partida.PartidaCosto
			SET costo = (SELECT costo FROM @tbl_costos WHERE _row = @cont),
			idUsuario = @idUsuario
			WHERE idPartida = @idPartida
			AND idClase = @idClase
			AND idTipoCobro = @idTipoCobro
		END
		ELSE 
		BEGIN
			if exists (select 1 from [partida].[Partida] where idPartida = @idPartida)
			begin
				INSERT INTO partida.PartidaCosto( costo, idPartida, idTipoCobro, idClase, idUsuario, idTipoObjeto)
				VALUES(
					(SELECT costo FROM @tbl_costos WHERE _row = @cont),
					@idPartida,
					@idTipoCobro,
					@idClase,
					@idUsuario,
					@idTipoObjeto
				)
			end
			else
			begin
				if(@idPartidaTmp <> @idPartida)
				begin
					insert into @tbl_errores(error) values('La partida ' + CAST(@idPartida as varchar(50))  + ' no existe en la lista de Partidas.')
					set @idPartidaTmp = @idPartida
				end
			end
			
		END
		SET @cont = @cont + 1
	END

		if exists (select 1 from @tbl_errores)
	begin
		set @err = 'El proceso a finalizado con errores.'
		select * from @tbl_errores
	end
	
END
GO
