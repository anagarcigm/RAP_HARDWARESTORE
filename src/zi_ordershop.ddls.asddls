@EndUserText.label: 'Pedido Ferreteria'
@AbapCatalog.sqlViewName: 'ZORDEN'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.preserveKey:true
define root view ZI_ORDERSHOP 
 as select from zcad_ordershop as ordershop
      association [0..1] to ZI_CUPON      as _zi_cupon   on $projection.cupon      = _zi_cupon.CODE
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
    _zi_cupon
}
