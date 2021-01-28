FUNCTION ZCAD_ORDERSHOP_INSERT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  ZTT_CAD_ORDERSHOP
*"----------------------------------------------------------------------

insert zcad_ordershop from TABLE @values.

ENDFUNCTION.
