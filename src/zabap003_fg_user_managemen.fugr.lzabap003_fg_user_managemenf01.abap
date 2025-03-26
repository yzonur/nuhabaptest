*----------------------------------------------------------------------*
***INCLUDE LZABAP003_FG_USER_MANAGEMENF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_destination
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SAP_SYSTEM
*&      <-- LV_DESTINATION
*&      <-- RETURN
*&---------------------------------------------------------------------*
FORM get_destination  USING    sap_system
                      CHANGING lv_destination
                               return TYPE bapiret2.

  CLEAR : lv_destination, return.
  "Sadece Fiori Canlı Sistemden İşlem Yapılabilsin.

  CASE sy-sysid.
    WHEN 'NFP'.
      SELECT SINGLE rfc_dest FROM ZABAP003_T_U_CON
                             INTO  lv_destination
                             WHERE target_sysid = sap_system.

    WHEN OTHERS.
      SELECT SINGLE rfc_dest FROM ZABAP003_T_U_CON
                             INTO  lv_destination
                             WHERE target_sysid = sap_system AND
                             prod_system  NE 'X'.
  ENDCASE.

  IF sy-subrc NE 0.
    return-type    = 'E'.
    return-message = text-012.
    EXIT.
  ENDIF.

  IF sy-sysid EQ 'NFP' AND
     sap_system EQ 'NFP'.

    CLEAR : lv_destination.
    lv_destination = 'NONE'.

*  ELSEIF sy-sysid EQ 'NFD' AND
*         sap_system EQ 'NFD'.
  ELSEIF sy-sysid EQ 'NCD' AND
         sap_system EQ 'NCD'.

    CLEAR : lv_destination.
    lv_destination = 'NONE'.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form system_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- RETURN
*&---------------------------------------------------------------------*
FORM system_check CHANGING return TYPE bapiret2..

  DATA: lv_addrstr  TYPE ni_nodeaddr,
        lv_terminal TYPE c LENGTH 40,
        ls_sysprm   TYPE zabap003_t_sy_pm.

  CLEAR : return.

  CALL FUNCTION 'TH_USER_INFO'
    EXPORTING
      client   = sy-mandt
      user     = sy-uname
    IMPORTING
      addrstr  = lv_addrstr
      terminal = lv_terminal.

  TRANSLATE lv_terminal TO UPPER CASE.

  SELECT SINGLE * FROM zabap003_t_sy_pm INTO ls_sysprm.

  IF lv_terminal NE ls_sysprm-terminal OR sy-uname NE ls_sysprm-bname.
    return-type = 'E'.
    return-message = text-013.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_exi_check_hr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SAP_SYSTEM
*&      --> PERS_NO
*&      --> USERNAME
*&      --> TC_NO
*&      --> MOB_NUMBER
*&      --> E_MAIL
*&      --> LV_SUBTY
*&      --> LV_RFC_NAME
*&      --> LV_DESTINATION
*&      <-- LV_EXC_MSG
*&      <-- RETURN
*&---------------------------------------------------------------------*
FORM user_exi_check_hr USING    sap_system
                                pers_no
                                username
                                tc_no
                                mob_number
                                e_mail
                                lv_subty
                                lv_rfc_name
                                lv_destination
                       CHANGING lv_exc_msg
                                return TYPE bapiret2.

  "NCP sistemi HR verileri kontrolü. -->
  CLEAR : lv_exc_msg, return.

  CALL FUNCTION lv_rfc_name DESTINATION lv_destination
    EXPORTING
      sap_system            = sap_system
      pers_no               = pers_no
      username              = username
      tc_no                 = tc_no
      mob_number            = mob_number
      e_mail                = e_mail
      subty                 = lv_subty
    IMPORTING
      return                = return
    EXCEPTIONS
      system_failure        = 1000 MESSAGE lv_exc_msg
      communication_failure = 1001 MESSAGE lv_exc_msg
      OTHERS                = 1002.

  IF sy-subrc NE 0.
    return-type    = 'E'.
    return-message = lv_exc_msg.
  ELSEIF return-type EQ 'S'.
    "Tüm kontroller tamamdır.
    "SMS doğrulaması için sonuç gönder 3rd party
    return-type = 'S'.
    CLEAR return-message.
  ENDIF.
  "NCP sistemi HR verileri kontrolü. <--

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_get_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_RETURN
*&      --> LV_RFC_NAME
*&      --> LV_DESTINATION
*&      --> USERNAME
*&      <-- LS_ADDRESS
*&      <-- LS_LOGONDATA
*&      <-- LS_ISLOCKED
*&      <-- LV_EXC_MSG
*&      <-- RETURN
*&---------------------------------------------------------------------*
FORM user_get_detail TABLES   lt_return
                     USING    lv_rfc_name
                              lv_destination
                              username
                     CHANGING ls_address
                              ls_logondata
                              ls_islocked
                              lv_exc_msg
                              return TYPE bapiret2.

  REFRESH lt_return.
  CLEAR : ls_address, ls_logondata, ls_islocked, lv_exc_msg, return.


  CALL FUNCTION lv_rfc_name DESTINATION lv_destination
    EXPORTING
      username              = username
    IMPORTING
      address               = ls_address
      logondata             = ls_logondata
      islocked              = ls_islocked
    TABLES
      return                = lt_return
    EXCEPTIONS
      system_failure        = 1000 MESSAGE lv_exc_msg
      communication_failure = 1001 MESSAGE lv_exc_msg
      OTHERS                = 1002.

  IF sy-subrc NE 0.
    return-type    = 'E'.
    return-message = lv_exc_msg.
  ENDIF.


ENDFORM.
