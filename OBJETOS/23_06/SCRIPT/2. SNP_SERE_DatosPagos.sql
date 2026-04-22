IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'SNP_SERE_DatosPagos')
DROP PROCEDURE SNP_SERE_DatosPagos
GO 
CREATE PROCEDURE SNP_SERE_DatosPagos(
@pSerie Char(4),
@pCorrelativo Varchar(10),
@pSecuencia Integer,
@ppagoventa_tipo Varchar(100),
@ppagoventa_tipocambio Money,
@ppagoventa_monto Money,
@ppagoventa_referenciatransaccion Varchar(100),
@pventa_id Varchar(100),
@pmoneda_id Varchar(100),
@pmoneda_descripcion Varchar(100),
@pmoneda_simbolo Varchar(100),
@pmoneda_tipocambio Money,
@pmoneda_tipocambio_compra Money,
@ptarjeta_id Varchar(100),
@ptarjeta_descripcion Varchar(100),
@ptarjeta_estado Varchar(100),
@ptarjeta_retencion Money,
@ptarjeta_retencioncondicion Money,
@ptarjeta_delivery Varchar(100),
@ptarjeta_retienecliente Varchar(100),
@ptarjeta_codigopos Varchar(100),
@ptarjetaglobal_id Varchar(100),
@ptarjetaglobal Varchar(100),
@pDominio Varchar(100),
@pIdLocal Varchar(100),
@ptipoDocumento varChar(100))
AS
BEGIN
	DECLARE @vCount Int
	DECLARE @vTipoPagoSpring Varchar(4)
	DECLARE @vtipoDocumento Char(2), @vGeneraCobranza Char(1)

	SET @vTipoPagoSpring = ''
	SET @vCount = 0

	IF @pTipoDocumento ='Boleta' SET @vtipoDocumento ='BL'
	IF @pTipoDocumento ='Factura' SET @vtipoDocumento ='FC'
	IF @pTipoDocumento ='Nota de credito Boleta' SET @vtipoDocumento ='NC'
	IF @pTipoDocumento ='Nota de credito Factura' SET @vtipoDocumento ='NC'
	IF @pTipoDocumento ='Nota de Venta' SET @vtipoDocumento ='XX'

	SELECT @vCount = Count(*) FROM Restaurant_Pagos WHERE venta_id=@pventa_id and Secuencia = @pSecuencia  AND dominio=@pDominio AND  LocalID =@pIdLocal AND tipoDocumento= @vtipoDocumento
	
	IF @ppagoventa_tipo = 'Efectivo'
	BEGIN
		SET @vTipoPagoSpring = 'EF'
	END
	ELSE
	BEGIN
		SELECT @vTipoPagoSpring  = TarjetaSpring, @vGeneraCobranza = IsNull(GeneraCobranza,'N')
		  FROM Restaurant_PagoSpring 
		 WHERE Tarjeta_Id = @ptarjeta_id AND dominio=@pDominio AND  Local_ID =@pIdLocal
	END

	IF @vCount = 0
	BEGIN
		
		INSERT INTO Restaurant_Pagos(Serie, Correlativo, Secuencia, pagoventa_tipo, pagoventa_tipocambio, pagoventa_monto, pagoventa_referenciatransaccion, venta_id, moneda_id,
								moneda_descripcion, moneda_simbolo, moneda_tipocambio, moneda_tipocambio_compra, tarjeta_id, tarjeta_descripcion, tarjeta_estado,
								tarjeta_retencion, tarjeta_retencioncondicion, tarjeta_delivery, tarjeta_retienecliente, tarjeta_codigopos, tarjetaglobal_id, tarjetaglobal,
								dominio, LocalID, tipoPagoSpring, tipoDocumento,GeneraCobranza)
	                     VALUES (@pSerie, @pCorrelativo, @pSecuencia, @ppagoventa_tipo, @ppagoventa_tipocambio, @ppagoventa_monto, @ppagoventa_referenciatransaccion, @pventa_id, @pmoneda_id, 
						        @pmoneda_descripcion, @pmoneda_simbolo, @pmoneda_tipocambio, @pmoneda_tipocambio_compra, @ptarjeta_id, @ptarjeta_descripcion, @ptarjeta_estado, 
								@ptarjeta_retencion, @ptarjeta_retencioncondicion, @ptarjeta_delivery, @ptarjeta_retienecliente, @ptarjeta_codigopos, @ptarjetaglobal_id, @ptarjetaglobal,
								@pDominio,@pIdLocal,@vTipoPagoSpring,@vtipoDocumento,@vGeneraCobranza)
	END
END



