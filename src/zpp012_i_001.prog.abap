*&---------------------------------------------------------------------*
*& Include          ZPP012_I_001
*&---------------------------------------------------------------------*

TABLES :
  t001w, afru, zbigs_t_teyit.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.

  SELECT-OPTIONS :
    so_werks FOR t001w-werks OBLIGATORY,
    so_aufnr FOR afru-aufnr,
    so_urtid FOR zbigs_t_teyit-uret_id,
    so_rueck FOR afru-rueck,
    so_rmzhl FOR afru-rmzhl,
    so_ernam FOR afru-ernam,
    so_budat FOR afru-budat.

SELECTION-SCREEN END OF BLOCK b1.
