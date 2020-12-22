@AbapCatalog.sqlViewName: 'ZICUPON'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vista zcad_cupon'
define view ZI_CUPON as select from zcad_cupon {
    key code as CODE,
    percentaje as percentaje
}
