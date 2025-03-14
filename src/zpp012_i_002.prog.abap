*&---------------------------------------------------------------------*
*& Include          ZPP012_I_002
*&---------------------------------------------------------------------*
CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF ms_structure_names,
        s0101 TYPE tabname VALUE 'ZPP012_S_001',
      END OF ms_structure_names,

      BEGIN OF ms_alv_components,
        fcat TYPE char10 VALUE 'FCAT',
        grid TYPE char10 VALUE 'GRID',
        prnt TYPE char10 VALUE 'PRNT',
        cont TYPE char10 VALUE 'CONT',
        layo TYPE char10 VALUE 'LAYO',
        vari TYPE char10 VALUE 'VARI',
        sort TYPE char10 VALUE 'SORT',
        itab TYPE char10 VALUE 'ITAB',
        styl TYPE char10 VALUE 'STYLE',
      END OF ms_alv_components,

      BEGIN OF ms_ucomm,
        back   TYPE sy-ucomm VALUE 'EX001',
        leave  TYPE sy-ucomm VALUE 'EX002',
        exit   TYPE sy-ucomm VALUE 'EX003',

        cancel TYPE sy-ucomm VALUE 'BT001',
      END OF ms_ucomm,

      BEGIN OF ms_toolbar,
        cancel TYPE ui_func VALUE 'BT001',
      END OF ms_toolbar,

      BEGIN OF ms_gui,
        status TYPE char20 VALUE 'STATUS_',
        title  TYPE char20 VALUE 'TITLE_',
      END OF ms_gui,

      BEGIN OF ms_scr,
        s0100 TYPE sy-dynnr VALUE '0100',
        s0101 TYPE sy-dynnr VALUE '0101',
      END OF ms_scr.

    CLASS-METHODS:
      refresh_alv   IMPORTING iv_scrn TYPE sy-dynnr,
      show_messages IMPORTING it_ret  TYPE bapirettab,

      get_data    RETURNING VALUE(rv_ok) TYPE abap_bool,
      start       IMPORTING VALUE(iv_ok) TYPE abap_bool,

      pbo IMPORTING VALUE(iv_scrn) TYPE sy-dynnr,
      pai IMPORTING VALUE(iv_scrn) TYPE sy-dynnr,
      ext IMPORTING VALUE(iv_scrn) TYPE sy-dynnr.

  PRIVATE SECTION.
    CLASS-DATA:
      BEGIN OF ms_alv,
        BEGIN OF s0100,
          cont TYPE REF TO cl_gui_custom_container,
        END OF s0100,

        BEGIN OF s0101,
          itab TYPE STANDARD TABLE OF zpp012_s_001,
          grid TYPE REF TO cl_gui_alv_grid,
          fcat TYPE lvc_t_fcat,
          layo TYPE lvc_s_layo,
          vari TYPE disvariant,
          sort TYPE lvc_t_sort,
        END OF s0101,
      END OF ms_alv.

    CLASS-METHODS:
      build_alv  IMPORTING VALUE(iv_scrn_alv) TYPE sy-dynnr
                           VALUE(iv_scrn_gui) TYPE sy-dynnr,
      build_cont IMPORTING VALUE(iv_ccnt) TYPE scrfname
                 RETURNING VALUE(ro_cont) TYPE REF TO cl_gui_custom_container,
      build_fcat IMPORTING VALUE(iv_scrn) TYPE char4
                 RETURNING VALUE(rt_fcat) TYPE lvc_t_fcat,
      build_grid IMPORTING VALUE(io_cont) TYPE REF TO cl_gui_custom_container
                 RETURNING VALUE(ro_grid) TYPE REF TO cl_gui_alv_grid,
      build_layo IMPORTING VALUE(iv_scrn) TYPE char4
                 RETURNING VALUE(rs_layo) TYPE lvc_s_layo,
      build_vari IMPORTING VALUE(iv_scrn) TYPE char4
                 RETURNING VALUE(rs_vari) TYPE disvariant,
      build_sort IMPORTING VALUE(iv_scrn) TYPE char4
                 RETURNING VALUE(rt_sort) TYPE lvc_t_sort,

      on_button_click          FOR EVENT button_click          OF cl_gui_alv_grid IMPORTING sender es_col_id es_row_no,
      on_data_changed_finished FOR EVENT data_changed_finished OF cl_gui_alv_grid IMPORTING sender e_modified et_good_cells,
      on_double_click          FOR EVENT double_click          OF cl_gui_alv_grid IMPORTING sender e_row e_column es_row_no,
      on_hotspot               FOR EVENT hotspot_click         OF cl_gui_alv_grid IMPORTING sender e_row_id e_column_id es_row_no,
      on_context_menu_request  FOR EVENT context_menu_request  OF cl_gui_alv_grid IMPORTING sender e_object,
      on_toolbar               FOR EVENT toolbar               OF cl_gui_alv_grid IMPORTING sender e_object e_interactive,
      on_ucomm                 FOR EVENT user_command          OF cl_gui_alv_grid IMPORTING sender e_ucomm,

      ucomm_cancel

      .
ENDCLASS.
CLASS lcl_main IMPLEMENTATION.
  METHOD build_alv.
    FIELD-SYMBOLS : <lo_grid> TYPE REF TO cl_gui_alv_grid,
                    <lo_prnt> TYPE REF TO cl_gui_container,
                    <lo_cont> TYPE REF TO cl_gui_custom_container.

    DATA(lv_str_alv) = 'S' && iv_scrn_alv.
    ASSIGN COMPONENT lv_str_alv OF STRUCTURE ms_alv TO FIELD-SYMBOL(<ls_alv>).
    IF <ls_alv> IS ASSIGNED.
      ASSIGN COMPONENT ms_alv_components-grid OF STRUCTURE <ls_alv> TO <lo_grid>.
      IF <lo_grid> IS ASSIGNED.
        IF <lo_grid> IS NOT BOUND.

          " Grid Oluşturma
          DATA(lv_str_gui) = 'S' && iv_scrn_gui.
          ASSIGN COMPONENT lv_str_gui OF STRUCTURE ms_alv TO FIELD-SYMBOL(<ls_gui>).
          IF <ls_gui> IS ASSIGNED.
            ASSIGN COMPONENT ms_alv_components-cont OF STRUCTURE <ls_gui> TO <lo_cont>.
            IF <lo_cont> IS ASSIGNED.
              <lo_grid> = lcl_main=>build_grid( io_cont = <lo_cont> ).
            ENDIF.
          ENDIF.

          " Fieldcatalog oluşturma
          ASSIGN COMPONENT ms_alv_components-fcat OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<lt_fcat>).
          IF <lt_fcat> IS ASSIGNED.
            CLEAR : <lt_fcat>.
            <lt_fcat> = build_fcat( iv_scrn = iv_scrn_alv ).
          ENDIF.

          " Layout oluşturma
          ASSIGN COMPONENT ms_alv_components-layo OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<ls_layo>).
          IF <ls_layo> IS ASSIGNED.
            CLEAR : <ls_layo>.
            <ls_layo> = lcl_main=>build_layo( iv_scrn = iv_scrn_alv ).
          ENDIF.

          " Variant oluşturma
          ASSIGN COMPONENT ms_alv_components-vari OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<ls_vari>).
          IF <ls_vari> IS ASSIGNED.
            CLEAR : <ls_vari>.
            <ls_vari> = lcl_main=>build_vari( iv_scrn = iv_scrn_alv ).
          ENDIF.

          " Sort Tablosu oluşturma
          ASSIGN COMPONENT ms_alv_components-sort OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<lt_sort>).
          IF <lt_sort> IS ASSIGNED.
            CLEAR : <lt_sort>.
            <lt_sort> = lcl_main=>build_sort( iv_scrn = iv_scrn_alv ).
          ENDIF.

          " Display Alv
          ASSIGN COMPONENT ms_alv_components-itab OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<lt_itab>).
          IF <lt_itab> IS ASSIGNED.
            <lo_grid>->set_table_for_first_display(
              EXPORTING
                i_bypassing_buffer            = abap_true
                is_variant                    = <ls_vari>
                i_save                        = 'A'
                is_layout                     = <ls_layo>
              CHANGING
                it_outtab                     = <lt_itab>
                it_fieldcatalog               = <lt_fcat>
                it_sort                       = <lt_sort>
              EXCEPTIONS
                invalid_parameter_combination = 1
                program_error                 = 2
                too_many_lines                = 3
                OTHERS                        = 4
            ).
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

            SET HANDLER : on_button_click          FOR <lo_grid>,
                          on_data_changed_finished FOR <lo_grid>,
                          on_double_click          FOR <lo_grid>,
                          on_hotspot               FOR <lo_grid>,
                          on_context_menu_request  FOR <lo_grid>,
                          on_toolbar               FOR <lo_grid>,
                          on_ucomm                 FOR <lo_grid>.
            <lo_grid>->set_toolbar_interactive( ).

            CALL METHOD <lo_grid>->set_ready_for_input
              EXPORTING
                i_ready_for_input = 1.

            CALL METHOD <lo_grid>->register_edit_event
              EXPORTING
                i_event_id = cl_gui_alv_grid=>mc_evt_enter.

            CALL METHOD <lo_grid>->register_edit_event
              EXPORTING
                i_event_id = cl_gui_alv_grid=>mc_evt_modified.
          ENDIF.
        ELSE.
          cl_gui_cfw=>flush( ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
  METHOD build_cont.
    CREATE OBJECT ro_cont
      EXPORTING
        container_name              = iv_ccnt
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.
  METHOD build_fcat.
    DATA(lv_str) = |{ 'S' }{ iv_scrn }|.
    ASSIGN COMPONENT lv_str OF STRUCTURE ms_structure_names TO FIELD-SYMBOL(<lv_str>).
    IF <lv_str> IS ASSIGNED.
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = <lv_str>
          i_bypassing_buffer     = 'X'
        CHANGING
          ct_fieldcat            = rt_fcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      LOOP AT rt_fcat REFERENCE INTO DATA(lr_fcat).
        CASE lr_fcat->fieldname.
          WHEN 'SLCTD'.
            lr_fcat->checkbox = abap_true.
            lr_fcat->edit     = abap_true.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  METHOD build_grid.
    CREATE OBJECT ro_grid
      EXPORTING
        i_parent          = io_cont
        i_appl_events     = abap_true
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.
  METHOD build_layo.
    rs_layo-sel_mode   = 'A'.
    rs_layo-zebra      = abap_true.
    rs_layo-cwidth_opt = abap_true.

    CASE iv_scrn.
      WHEN ms_scr-s0101.
        rs_layo-no_rowmark = abap_true.
    ENDCASE.
  ENDMETHOD.
  METHOD build_vari.
    CASE iv_scrn.
      WHEN ms_scr-s0101.
        rs_vari = VALUE #( report = sy-repid username = sy-uname handle = iv_scrn ).
    ENDCASE.
  ENDMETHOD.
  METHOD build_sort.
    CASE iv_scrn.
      WHEN ms_scr-s0101.
    ENDCASE.
  ENDMETHOD.
  METHOD on_button_click.

  ENDMETHOD.
  METHOD on_data_changed_finished.
    IF e_modified IS NOT INITIAL.
      CASE sender.
        WHEN ms_alv-s0101-grid.
          lcl_main=>refresh_alv( iv_scrn = sy-dynnr ).
      ENDCASE.
    ENDIF.
  ENDMETHOD.
  METHOD on_double_click.

  ENDMETHOD.
  METHOD on_hotspot.
    CASE e_column_id-fieldname.
      WHEN 'MATNR'.

    ENDCASE.
  ENDMETHOD.
  METHOD on_context_menu_request.
    DATA: lt_fcodes TYPE ui_funcattr,
          ls_fcode  TYPE uiattentry,
          ls_func   TYPE ui_func,
          lt_func   TYPE ui_functions.

  ENDMETHOD.
  METHOD on_toolbar.
    DELETE e_object->mt_toolbar WHERE ( function EQ '&REFRESH'          OR
                                        function EQ '&CHECK'            OR
                                        function EQ '&LOCAL&CUT'        OR
                                        function EQ '&LOCAL&COPY'       OR
                                        function EQ '&LOCAL&PASTE'      OR
                                        function EQ '&LOCAL&UNDO'       OR
                                        function EQ '&LOCAL&APPEND'     OR
                                        function EQ '&LOCAL&INSERT_ROW' OR
                                        function EQ '&LOCAL&DELETE_ROW' OR
                                        function EQ '&PRINT_BACK'       OR
                                        function EQ '&INFO'             OR
                                        function EQ '&LOCAL&COPY_ROW' ).

    APPEND VALUE #( function  = ms_toolbar-cancel
                    icon      = icon_cancel
                    text      = TEXT-t01
                    quickinfo = TEXT-t01  ) TO e_object->mt_toolbar.
  ENDMETHOD.
  METHOD on_ucomm.
    sender->get_selected_rows(
      IMPORTING
        et_row_no = DATA(lt_rows)
    ).
    DATA(lv_selected_lines) = lines( lt_rows ).

    CASE sender.
      WHEN ms_alv-s0101-grid.
        LOOP AT lt_rows REFERENCE INTO DATA(lr_rows).
          DATA(lr_0101)  = REF #( ms_alv-s0101-itab[ lr_rows->row_id ] OPTIONAL ).
          lr_0101->slctd = abap_true.
        ENDLOOP.

        CASE e_ucomm.
          WHEN ms_ucomm-cancel.
            lcl_main=>ucomm_cancel( ).
            lcl_main=>get_data( ).
        ENDCASE.

        LOOP AT ms_alv-s0101-itab REFERENCE INTO lr_0101 WHERE slctd EQ abap_true.
          lr_0101->slctd = abap_false.
        ENDLOOP.

        lcl_main=>refresh_alv( iv_scrn = ms_scr-s0101 ).
    ENDCASE.
  ENDMETHOD.
  METHOD ucomm_cancel.
    DATA :
      ls_return TYPE bapiret1,
      lt_return TYPE bapirettab.

    LOOP AT ms_alv-s0101-itab REFERENCE INTO DATA(lr_0101) WHERE slctd EQ abap_true.
      CALL FUNCTION 'BAPI_PROCORDCONF_CANCEL'
        EXPORTING
          confirmation        = lr_0101->rueck
          confirmationcounter = lr_0101->rmzhl
        IMPORTING
          return              = ls_return.
      IF ls_return-type EQ 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        APPEND VALUE #( type       = 'E'
                        id         = 'ZPP000'
                        number     = '002'
                        message_v1 = lr_0101->rueck
                        message_v2 = lr_0101->rmzhl ) TO lt_return.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.

        APPEND VALUE #( type       = 'S'
                        id         = 'ZPP000'
                        number     = '003'
                        message_v1 = lr_0101->rueck
                        message_v2 = lr_0101->rmzhl ) TO lt_return.
      ENDIF.
    ENDLOOP.

    lcl_main=>show_messages( it_ret = lt_return ).
  ENDMETHOD.
  METHOD refresh_alv.
    FIELD-SYMBOLS : <lo_grid> TYPE REF TO cl_gui_alv_grid,
                    <ls_layo> TYPE lvc_s_layo.

    DATA(lv_scrn) = |{ 'S' }{ iv_scrn }|.
    ASSIGN COMPONENT lv_scrn OF STRUCTURE ms_alv TO FIELD-SYMBOL(<ls_alv>).
    IF <ls_alv> IS ASSIGNED.
      ASSIGN COMPONENT ms_alv_components-grid OF STRUCTURE <ls_alv> TO <lo_grid>.
      ASSIGN COMPONENT ms_alv_components-layo OF STRUCTURE <ls_alv> TO <ls_layo>.
      IF ( <lo_grid> IS ASSIGNED AND <lo_grid> IS NOT INITIAL ) AND
         ( <ls_layo> IS ASSIGNED AND <ls_layo> IS NOT INITIAL ).
        CALL METHOD <lo_grid>->set_frontend_layout
          EXPORTING
            is_layout = <ls_layo>.

        <lo_grid>->refresh_table_display(
          EXPORTING
            is_stable      = VALUE lvc_s_stbl( row = abap_true col = abap_true ) " With Stable Rows/Columns
            i_soft_refresh = 'X'
          EXCEPTIONS
            finished       = 1
            OTHERS         = 2
        ).
        IF sy-subrc IS NOT INITIAL.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
  METHOD pbo.
    DATA(lv_status) = |{ ms_gui-status }{ iv_scrn }|.
    SET PF-STATUS lv_status.

    DATA(lv_title) = |{ ms_gui-title }{ iv_scrn }|.
    SET TITLEBAR lv_title.

    CASE iv_scrn.
      WHEN ms_scr-s0100.
        IF ms_alv-s0100-cont IS NOT BOUND.
          " Build Container
          ms_alv-s0100-cont = build_cont( iv_ccnt = |{ 'CC_' }{ iv_scrn }| ).

          " Build ALV (0101)
          lcl_main=>build_alv( iv_scrn_gui = iv_scrn iv_scrn_alv = ms_scr-s0101 ).
        ENDIF.
    ENDCASE.
  ENDMETHOD.
  METHOD pai.
    CASE iv_scrn.
      WHEN ms_scr-s0100.

    ENDCASE.
  ENDMETHOD.
  METHOD ext.
    CASE iv_scrn.
      WHEN ms_scr-s0100.
        CASE sy-ucomm.
          WHEN ms_ucomm-back.
            LEAVE TO SCREEN 0.
          WHEN ms_ucomm-leave.
            LEAVE PROGRAM.
          WHEN ms_ucomm-exit.
            LEAVE PROGRAM.
        ENDCASE.
    ENDCASE.
  ENDMETHOD.
  METHOD get_data.
    CLEAR : ms_alv-s0101-itab.

    SELECT ap~aufnr, ap~matnr,
           ar~rueck, ar~rmzhl, ar~ltxa1, ar~gmnga, ar~gmein, ar~ernam,
           ar~budat,
           bg~uret_id, bg~verid, bg~werks, bg~g_lfimg AS lfimg,
           mk~maktx
      FROM afpo AS ap
      INNER JOIN afru          AS ar ON ar~aufnr EQ ap~aufnr
      INNER JOIN zbigs_t_teyit AS bg ON bg~aufnr EQ ar~aufnr
                                    AND bg~uret_id EQ ar~ltxa1
      LEFT  JOIN makt          AS mk ON mk~matnr EQ ap~matnr
                                    AND mk~spras EQ @sy-langu
      WHERE bg~werks   IN @so_werks
        AND ap~aufnr   IN @so_aufnr
        AND bg~uret_id IN @so_urtid
        AND ar~rueck   IN @so_rueck
        AND ar~rmzhl   IN @so_rmzhl
        AND ar~ernam   IN @so_ernam
        AND ar~budat   IN @so_budat
        AND ( stokz EQ @space AND stzhl EQ @space )
      ORDER BY ap~aufnr, bg~uret_id, ar~rueck, ar~rmzhl
      INTO TABLE @DATA(lt_afpo).
    IF sy-subrc EQ 0.
      DELETE ADJACENT DUPLICATES FROM lt_afpo COMPARING aufnr uret_id rueck rmzhl.

      LOOP AT lt_afpo REFERENCE INTO DATA(lr_afpo).
        APPEND INITIAL LINE TO ms_alv-s0101-itab REFERENCE INTO DATA(lr_0101).
        MOVE-CORRESPONDING lr_afpo->* TO lr_0101->*.
      ENDLOOP.

      rv_ok = abap_true.
    ENDIF.
  ENDMETHOD.
  METHOD start.
    IF iv_ok EQ abap_true.
      CALL SCREEN 0100.
    ELSE.
      MESSAGE s001 DISPLAY LIKE 'E'.
    ENDIF.
  ENDMETHOD.
  METHOD show_messages.
    IF it_ret IS NOT INITIAL.
      CALL FUNCTION 'OXT_MESSAGE_TO_POPUP'
        EXPORTING
          it_message = it_ret
        EXCEPTIONS
          bal_error  = 0
          OTHERS     = 0.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
