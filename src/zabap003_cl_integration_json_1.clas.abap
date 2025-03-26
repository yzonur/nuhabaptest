class ZABAP003_CL_INTEGRATION_JSON_1 definition
  public
  final
  create public .

public section.

  interfaces ZNT_009_IF_INTEGRATION .
protected section.
private section.
ENDCLASS.



CLASS ZABAP003_CL_INTEGRATION_JSON_1 IMPLEMENTATION.


  method ZNT_009_IF_INTEGRATION~CALL_SERVICE.
  endmethod.


  METHOD ZNT_009_IF_INTEGRATION~SEND_SERVICE.

**RFC NAME
    DATA(lo_log) = NEW znt_009_cl_save_log( ).
    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( me ).
    DATA(lv_objectname) = CONV tabname( lv_classname+7 ).

    CALL METHOD lo_log->save_log
      EXPORTING
        iv_request          = iv_request
        iv_response         = iv_response
        iv_request_tabname  = iv_request_tabname
        iv_response_tabname = iv_response_tabname
        iv_status           = iv_status
        iv_objectname       = lv_objectname "CONV tabname( lv_classname+7 )
        iv_direction        = znt_009_if_integration=>mc_direction_outbound
        iv_int_format       = iv_int_format.
  ENDMETHOD.
ENDCLASS.
