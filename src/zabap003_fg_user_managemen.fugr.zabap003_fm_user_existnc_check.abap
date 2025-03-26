FUNCTION zabap003_fm_user_existnc_check.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SAP_SYSTEM) LIKE  SY-SYSID
*"     VALUE(PERS_NO) TYPE  ZABAP003_E_PERSNO
*"     VALUE(USERNAME) LIKE  BAPIBNAME-BAPIBNAME
*"     VALUE(TC_NO) TYPE  ZABAP003_E_TC_NO
*"     VALUE(MOB_NUMBER) TYPE  AD_MBNMBR1
*"     VALUE(E_MAIL) TYPE  AD_SMTPADR
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA : lv_rfc_name    TYPE tfdir-funcname,
         lv_destination TYPE rfcdest,
         lv_subty       TYPE subty,
         ls_address     TYPE bapiaddr3,
         ls_logondata   TYPE bapilogond,
         ls_islocked    TYPE bapislockd,
         lt_return      TYPE TABLE OF bapiret2,
         lv_exc_msg     TYPE /iwbep/mgw_bop_rfc_excep_text,
         ls_request     TYPE zabap003_s_user_check_req.

  ls_request = VALUE #( sap_system  = sap_system
                        pers_no     = pers_no
                        username    = username
                        tc_no       = tc_no
                        mob_number  = mob_number
                        e_mail      = e_mail ).

  CLEAR   : return, lv_exc_msg.
  REFRESH : lt_return.

  PERFORM system_check CHANGING return .
**
  PERFORM send_service_user_check USING ls_request
                                        return
                                        return-type.
**
  CHECK return-type NE 'E'.

  TRANSLATE e_mail TO UPPER CASE.


  PERFORM get_destination USING    sap_system
                          CHANGING lv_destination
                                   return.
**
  PERFORM send_service_user_check USING ls_request
                                        return
                                        return-type.
**
  CHECK return-type NE 'E'.

  "Kullanıcı ana verileri kontrol.
  CLEAR : lv_rfc_name.
  lv_rfc_name    = 'BAPI_USER_GET_DETAIL'.

  PERFORM user_get_detail TABLES   lt_return
                          USING    lv_rfc_name
                                   lv_destination
                                   username
                          CHANGING ls_address
                                   ls_logondata
                                   ls_islocked
                                   lv_exc_msg
                                   return.
**
  PERFORM send_service_user_check USING ls_request
                                        return
                                        return-type.
**
  CHECK return-type NE 'E'.

  IF sy-subrc EQ 0 AND ( ls_logondata-gltgb => sy-datum  OR
                         ls_logondata-gltgb IS INITIAL ) AND
                       ( ls_islocked-glob_lock EQ  'U'   AND
                         ls_islocked-local_lock EQ 'U'   AND
                         ls_islocked-no_user_pw EQ 'U' ).

    "HR verileri kontrolü.
    CASE sy-sysid.
*      WHEN 'NFP'.
      WHEN 'NEP'.
        CLEAR : sap_system.
*        sap_system = 'NCP'.
        sap_system = 'NEP'.
      WHEN OTHERS.
        CLEAR : sap_system.
*        sap_system = 'NCD'.
        sap_system = 'NED'.
    ENDCASE.

    PERFORM get_destination USING    sap_system
                            CHANGING lv_destination
                                     return.
**
    PERFORM send_service_user_check USING ls_request
                                          return
                                          return-type.
**
    CHECK return-type NE 'E'.

    CLEAR : lv_rfc_name, lv_subty.
*    lv_rfc_name    = 'ZUSER_EXISTENCE_CHECK_HR'.
    lv_rfc_name    = 'ZABAP003_FM_USER_PASS_RST_MAIL'.
    lv_subty       = '01'.

    PERFORM user_exi_check_hr USING    sap_system
                                       pers_no
                                       username
                                       tc_no
                                       mob_number
                                       e_mail
                                       lv_subty
                                       lv_rfc_name
                                       lv_destination
                              CHANGING lv_exc_msg
                                       return.

  ELSE.
    READ TABLE lt_return INTO return INDEX 1.
    IF return IS INITIAL.
      return-type    = 'E'.
      return-message = TEXT-004.
    ENDIF.
  ENDIF.

  CLEAR : lv_rfc_name, lv_destination, lv_subty,
          sap_system, pers_no, username, tc_no,
          mob_number, e_mail, lv_exc_msg.


  PERFORM send_service_user_check USING ls_request
                                        return
                                        return-type.
ENDFUNCTION.
FORM send_service_user_check USING is_request  TYPE zabap003_s_user_check_req
                                   is_response TYPE bapiret2
                                   iv_type     TYPE znt_009_e_status.

  DATA(lo_object) = NEW zabap003_cl_integration_json_1( ).
  DATA(lv_request) = /ui2/cl_json=>serialize( data   = is_request ).
  DATA(lv_response) = /ui2/cl_json=>serialize( data   = is_response ).

  lo_object->znt_009_if_integration~send_service(
      iv_request          = lv_request
      iv_response         = lv_response
      iv_request_tabname  = 'ZABAP003_S_USER_CHECK_REQ'
      iv_response_tabname = 'BAPIRET2'
      iv_int_format       = znt_009_if_integration=>mc_int_format_json
      iv_status           = iv_type ).

ENDFORM.
