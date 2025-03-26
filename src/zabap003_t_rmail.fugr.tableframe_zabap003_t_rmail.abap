*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZABAP003_T_RMAIL
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZABAP003_T_RMAIL   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
