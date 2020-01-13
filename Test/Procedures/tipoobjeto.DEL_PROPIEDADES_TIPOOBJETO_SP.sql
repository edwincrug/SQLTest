CREATE PROCEDURE [tipoobjeto].[DEL_PROPIEDADES_TIPOOBJETO_SP]
	@data				XML,
	@idUsuario			INT,
	@err				varchar(max) OUTPUT
		
AS

BEGIN
	
	DECLARE @msj		varchar(50) = '', 
			@VC_ErrorMessage	VARCHAR(4000)	= '',
			@VC_ThrowMessage	VARCHAR(100)	= 'An error has occured on [DEL_PROPIEDADES_TIPOOBJETO_SP]:',
			@VC_ErrorSeverity	INT = 0,
			@VC_ErrorState		INT = 0,
			@status				int = 0,
			@activo				int = 0,
			@propiedad			nvarchar(10) = (SELECT I.N.value('.','nvarchar(10)')
												FROM @data.nodes('/Ids/prop') AS I(N))

	DECLARE @tbl_propiedades AS TABLE(
        idPropiedad			INT
    )

	INSERT INTO @tbl_propiedades
    SELECT
        I.N.value('.','int')
        FROM @data.nodes('/Ids/idProp') AS I(N);

		BEGIN TRY
			BEGIN TRANSACTION DEL_PROPIEDADES_TIPOOBJETO_SP			
						IF @propiedad = 'general'
				BEGIN
										UPDATE [tipoobjeto].[PropiedadGeneral]
						SET [activo] = 0
						WHERE idPropiedadGeneral IN (SELECT idPropiedad from @tbl_propiedades)
	
				set @status = 1;
				SET @msj = 'La propiedad se elimino correctamente';
				END 
						IF @propiedad = 'clase'
				BEGIN
								UPDATE [tipoobjeto].[PropiedadClase]
					SET [activo] = 0
					WHERE idPropiedadClase IN (SELECT idPropiedad from @tbl_propiedades)

				set @status = 1;
				SET @msj = 'La propiedad se elimino correctamente';
				END 

			COMMIT TRANSACTION DEL_PROPIEDADES_TIPOOBJETO_SP
		END TRY
		BEGIN CATCH
			SELECT  
				@VC_ErrorMessage	= ERROR_MESSAGE(),
				@VC_ErrorSeverity	= ERROR_SEVERITY(),
				@VC_ErrorState		= ERROR_STATE();
			BEGIN
				ROLLBACK TRANSACTION DEL_PROPIEDADES_TIPOOBJETO_SP
				SET @msj = 'Error al eliminar la propiedad de tipo';
				SET @VC_ErrorMessage = {
					fn CONCAT(
						@VC_ThrowMessage,
						@VC_ErrorMessage)
				}
				RAISERROR (
					@VC_ErrorMessage, 
					@VC_ErrorSeverity, 
					@VC_ErrorState
				);
			END
		END CATCH
	SELECT 
		@msj				AS [Message], 
		@status				AS [Eliminado];

    SET NOCOUNT OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END
GO
