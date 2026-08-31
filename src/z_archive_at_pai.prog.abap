*&---------------------------------------------------------------------*
*& Include          Z_ARCHIVE_AT_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  CASE sy-ucomm.
    WHEN 'DETAIL'.
      CALL SCREEN 0100.
*      CLEAR:
*        it_values,
*        it_dsumm.
*      CLEAR it_dsumm.
    WHEN OTHERS.
*      CLEAR it_dsumm.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
