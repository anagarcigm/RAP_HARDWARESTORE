@EndUserText.label: 'Proyection ZI_ORDERSHOP'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define root view entity ZC_ORDERSHOP as projection on ZI_ORDERSHOP {
    //ZI_ORDERSHOP
    key id,
    @Semantics.amount.currencyCode: 'moneda'
    totalprice,
    cupon,
     @Semantics.amount.currencyCode: 'moneda'
    discountedprice,
    moneda,
    bolts,
    screw,
    nuts,
    washers,
    _cupon.percentaje,
     
     @ObjectModel.virtualElement: true       
     @ObjectModel.virtualElementCalculatedBy:
                        'ABAP:ZCL_VIRTUAL_FIELDS'
     @EndUserText.label: 'F. Entrega'                  
     virtual deliveratedate: abap.dats,
    /* Associations */
    //ZI_ORDERSHOP
    _cupon
  
}
