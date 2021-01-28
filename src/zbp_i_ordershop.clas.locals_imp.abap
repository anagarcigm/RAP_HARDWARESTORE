CLASS lhc_ZI_ORDERSHOP DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      lc_nuts    TYPE ze_idproduct VALUE'NUTS_01',
      lc_screws  TYPE ze_idproduct VALUE'SCREW_01',
      lc_washers TYPE ze_idproduct VALUE'WASHER_01',
      lc_bolts   TYPE ze_idproduct VALUE'BOLTS_01'.

    METHODS get_features  FOR FEATURES IMPORTING keys REQUEST requested_features FOR ordersh    RESULT result.
    METHODS validate_cupon FOR VALIDATE ON SAVE IMPORTING keys FOR ordersh~validatecupon.
    METHODS validatestock  FOR VALIDATE ON SAVE IMPORTING keys FOR ordersh~validatestock.
    METHODS calculatetotal FOR DETERMINE ON MODIFY IMPORTING keys FOR ordersh~calculateTotal.
    METHODS setid FOR DETERMINE ON SAVE IMPORTING keys FOR ordersh~set_id.
ENDCLASS.

CLASS lhc_ZI_ORDERSHOP IMPLEMENTATION.

 method setid.

  READ ENTITIES OF zi_ordershop IN LOCAL MODE
      ENTITY ordersh
        FIELDS ( ID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    DELETE lt_data WHERE ID IS NOT INITIAL.
    CHECK lt_data IS NOT INITIAL.

    "Get max travelID
    SELECT SINGLE FROM zcad_ordershop FIELDS MAX( id ) INTO @DATA(lv_max_id).

    add 1 to lv_max_id.
    Lv_max_id = |{ LV_MAX_ID ALPHA = IN }|  .
     "update involved instances
    MODIFY ENTITIES OF zi_ordershop IN LOCAL MODE
      ENTITY ordersh
        UPDATE FIELDS ( id )
        WITH VALUE #( FOR ls_data IN lt_data  (
                           %tky      = ls_data-%tky
                           ID  = lv_max_id ) )
    REPORTED DATA(lt_reported).

    "fill reported
    reported = CORRESPONDING #( DEEP lt_reported ).
 ENDMETHOD.
  METHOD validate_cupon.

    READ ENTITIES OF zi_ordershop IN LOCAL MODE
    ENTITY ordersh
    FIELDS (  cupon )
     WITH CORRESPONDING #(  keys )
    RESULT DATA(lt_result).

* transformar upper case
*   lt_result = VALUE #( LET lt_temp = lt_result IN FOR ls_temp IN lt_temp
*                    ( cupon = to_upper( ls_temp-cupon ) ) ).

    SELECT FROM zcad_cupon FIELDS code
    FOR ALL ENTRIES IN @lt_result
    WHERE code =  @lt_result-cupon
    INTO TABLE @DATA(lt_result_db).



    LOOP AT lt_result INTO DATA(ls_result).
      IF ls_result-cupon IS NOT INITIAL AND NOT line_exists( lt_result_db[ code = ls_result-cupon ] ).
        APPEND VALUE #( order_uuid   = ls_result-order_uuid ) TO failed-ordersh.


        APPEND VALUE #(  order_uuid   = ls_result-order_uuid
                         %msg      = new_message( id       = 'ZCAD'
                                                  number   = '001'
                                                  v1       = ls_result-cupon
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-cupon = if_abap_behv=>mk-on ) TO reported-ordersh.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.
*
  METHOD validatestock.
    DATA: lv_return LIKE sy-subrc.

    READ ENTITIES OF zi_ordershop IN LOCAL MODE
          ENTITY ordersh
          ALL FIELDS WITH
          CORRESPONDING #( keys )
          RESULT   DATA(lt_read_data).

    LOOP AT lt_read_data ASSIGNING FIELD-SYMBOL(<fs_read_data>).
      IF <fs_read_data>-nuts IS NOT INITIAL.

        CALL FUNCTION 'ZCAD_CALCULAR_PVP'
          EXPORTING
            numero_piezas = <fs_read_data>-nuts
            product       = lc_nuts
          IMPORTING
            control_stock = lv_return.

         if lv_return = '4'.
          APPEND VALUE #( order_uuid   = <fs_read_data>-order_uuid ) TO failed-ordersh.


          APPEND VALUE #(  order_uuid   = <fs_read_data>-order_uuid
                         %msg      = new_message( id       = 'ZCAD'
                                                  number   = '002'
                                                  v1       = lc_nuts
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-nuts = if_abap_behv=>mk-on ) TO reported-ordersh.
         endif.
      ENDIF.

      IF <fs_read_data>-washers IS NOT INITIAL.
        CALL FUNCTION 'ZCAD_CALCULAR_PVP'
          EXPORTING
            numero_piezas = <fs_read_data>-washers
            product       = lc_washers
          IMPORTING
            control_stock = lv_return.
             if lv_return = '4'.
          APPEND VALUE #( order_uuid  = <fs_read_data>-order_uuid ) TO failed-ordersh.


          APPEND VALUE #(  order_uuid   = <fs_read_data>-order_uuid
                         %msg      = new_message( id       = 'ZCAD'
                                                  number   = '002'
                                                  v1       = lc_washers
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-washers = if_abap_behv=>mk-on ) TO reported-ordersh.
         endif.
      ENDIF.
      IF <fs_read_data>-bolts IS NOT INITIAL.
        CALL FUNCTION 'ZCAD_CALCULAR_PVP'
          EXPORTING
            numero_piezas = <fs_read_data>-bolts
            product       = lc_bolts
          IMPORTING
            control_stock = lv_return.

         if lv_return = '4'.
          APPEND VALUE #( order_uuid   = <fs_read_data>-order_uuid ) TO failed-ordersh.


          APPEND VALUE #(  order_uuid  = <fs_read_data>-order_uuid
                         %msg      = new_message( id       = 'ZCAD'
                                                  number   = '002'
                                                  v1       = lc_bolts
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-bolts = if_abap_behv=>mk-on ) TO reported-ordersh.
         endif.

      ENDIF.

      IF <fs_read_data>-screw IS NOT INITIAL.
        CALL FUNCTION 'ZCAD_CALCULAR_PVP'
          EXPORTING
            numero_piezas = <fs_read_data>-screw
            product       = lc_screws
          IMPORTING
            control_stock = lv_return.

       if lv_return = '4'.
          APPEND VALUE #( order_uuid   = <fs_read_data>-order_uuid ) TO failed-ordersh.


          APPEND VALUE #(  order_uuid   = <fs_read_data>-order_uuid
                         %msg      = new_message( id       = 'ZCAD'
                                                  number   = '002'
                                                  v1       = lc_screws
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-screw = if_abap_behv=>mk-on ) TO reported-ordersh.
         endif.
      ENDIF.


    ENDLOOP.
  ENDMETHOD.
  METHOD  calculatetotal.
    DATA: lV_importe TYPE ze_totalp,
          lv_return  LIKE sy-subrc.
    DATA: ls_cupon TYPE zcad_cupon.

    IF keys IS NOT INITIAL.

*   Read order instance data

      READ ENTITIES OF zi_ordershop IN LOCAL MODE
           ENTITY ordersh
           ALL FIELDS WITH
           CORRESPONDING #( keys )
           RESULT   DATA(lt_read_data).

      LOOP AT lt_read_data ASSIGNING FIELD-SYMBOL(<fs_read_data>).
        CLEAR <fs_read_data>-totalprice.
        <fs_read_data>-moneda = 'EUR'.
        IF <fs_read_data>-nuts IS NOT INITIAL.

          CALL FUNCTION 'ZCAD_CALCULAR_PVP'
            EXPORTING
              numero_piezas = <fs_read_data>-nuts
              product       = lc_nuts
            IMPORTING
              precio        = lV_importe
              control_stock = lv_return.

          <fs_read_data>-totalprice = <fs_read_data>-totalprice + LV_importe.
        ENDIF.

        IF <fs_read_data>-washers IS NOT INITIAL.
          CALL FUNCTION 'ZCAD_CALCULAR_PVP'
            EXPORTING
              numero_piezas = <fs_read_data>-washers
              product       = lc_washers
            IMPORTING
              precio        = lV_importe
              control_stock = lv_return.

          <fs_read_data>-totalprice = <fs_read_data>-totalprice + LV_importe.
        ENDIF.
        IF <fs_read_data>-bolts IS NOT INITIAL.
          CALL FUNCTION 'ZCAD_CALCULAR_PVP'
            EXPORTING
              numero_piezas = <fs_read_data>-bolts
              product       = lc_bolts
            IMPORTING
              precio        = lV_importe
              control_stock = lv_return.

          <fs_read_data>-totalprice = <fs_read_data>-totalprice + LV_importe.
        ENDIF.

        IF <fs_read_data>-screw IS NOT INITIAL.
          CALL FUNCTION 'ZCAD_CALCULAR_PVP'
            EXPORTING
              numero_piezas = <fs_read_data>-screw
              product       = lc_screws
            IMPORTING
              precio        = lV_importe
              control_stock = lv_return.

          <fs_read_data>-totalprice = <fs_read_data>-totalprice + LV_importe.
        ENDIF.

        IF <fs_read_data>-cupon IS INITIAL.
          <fs_read_data>-discountedprice = <fs_read_data>-totalprice.
        ELSE.

          SELECT SINGLE *
          FROM zcad_cupon
          WHERE code  = @<fs_read_data>-cupon
          INTO @ls_cupon.
          IF sy-subrc EQ 0.
            <fs_read_data>-discountedprice = <fs_read_data>-totalprice -
             (  <fs_read_data>-totalprice * ls_cupon-percentaje ).
          else.
           <fs_read_data>-discountedprice = <fs_read_data>-totalprice.
          ENDIF.
        ENDIF.
      ENDLOOP.

      MODIFY ENTITIES OF zi_ordershop IN LOCAL MODE
         ENTITY ordersh
        UPDATE FIELDS ( totalprice moneda  discountedprice )
        WITH CORRESPONDING #(  lt_read_data )
                REPORTED DATA(lt_reported)
                FAILED DATA(lt_failed).
*         UPDATE FIELDS ( tota moneda )
*          WITH VALUE #( FOR key IN keys ( id  = key-id
*                                             moneda = 'EUR' ) )
*                                            failed data(lt_failed).

*       reported = CORRESPONDING #( DEEP lt_reported ).


    ENDIF.

  ENDMETHOD.
  METHOD get_features.

    READ ENTITIES OF zi_ordershop IN LOCAL MODE
    ENTITY ordersh
    FIELDS ( bolts washers nuts screw totalprice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data)
    FAILED DATA(lt_failed).

    result = VALUE #( FOR ls_data IN lt_data
                       ( %key             = ls_data-%key
                         %field-bolts     = if_abap_behv=>fc-f-read_only
                         %field-nuts      =    if_abap_behv=>fc-f-read_only
                         %field-washers  = if_abap_behv=>fc-f-read_only
                         %field-screw     =  if_abap_behv=>fc-f-read_only    ) ).


  ENDMETHOD.


ENDCLASS.

CLASS lcl_save DEFINITION INHERITING FROM cl_abap_behavior_saver.


  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.

 PRIVATE SECTION.
    CONSTANTS:
      lc_nuts    TYPE ze_idproduct VALUE'NUTS_01',
      lc_screws  TYPE ze_idproduct VALUE'SCREW_01',
      lc_washers TYPE ze_idproduct VALUE'WASHER_01',
      lc_bolts   TYPE ze_idproduct VALUE'BOLTS_01'.
ENDCLASS.


CLASS lcl_save IMPLEMENTATION.


   METHOD save_modified.
*
        DATA lt_data_db TYPE STANDARD TABLE OF zcad_ordershop.
        DATA LV_RETURN LIKE SY-SUBRC.
        field-symbols  <fs_read_data> type zcad_ordershop.
*
        IF create-ordersh IS NOT INITIal.
*
          lt_data_db = CORRESPONDING #( create-ordersh ).
*

          loop at lt_data_db ASSIGNING  <fs_READ_data>.
**
           IF <fs_read_data>-nuts IS NOT INITIAL.

          CALL FUNCTION 'ZCAD_CALCULAR_PVP'
            EXPORTING
              numero_piezas = <fs_read_data>-nuts
              product       = lc_nuts
              save_stock    = abap_true
            IMPORTING
              CONTROL_STOCK = lv_return.


        ENDIF.

        IF <fs_read_data>-washers IS NOT INITIAL.
          CALL FUNCTION 'ZCAD_CALCULAR_PVP'
            EXPORTING
              numero_piezas = <fs_read_data>-washers
              product       = lc_washers
                save_stock    = abap_true
            IMPORTING
              CONTROL_STOCK = lv_return.


        ENDIF.
        IF <fs_read_data>-bolts IS NOT INITIAL.
          CALL FUNCTION 'ZCAD_CALCULAR_PVP'
            EXPORTING
              numero_piezas = <fs_read_data>-bolts
              product       = lc_bolts
                save_stock    = abap_true
            IMPORTING
               control_stock = lv_return.


        ENDIF.

        IF <fs_read_data>-screw IS NOT INITIAL.
          CALL FUNCTION 'ZCAD_CALCULAR_PVP'
            EXPORTING
              numero_piezas = <fs_read_data>-screw
              product       = lc_screws
                save_stock    = abap_true
            IMPORTING
              control_stock = lv_return.

        ENDIF.


          endloop.

        endif.
*
        if delete-ordersh is not  INITIAL.

         lt_data_db = CORRESPONDING #( delete-ordersh ).

         select *
         from zcad_ordershop
         FOR ALL ENTRIES IN @lt_data_db
         where order_uuid = @lt_data_db-order_uuid
         into table @lt_data_db.



          LOOP AT lt_data_db ASSIGNING <fs_read_data>.
**
            IF <fs_read_data>-nuts IS NOT INITIAL.

              CALL FUNCTION 'ZCAD_CALCULAR_PVP'
                EXPORTING
                  numero_piezas = <fs_read_data>-nuts
                  product       = lc_nuts
                  delete_order  = abap_true
                IMPORTING
                   control_stock  = lv_return.


            ENDIF.

            IF <fs_read_data>-washers IS NOT INITIAL.
              CALL FUNCTION 'ZCAD_CALCULAR_PVP'
                EXPORTING
                  numero_piezas = <fs_read_data>-washers
                  product       = lc_washers
                  delete_order  = abap_true
                IMPORTING
                  control_stock = lv_return.


            ENDIF.
            IF <fs_read_data>-bolts IS NOT INITIAL.
              CALL FUNCTION 'ZCAD_CALCULAR_PVP'
                EXPORTING
                  numero_piezas = <fs_read_data>-bolts
                  product       = lc_bolts
                  delete_order  = abap_true
                IMPORTING
                  control_stock = lv_return.


            ENDIF.

            IF <fs_read_data>-screw IS NOT INITIAL.
              CALL FUNCTION 'ZCAD_CALCULAR_PVP'
                EXPORTING
                  numero_piezas = <fs_read_data>-screw
                  product       = lc_screws
                  delete_order  = abap_true
                IMPORTING
                  control_stock = lv_return.

            ENDIF.


          ENDLOOP.

        endif.
*
.
*
  ENDMETHOD.
ENDCLASS.
