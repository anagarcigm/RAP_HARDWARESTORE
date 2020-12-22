class ZCL_VIRTUAL_FIELDS definition
  public
  final
  create public .

public section.

  interfaces IF_SADL_EXIT .
  interfaces IF_SADL_EXIT_CALC_ELEMENT_READ .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VIRTUAL_FIELDS IMPLEMENTATION.


  method IF_SADL_EXIT_CALC_ELEMENT_READ~CALCULATE.

    DATA ls_data TYPE STANDARD TABLE OF zc_ordershop.


    ls_data = CORRESPONDING #( it_original_data ).
    LOOP AT ls_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      <fs_data>-deliveratedate = sy-datum + 7.
    ENDLOOP.

    MOVE-CORRESPONDING ls_data TO ct_calculated_data.


  endmethod.


  method IF_SADL_EXIT_CALC_ELEMENT_READ~GET_CALCULATION_INFO.

*   IF line_exists( it_requested_calc_elements[ table_line = 'DELIVERATEDATE' ] ).
*       APPEND 'WASHERS' TO et_requested_orig_elements.
*         APPEND 'BOLTS' TO et_requested_orig_elements.
*         APPEND 'NUTS' TO et_requested_orig_elements.
*         APPEND 'SCREW' TO et_requested_orig_elements.
*   	ENDIF.
  endmethod.
ENDCLASS.
