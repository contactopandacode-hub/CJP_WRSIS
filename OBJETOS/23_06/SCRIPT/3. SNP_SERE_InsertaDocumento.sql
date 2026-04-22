IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'SNP_SERE_InsertaDocumento')
DROP PROCEDURE SNP_SERE_InsertaDocumento
GO
CREATE PROCEDURE SNP_SERE_InsertaDocumento(
@pId Varchar(100),
@pDominio Varchar(100),
@pLocalId Varchar(100),
@ptipoDocumento Varchar(2))
AS
BEGIN 
  DECLARE @vtipoDocumento Varchar(100),@vCompaniaSocio varchar(8),@vSerie Varchar(4), @vCorretivo Varchar(10), @vNumeroDocumento Varchar(15), @vCountPersona Int, @vCountDocumento Int,@int_Vendedor Int
  DECLARE @vCliente_numerodocumento Varchar(20), @vLocalId Varchar(4),@vUnidadNegocio Varchar(4), @vAlmacenCodigo Varchar(10),@vEstadoDocumento varchar(2)
  DECLARE @vFactorPorcentaje Money, @vTipoCambio Money, @vpagoVenta_Monto Money,@vTotal Money
  DECLARE @vEstado Varchar(2), @vEstadoDetalle varchar(2), @vEstadoCobranza varchar(2)

BEGIN TRANSACTION;
	BEGIN TRY	
	  SET @vCountPersona =0
	  SET @vTipoCambio = 0
	  SET @vpagoVenta_Monto =0
	  SET @vCountDocumento = 0
	  SET @int_Vendedor = 2
	  SET @vEstadoDocumento ='PR'
	  SET @vEstadoDetalle ='PR'
	  SET @vEstadoCobranza ='AP'
	  -- Para el vendor si no tiene sera el codigo 2, validar el DNI con el maestro de personas.
	  -- SET @vCompaniaSocio ='09000000'

	  SELECT @vFactorPorcentaje = FactorPorcentaje FROM Impuestos WHERE Impuesto='IGV' 

	  SELECT @vtipoDocumento= tipodocumento , @vSerie =Serie, @vNumeroDocumento = Correlativo, @vCliente_numerodocumento=cliente_numerodocumento,
		    @vEstado = Estado, @vTotal = total,
			@vLocalId =CodigoLocal FROM Restaurant_Cabecera
	   WHERE id =@pId And Dominio = @pDominio And IdLocal= @pLocalId  AND tipoDocumento = @ptipoDocumento

	   SELECT @vUnidadNegocio = UnidadNegocio, @vCompaniaSocio = CompaniaSocio , @vAlmacenCodigo = almacencodigo FROM MA_UnidadNegocio WHERE Dominio = @pDominio And codigo_local= @pLocalId	
	   
	   SELECT @vpagoVenta_Monto = SUM(pagoVenta_Monto) FROM Restaurant_Pagos WHERE venta_id =@pId And Dominio = @pDominio And LocalId= @pLocalId And tipoDocumento = @vtipoDocumento

	   IF @vpagoVenta_Monto>0 SET  @vEstadoDocumento='CO'
	   IF @vEstado = '0' SET  @vEstadoDocumento='AN'
	   IF @vEstado = '0' SET  @vEstadoDetalle='AN'
	   IF @vEstado = '0' SET  @vEstadoCobranza='AN'
   
	   SET @vNumeroDocumento = @vSerie + '-'+ RIGHT(REPLICATE('0', 7) + CAST(@vNumeroDocumento AS VARCHAR(7)), 7)
	   	  
	   SELECT @vCountDocumento = Count(*) FROM CO_Documento WHERE CompaniaSocio =@vCompaniaSocio AND tipoDocumento =@vtipoDocumento AND numeroDocumento = @vNumeroDocumento
	   IF @vCountDocumento IS NULL SET @vCountDocumento = 0

	   IF @vCountDocumento = 0
	   BEGIN
		   SELECT @vCountPersona= Isnull(Persona,0) FROM PersonaMast
		    WHERE (Documento = @vCliente_numerodocumento Or DocumentoIdentidad = @vCliente_numerodocumento OR DocumentoFiscal= @vCliente_numerodocumento)
			  AND Estado='A'

		   IF @vCountPersona = 0 OR @vCountPersona IS NULL SET @vCountPersona =2114
	 
	
		   SELECT @vTipoCambio = Isnull(FactorVenta ,0)
			 FROM TipoCambioMast  With (NoLock)    
			WHERE MonedaCodigo = 'EX'                
			AND MonedaCambioCodigo = 'LO' AND FechaCambio = Left(Convert(varchar,GETDATE(),120),10)
		
			IF @vTipoCambio = 0 
			BEGIN
			 SELECT TOP 1 @vTipoCambio = FactorVenta 
			   FROM TipoCambioMast  With (NoLock)    
			  WHERE MonedaCodigo = 'EX'  AND MonedaCambioCodigo = 'LO'   order by FechaCambio desc     
			END

			INSERT INTO CO_Documento(CompaniaSocio,TipoDocumento,NumeroDocumento,EstablecimientoCodigo,FormaFacturacion,ClienteNumero,ClienteRUC,ClienteNombre,  
									ClienteDireccion,ClienteCobrarA,FechaDocumento,FechaVencimiento,TipoFacturacion,TipoVenta,ConceptoFacturacion,FormadePago,  
									Criteria,Vendedor,TipodeCambio,MonedaDocumento,MontoAfecto,MontoNoAfecto,MontoImpuestoVentas,MontoTotal,PreparadoPor, 
									FechaPreparacion,CentroCosto,Sucursal,TipoCanjeFactura,UnidadNegocio,UnidadReplicacion,Comentarios,Estado,UltimoUsuario, 
									UltimaFechaModif,ClienteReferencia,montodescuentos,direccionentrega,montoimpuestos,AlmacenCodigo,
									FENotaCreditoMotivo,FENotaCreditoSustento,NotaCreditoDocumento,
									MontoPagado, voucherperiodo, ContabilizacionPendienteFlag ) 
							SELECT @vCompaniaSocio,@vtipoDocumento,@vNumeroDocumento,'1902','F',@vCountPersona,cliente_numeroDocumento,cliente_cliente,
									cliente_direccion,@vCountPersona,fecha,fecha,'NOR',(CASE WHEN UPPER(canalventa) ='SALONES' OR UPPER(canalventa) ='RAPIDA'  THEN 'TDA'ELSE 'DEL' END),'NOR','004',
									'999999',@int_Vendedor,@vTipoCambio,'LO',Venta_montoafecto,Venta_montoinafecto,impuestos,total,1,
									fecha,'31001',@vUnidadNegocio,'NO',@vUnidadNegocio,@vUnidadNegocio,null,@vEstadoDocumento,'MISESF',
									getdate(),@pDominio+'-'+@pLocalId+'-'+@pId,descuento,cliente_direccion,recargoConsumo_Monto,@vAlmacenCodigo,
									MOTIVO,sustento, tipodoc_ref+'-'+ seriedoc_ref+'-'+ RIGHT(REPLICATE('0', 7) + CAST(convert (int,numerodoc_ref) AS VARCHAR(7)), 7),
									@vpagoVenta_Monto,Left(fecha,4)+SUBSTRING(fecha,6,2),'S'
								FROM Restaurant_Cabecera
							WHERE id =@pId  And Dominio = @pDominio And IdLocal= @pLocalId And tipoDocumento = @vtipoDocumento

			IF @vtipoDocumento='XX' 
			BEGIN
				UPDATE CO_Documento SET MontoAfecto=0.00, MontoImpuestoVentas=0.00, MontoNoAfecto = @vTotal, MontoTotal= @vTotal
				 WHERE CompaniaSocio=@vCompaniaSocio AND TipoDocumento=@vtipoDocumento AND NumeroDocumento=@vNumeroDocumento
			END
	
			--Inserta Impuestos
			 INSERT INTO CO_DocumentoImpuesto(CompaniaSocio,TipoDocumento,NumeroDocumento,TipoRegistro,Impuesto,Porcentaje,Monto) 
								SELECT @vCompaniaSocio,@vtipoDocumento,@vNumeroDocumento,'I',nombre,porcentaje,monto
								  FROM Restaurant_Impuestos
								 WHERE id =@pId And Dominio = @pDominio And LocalID= @pLocalId And tipoDocumento = @vtipoDocumento
	
			--Inserta Detalle
			INSERT INTO CO_DocumentoDetalle(CompaniaSocio,TipoDocumento,NumeroDocumento,Linea,TipoDetalle,ItemCodigo,Condicion,Descripcion,UnidadCodigo,CantidadPedida, CantidadPedidaOriginal ,
										   PrecioUnitarioOriginal,PrecioUnitario,Monto,IGVExoneradoFlag,DespachoUnidadEquivalenteFlag,ImprimirPUFlag,AlmacenCodigo, 
										   CentroCosto,Estado,UltimoUsuario,UltimaFechaModif,TransferenciaGratuitaFlag,Sucursal,preciounitariofinal,PorcentajeDescuento01)
									SELECT @vCompaniaSocio,@vtipoDocumento,@vNumeroDocumento,Secuencia,'I',detalle_codigo_interno,'0',nombre_producto,'UND',cantidad_vendida,cantidad_vendida, 
									  Precio_Unitario, Round(valorventa / cantidad_vendida,4), valorventa,(CASE when tipo_impuesto_txt ='Gravado' THEN 'N'ELSE'S' END),'N','S',@vAlmacenCodigo,  
									  '31001',@vEstadoDetalle,'MISESF',GETDATE(),'N','LIMA'  ,precio_Unitario , (Case when porc_desc_unitario > 0 then porc_desc_unitario ELSE porc_desc_global END)                         
									 FROM Restaurant_Detalle  
									 WHERE id =@pId And Dominio = @pDominio And LocalID= @pLocalId And tipoDocumento = @vtipoDocumento
								 
			--Genera Cobranza		
			DECLARE @vInt_Cobranza Int
			SET @vInt_Cobranza = 0		
			
			SELECT @vInt_Cobranza = Count (*)  FROM Restaurant_Pagos 
			 WHERE venta_id =@pId And Dominio = @pDominio 
			   AND LocalId= @pLocalId And tipoDocumento = @vtipoDocumento
			   AND GeneraCobranza ='S'

			IF @vInt_Cobranza > 0
			BEGIN
				EXEC  SNP_FE_GenerarCorrelativo '999999','SY','COCN',@vInt_Cobranza OUTPUT

				INSERT INTO CO_Cobranza(UnidadReplicacion,CobranzaNumero, CompaniaSocio, FechaPreparacion, FechaCobranza, Cliente,Cobrador,Cajero,
									   Estado,UltimoUsuario,UltimaFechaModif,Ledger)
								SELECT @vUnidadNegocio,@vInt_Cobranza,@vCompaniaSocio,CONVERT(datetime,fecha,120),CONVERT(datetime,fecha,120),@vCountPersona,@int_Vendedor,@int_Vendedor,
										@vEstadoCobranza,'MISESF',CONVERT(datetime,fecha,120),0
								  FROM Restaurant_Cabecera
								 WHERE id =@pId  And Dominio = @pDominio And IdLocal= @pLocalId	 And tipoDocumento = @vtipoDocumento

				-- Insert Detalle	
				SET @vEstadoCobranza ='RV'
			    IF @vEstado = '0' SET  @vEstadoCobranza='AN'
   			
				INSERT INTO CO_CobranzaDetalle(UnidadReplicacion,CobranzaNumero,Linea,TipoPago, MonedaPago, MontoLocal,MontoDolares,TipoCambioPago,
											Estado,UltimoUsuario,UltimaFechaModif,DocumentoReferencia)
										SELECT @vUnidadNegocio,@vInt_Cobranza, Secuencia,TipoPagoSpring, (CASE WHEN moneda_Id='1' THEN 'LO' ELSE 'EX' END), pagoVenta_Monto, Round(pagoVenta_Monto/ @vTipoCambio,2),@vTipoCambio,
											@vEstadoCobranza,'MISESF',getdate(),pagoventa_referenciatransaccion
											 FROM Restaurant_Pagos 
											 WHERE venta_id =@pId And Dominio = @pDominio And LocalId= @pLocalId And tipoDocumento = @vtipoDocumento

				--- Insert CO_DocumentoCobranza			

				INSERT INTO CO_DocumentoCobranza(CompaniaSocio,TipoDocumento,NumeroDocumento,UnidadReplicacion,CobranzaNumero,MontoPagado)
										VALUES( @vCompaniaSocio,@vtipoDocumento,@vNumeroDocumento,@vUnidadNegocio,@vInt_Cobranza,@vpagoVenta_Monto)						
			END

			UPDATE Restaurant_Cabecera SET SpringCompania = @vCompaniaSocio , SpringTipoDocumento = @vtipoDocumento ,SpringNumeroDocumento = @vNumeroDocumento
			 WHERE id =@pId  And Dominio = @pDominio And IdLocal= @pLocalId And tipoDocumento = @vtipoDocumento

			SELECT '0' AS Codigo, 'Procesado Correctamente' AS Mensaje
		END
		ELSE
		BEGIN
			SELECT '1' AS Codigo, 'Existe' AS Mensaje
		END

	END TRY
BEGIN CATCH
	SELECT '99' AS Codigo, ERROR_MESSAGE() AS Mensaje
	ROLLBACK TRANSACTION;     
IF @@TRANCOUNT > 0    
	ROLLBACK TRANSACTION;     
END CATCH

IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION; 
END