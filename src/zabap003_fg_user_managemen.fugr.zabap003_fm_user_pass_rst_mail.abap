FUNCTION zabap003_fm_user_pass_rst_mail.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(SAP_SYSTEM) TYPE  SY-SYSID
*"     REFERENCE(FULLNAME) TYPE  AD_NAMTEXT
*"     REFERENCE(E_MAIL) TYPE  AD_SMTPADR
*"     REFERENCE(PASSWORD) TYPE  BAPIPWD
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------


  DATA: wa_docdata LIKE sodocchgi1,
        it_objpack LIKE sopcklsti1 OCCURS 1 WITH HEADER LINE,
        wa_objpack LIKE sopcklsti1,
        it_objhead LIKE solisti1 OCCURS 1 WITH HEADER LINE,
        it_objtxt  LIKE solisti1 OCCURS 10 WITH HEADER LINE,
        wa_objtxt  LIKE solisti1,
        it_objbin  LIKE solisti1 OCCURS 10 WITH HEADER LINE,
        it_objhex  LIKE solix OCCURS 10 WITH HEADER LINE,
        it_reclist LIKE somlreci1 OCCURS 1 WITH HEADER LINE,
        wa_reclist LIKE somlreci1,
        lt_html    TYPE TABLE OF zabap003_t_rmail,
        ls_html    LIKE LINE OF lt_html,
        lv_desc    TYPE zabap003_e_description.

  DATA: wa_lines TYPE i.

  CLEAR: wa_docdata,it_objtxt, it_objtxt[],  it_objpack,  it_objpack[],
         it_objhead, it_objhead[],it_objbin, it_objbin[],it_reclist,
         it_reclist[], ls_html, return, lv_desc.

  REFRESH: lt_html.

  PERFORM system_check CHANGING return .
  CHECK return-type NE 'E'.

  CONCATENATE sap_system ' Sistemi Şifre' INTO wa_docdata-obj_descr.

  IF gv_ok NE 'X'.
    return-type    = 'E'.
    return-message = TEXT-005.
    CLEAR gv_ok.
    EXIT.
  ENDIF.

*  IF sy-sysid NE 'NFD'.
*    return-type    = 'E'.
*    return-message = text-001.
*    EXIT.
*  ENDIF.

  SELECT SINGLE description FROM zabap003_t_u_con
                            INTO  lv_desc
                            WHERE target_sysid = sap_system.
  "--> Mail Body
  SELECT * FROM zabap003_t_rmail INTO CORRESPONDING FIELDS OF TABLE
  lt_html.
  CHECK lt_html IS NOT INITIAL.

  LOOP AT lt_html INTO ls_html .
    CASE ls_html-line.
      WHEN '&B1'. "Kullanıcı ana verileri Tam Adı
        CLEAR : ls_html-line.
        ls_html-line = fullname.
        APPEND ls_html-line TO it_objtxt.
      WHEN '&B2'. "SAP Sistem ID
        CLEAR : ls_html-line.
        ls_html-line = sap_system.
        APPEND ls_html-line TO it_objtxt.
      WHEN '&SID'. "SAP Sistem Açıklaması
        CLEAR : ls_html-line.
        ls_html-line = lv_desc.
        APPEND ls_html-line TO it_objtxt.
      WHEN '&B3'. "Üretilen şifre
        CLEAR : ls_html-line.
        ls_html-line = password.
        IF ls_html-line CA '&'.
          REPLACE ALL OCCURRENCES OF '&' IN ls_html-line WITH '&amp;'.
        ENDIF.
        APPEND ls_html-line TO it_objtxt.

      WHEN OTHERS.
        APPEND ls_html-line TO it_objtxt.
    ENDCASE.
  ENDLOOP.
  "Mail Body <--

  DESCRIBE TABLE it_objtxt      LINES wa_lines.
  READ TABLE it_objtxt      INTO wa_objtxt INDEX wa_lines.
  wa_docdata-doc_size =
      ( wa_lines - 1 ) * 255 + strlen( wa_objtxt ).

  CLEAR wa_objpack-transf_bin.
  wa_objpack-head_start = 1.
  wa_objpack-head_num   = 0.
  wa_objpack-body_start = 1.
  wa_objpack-body_num   = wa_lines.
  wa_objpack-doc_type   = 'HTML'.
  APPEND wa_objpack TO it_objpack.

  CLEAR  wa_reclist.
  wa_reclist-receiver = e_mail. "Mail adresi
  wa_reclist-rec_type = 'U'.
  APPEND wa_reclist TO it_reclist.


  CHECK NOT it_reclist[] IS INITIAL.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = wa_docdata
      put_in_outbox              = 'X'
      sender_address             = 'SAPsifre@nuh.corp'
      sender_address_type        = 'INT'
      commit_work                = 'X'
    TABLES
      packing_list               = it_objpack
      object_header              = it_objhead
      contents_bin               = it_objbin
      contents_txt               = it_objtxt
      contents_hex               = it_objhex
      receivers                  = it_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

  IF sy-subrc NE 0 .
    return-type    = 'E'.
    return-message = TEXT-005.
    CLEAR gv_ok.
  ELSE.
    return-type = 'S'.
*    return-message = 'Mail Gönderildi.'.
*    return-message = e_mail.
    CLEAR gv_ok.
  ENDIF.



ENDFUNCTION.
