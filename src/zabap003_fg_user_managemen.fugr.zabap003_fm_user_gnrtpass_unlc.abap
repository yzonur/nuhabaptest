FUNCTION zabap003_fm_user_gnrtpass_unlc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SAP_SYSTEM) TYPE  SY-SYSID
*"     VALUE(USERNAME) LIKE  BAPIBNAME-BAPIBNAME
*"     VALUE(E_MAIL) TYPE  AD_SMTPADR
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------


  DATA: ls_logondata   TYPE bapilogond,
        ls_islocked    TYPE bapislockd,
        lt_return      TYPE TABLE OF bapiret2,
        ls_return      LIKE LINE OF lt_return,
        ls_password    TYPE bapipwd,
        ls_passwordx   TYPE bapipwdx,
        ls_address     TYPE bapiaddr3,
        lv_destination TYPE rfcdest,
        lv_rfc_name    TYPE tfdir-funcname,
        lv_exc_msg     TYPE /iwbep/mgw_bop_rfc_excep_text,
        ls_request     TYPE zabap003_s_user_unlock_req.

  ls_request = VALUE #( sap_system  = sap_system
                        username    = username
                        e_mail      = e_mail ).


  CLEAR : return, gv_ok, lv_exc_msg.
  REFRESH : lt_return.

  PERFORM system_check CHANGING return .
**
  PERFORM send_service_user_unlock USING ls_request
                                         return
                                         return-type.
**
  CHECK return-type NE 'E'.

  PERFORM get_destination USING    sap_system
                          CHANGING lv_destination
                                   return.
**
  PERFORM send_service_user_unlock USING ls_request
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
  PERFORM send_service_user_unlock USING ls_request
                                         return
                                         return-type.
**
  CHECK return-type NE 'E'.

  IF sy-subrc EQ 0 AND ( ls_logondata-gltgb => sy-datum  OR
                         ls_logondata-gltgb IS INITIAL ) AND
                       ( ls_islocked-glob_lock EQ  'U'   AND
                         ls_islocked-local_lock EQ 'U'   AND
                         ls_islocked-no_user_pw EQ 'U' ).

    CLEAR : lv_rfc_name.
    lv_rfc_name    = 'BAPI_USER_UNLOCK'.

    CALL FUNCTION lv_rfc_name DESTINATION lv_destination
      EXPORTING
        username              = username
      TABLES
        return                = lt_return
      EXCEPTIONS
        system_failure        = 1000 MESSAGE lv_exc_msg
        communication_failure = 1001 MESSAGE lv_exc_msg
        OTHERS                = 1002.

    IF sy-subrc NE 0.
      return-type    = 'E'.
      return-message = lv_exc_msg.
**
      PERFORM send_service_user_unlock USING ls_request
                                             return
                                             return-type.
**
      EXIT.
    ENDIF.

    READ TABLE lt_return INTO ls_return INDEX 1.

    CASE ls_return-type.
      WHEN 'S'.
        "YENI SIFRE URET KULLANICIYA TANIMLA MAIL AT.

        CALL FUNCTION 'RSEC_GENERATE_PASSWORD'
          EXPORTING
            output_length   = 8
            security_policy = 'ZUSER_PASS_POLICY'
          IMPORTING
            output          = ls_password-bapipwd
          EXCEPTIONS
            some_error      = 1
            OTHERS          = 2.

        IF sy-subrc <> 0.
          return-message = TEXT-002.
          EXIT.
        ENDIF.

        ls_passwordx-bapipwd = 'X'.

        REFRESH : lt_return.
        CLEAR : lv_rfc_name.

        lv_rfc_name    = 'BAPI_USER_CHANGE'.

        CALL FUNCTION lv_rfc_name DESTINATION lv_destination
          EXPORTING
            username              = username
            password              = ls_password
            passwordx             = ls_passwordx
          TABLES
            return                = lt_return
          EXCEPTIONS
            system_failure        = 1000 MESSAGE lv_exc_msg
            communication_failure = 1001 MESSAGE lv_exc_msg
            OTHERS                = 1002.

        IF sy-subrc NE 0.
          return-type    = 'E'.
          return-message = lv_exc_msg.
**
          PERFORM send_service_user_unlock USING ls_request
                                                 return
                                                 return-type.
**
          EXIT.
        ENDIF.

        LOOP AT lt_return INTO ls_return.
          IF ls_return-type = 'E' OR
             ls_return-type = 'A'.
            CLEAR: return.
            return-type    = 'E'.
            return-message = TEXT-003.
          ENDIF.
        ENDLOOP.
**
        PERFORM send_service_user_unlock USING ls_request
                                               return
                                               return-type.
**
        CHECK return-type NE 'E'.
        gv_ok = 'X'.

*        CALL FUNCTION 'ZUSER_PASS_RESET_MAIL'
        CALL FUNCTION 'ZABAP003_FM_USER_PASS_RST_MAIL'
          EXPORTING
            sap_system = sap_system
            fullname   = ls_address-fullname
            e_mail     = e_mail
            password   = ls_password
          IMPORTING
            return     = return.

      WHEN 'E'.
        return = ls_return.
      WHEN OTHERS.
    ENDCASE.

  ELSE.
    READ TABLE lt_return INTO return INDEX 1.
    IF return IS INITIAL.
      return-type    = 'E'.
      return-message = TEXT-004.
    ENDIF.
  ENDIF.



  PERFORM send_service_user_unlock USING ls_request
                                         return
                                         return-type.
ENDFUNCTION.
FORM send_service_user_unlock USING is_request  TYPE zabap003_s_user_unlock_req
                                    is_response TYPE bapiret2
                                    iv_type     TYPE znt_009_e_status.

  DATA(lo_object) = NEW zabap003_cl_integration_json_2( ).
  DATA(lv_request) = /ui2/cl_json=>serialize( data   = is_request ).
  DATA(lv_response) = /ui2/cl_json=>serialize( data   = is_response ).

  lo_object->znt_009_if_integration~send_service(
      iv_request          = lv_request
      iv_response         = lv_response
      iv_request_tabname  = 'ZABAP003_S_USER_UNLOCK_REQ'
      iv_response_tabname = 'BAPIRET2'
      iv_int_format       = znt_009_if_integration=>mc_int_format_json
      iv_status           = iv_type ).

ENDFORM.
