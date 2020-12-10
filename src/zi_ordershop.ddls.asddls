@EndUserText.label: 'Pedido Ferreteria'
@AbapCatalog.sqlViewName: 'ZORDEN'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.preserveKey:true
define root view ZI_ORDERSHOP 
 as select from zcad_ordershop as ordershop
      association [0..1] to zcad_cupon      as _cupon   on $projection.cupon      = _cupon.code
 {
    key id,
     @Semantics.amount.currencyCode: 'moneda'
    totalprice ,
    cupon,
     @Semantics.amount.currencyCode: 'moneda'
    discountedprice,
    moneda,
    bolts,
    screw,
    nuts,
    washers,
     /* Associations */   
    _cupon
}
