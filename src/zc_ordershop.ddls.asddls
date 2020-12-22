@EndUserText.label: 'Proyection ZI_ORDERSHOP'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@OData.publish: true

define root view entity ZC_ORDERSHOP as projection on ZI_ORDERSHOP {
    //ZI_ORDERSHOP
    key id as id,
     @ObjectModel.text.element: ['percentaje']
     cupon as cupon,
      _zi_cupon.percentaje as percentaje, 
     
    bolts as bolts,
    screw as screw,
    nuts as nuts,
    washers as washers,
     moneda as moneda,
     @Semantics.amount.currencyCode: 'moneda'
    totalprice as totalprice,
       @Semantics.amount.currencyCode: 'moneda'
    discountedprice as discountedprice,
        
     @ObjectModel.virtualElement: true       
     @ObjectModel.virtualElementCalculatedBy:
                        'ABAP:ZCL_VIRTUAL_FIELDS'
     @EndUserText.label: 'F. Entrega'                  
     virtual deliveratedate: abap.dats,
    /* Associations */
  
    _zi_cupon
  
}
