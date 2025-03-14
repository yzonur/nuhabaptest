*&---------------------------------------------------------------------*
*& Include          ZPP012_I_003
*&---------------------------------------------------------------------*

MODULE pbo OUTPUT.
  lcl_main=>pbo( iv_scrn = sy-dynnr ).
ENDMODULE.

MODULE pai INPUT.
  lcl_main=>pai( iv_scrn = sy-dynnr ).
ENDMODULE.
MODULE ext INPUT.
  lcl_main=>ext( iv_scrn = sy-dynnr ).
ENDMODULE.
