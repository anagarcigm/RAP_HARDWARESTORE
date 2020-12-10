CLASS lhc_ZI_ORDERSHOP DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
*      DATA: lt_fields       TYPE TABLE OF dfies.

*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE order.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE order.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE order.
*
*    METHODS read FOR READ
*      IMPORTING keys FOR READ order RESULT result.

     METHODS validate_cupon FOR VALIDATION order~validatecupon IMPORTING keys for order .
ENDCLASS.

CLASS lhc_ZI_ORDERSHOP IMPLEMENTATION.
   method validate_cupon.

    READ ENTITIES OF zi_ordershop IN LOCAL MODE
    ENTITY order
    FIELDS ( cupon )
     WITH CORRESPONDING #(  keys )
    RESULT DATA(lt_result).

      SELECT FROM zcad_cupon FIELDS code
      FOR ALL ENTRIES IN @lt_result
      WHERE code = @lt_result-cupon
      INTO TABLE @DATA(lt_result_db).


        LOOP AT lt_result INTO DATA(ls_result).
        IF ls_result-cupon IS NOT INITIAL AND NOT line_exists( lt_result_db[ code = ls_result-cupon ] ).
         APPEND VALUE #( id   = ls_result-id ) TO failed.


        APPEND VALUE #(  id   = ls_result-id
                         %msg      = new_message( id       = 'ZCAD'
                                                  number   = '001'
                                                  v1       = ls_result-cupon
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-cupon = if_abap_behv=>mk-on ) TO reported.
      ENDIF.

    ENDLOOP.

   ENDMETHOD.
*
*  METHOD create.
*
*     DATA: LS_ORDER TYPE ZCAD_ORDERSHOP.
*
*
*    loop at entities ASSIGNING FIELD-SYMBOL(<FS_ORDER>).
*        LS_ORDER = CORRESPONDING #( <FS_ORDER> ).
*       INSERT  ZCAD_ORDERSHOP FROM LS_ORDER.
*     endloop.
*  ENDMETHOD.
*
*  METHOD delete.
*
*
*     DATA: LS_ORDER TYPE ZCAD_ORDERSHOP.
*
*   loop at keys ASSIGNING FIELD-SYMBOL(<FS_ORDER>).
*
*      LS_ORDER = CORRESPONDING #( <FS_ORDER> ).
*      DELETE FROM ZCAD_ORDERSHOP WHERE ID = LS_ORDER-ID.
*
*   ENDLOOP.
*
*  ENDMETHOD.
*
*  METHOD update.
*   if entities is not INITIAL.
*
*    call FUNCTION 'DDIF_FIELDINFO_GET'
*    EXPORTING
*      TABNAME = 'ZCAD_ORDERSHOP'
*    TABLES
*      dfies_tab      = lt_fields
*    EXCEPTIONS
*       not_found      = 1
*       internal_error = 2
*       OTHERS         = 3.
*
*    DATA(ls_data) = entities[ 1 ].
*
*    SELECT SINGLE *
*    FROM ZCAD_ORDERSHOP
*    INTO @DATA(ls_tmp_tabl)
*    WHERE ID = @ls_data-ID.
*
*    LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<fs_field>).
*      ASSIGN COMPONENT <fs_field>-fieldname OF STRUCTURE ls_data TO FIELD-SYMBOL(<fs_target>).
*
*      IF <fs_target> IS ASSIGNED AND <fs_target> IS NOT INITIAL.
*
*       ASSIGN COMPONENT <fs_field>-fieldname OF STRUCTURE ls_tmp_tabl
*       TO FIELD-SYMBOL(<fs_source>).
*
*        <fs_source> = <fs_target>.
*
*     ENDIF.
*
*    ENDLOOP.
*    UPDATE ZCAD_ORDERSHOP FROM LS_TMP_TABL.
*
*    endif.
*
*  ENDMETHOD.
*
*  METHOD read.
*
*
*     DATA: LS_OUT TYPE ZCAD_ORDERSHOP.
*
*
*   loop at keys INTO DATA(LS_ORDER).
*     SELECT SINGLE * INTO LS_OUT
*     FROM ZCAD_ORDERSHOP
*     WHERE ID = LS_ORDER-ID.
*
*
*    INSERT CORRESPONDING #( ls_out ) INTO TABLE RESULT.
*
*   ENDLOOP.
*
*  ENDMETHOD.



ENDCLASS.