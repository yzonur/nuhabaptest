*&---------------------------------------------------------------------*
*& Report ZPP012_P_001
*&---------------------------------------------------------------------*

REPORT ZPP012_P_001 MESSAGE-ID zpp000.

INCLUDE zpp012_i_001.
INCLUDE zpp012_i_002.
INCLUDE zpp012_i_003.

START-OF-SELECTION.
  DATA(lv_ok) = lcl_main=>get_data( ).

END-OF-SELECTION.
  lcl_main=>start( iv_ok = lv_ok ).
