REPORT zarchive_assess_tool.

CLASS dbl_clk DEFINITION DEFERRED.

*Include for Declaration
INCLUDE z_archive_at_top.

*Include for Selection Screen
INCLUDE z_archive_at_ssr.

*Include Contains Archieve Logic
INCLUDE z_archive_at_cls.

INCLUDE z_archive_at_pbo.

INCLUDE z_archive_at_pai.

INCLUDE z_archive_at_sub.

*Event for Initializing Screen Elements
INITIALIZATION.
  s_schema-option = 'EQ'.
  s_schema-sign = 'I'.
  s_schema-low = 'SAPHANADB'.
  APPEND s_schema.
  system_id = sy-sysid.

AT SELECTION-SCREEN OUTPUT.
  IF p_rad1 EQ ' '.
    LOOP AT SCREEN.
      IF screen-group1 = 'MOD'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF p_rad2 EQ 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'MOD'.
        screen-active = 1.
        MODIFY SCREEN.
        CLEAR screen.
      ENDIF.
    ENDLOOP.
  ENDIF.

*Changes on 22-05-24 (For Disk Graph)
  IF p_rad3 EQ 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'MOD'.
        screen-active = 1.
        MODIFY SCREEN.
        CLEAR screen.
      ENDIF.
    ENDLOOP.
  ENDIF.

START-OF-SELECTION.
  DATA zget_data TYPE REF TO dbl_clk.
  CREATE OBJECT zget_data.

  IF p_rad1 EQ 'X'.
    CALL METHOD dbl_clk=>get_data( ).

  ELSEIF p_rad2 EQ 'X'.
    CALL METHOD dbl_clk=>get_dbhist.

  ELSEIF p_rad3 EQ 'X'.
    CALL METHOD dbl_clk=>get_dbdisk( ).
  ENDIF.

*&---------------------------------------------------------------------*
*& Form zdynamic
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zdynamic .
*  CALL METHOD cl_abap_typedescr=>describe_by_name
*  EXPORTING
*    p_name         = lv_table
*  RECEIVING
*    p_descr_ref    = o_typedescr
*  EXCEPTIONS
*    type_not_found = 1
*    OTHERS         = 2.
*IF sy-subrc <> 0.
** Implement suitable error handling here
*ENDIF.
*
*IF o_typedescr IS BOUND.
*  o_structdescr ?= o_typedescr.
*ENDIF.
*
*IF o_structdescr IS BOUND.
*  CALL METHOD cl_abap_tabledescr=>create
*    EXPORTING
*      p_line_type = o_structdescr
*    RECEIVING
*      p_result    = o_tabledescr.
*ENDIF.
*
**Creating Object
*DATA:
*  fs_ref TYPE REF TO data,
*  it_ref TYPE REF TO data.
*
*CREATE DATA fs_ref TYPE HANDLE o_structdescr.
*CREATE DATA it_ref TYPE HANDLE o_tabledescr.
*
**Value Assignment
*FIELD-SYMBOLS <fs>.
*FIELD-SYMBOLS <fwa>   TYPE any.
*FIELD-SYMBOLS <fitab> TYPE ANY TABLE.
*
**Mapping the values
*ASSIGN fs_ref->* TO <fwa>.
*ASSIGN it_ref->* TO <fitab>.
*
**Retriving the Data
*SELECT *
*FROM (lv_table)
*INTO TABLE <fitab>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  DATA:
  l_mem_sum2 TYPE string.

  SET PF-STATUS 'DBHIST'.
* SET TITLEBAR 'xxx'.t

  IF lcl_cust2 IS INITIAL.
    CREATE OBJECT lcl_cust2
      EXPORTING
*       parent         = parent
        container_name = 'CONTAINER1'.
  ENDIF.

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = if_salv_c_bool_sap=>false
          r_container  = lcl_cust2
        IMPORTING
          r_salv_table = DATA(lcl_salv3)
        CHANGING
          t_table      = itab.
    CATCH cx_salv_msg.
  ENDTRY.

  CALL METHOD lcl_salv3->get_columns
    RECEIVING
      value = DATA(lcl_columns3).

  lcl_columns3->set_optimize( 'X' ).
*  DATA(lcl_column2) = lcl_columns2->get_column( `YEAR` ).
*  lcl_column2->set_long_text( `Year`).
*
*  lcl_column2 = lcl_columns2->get_column( `MONTH` ).
*  lcl_column2->set_long_text( `Month`).

  DATA(lcl_column3) = lcl_columns3->get_column( `POPER` ).
  lcl_column3->set_long_text( `Period`).

  lcl_column3 = lcl_columns3->get_column( `AGGRESSIVE` ).
  lcl_column3->set_long_text( `Aggressive Archiving (40%)`).

  lcl_column3 = lcl_columns3->get_column( `MODERATE` ).
  lcl_column3->set_long_text( `Moderate Archiving (25%)`).

*  lcl_column2 = lcl_columns2->get_column( `DISK_USED_DATA` ).
*  lcl_column2->set_long_text( `Size (Actual + Projected)`).    "Actual Code

**Changes on 21-05-24
*  lcl_column2 = lcl_columns2->get_column( `MEM_MON_GRW` ).
*  lcl_column2->set_long_text( `Memory Size (Actual + Projected)`).

  lcl_column3 = lcl_columns3->get_column( `DISK_USED_DATA` ).
  lcl_column3->set_long_text( `Disk Size(GB)`).

*Changes on 03-06-24 (Adding Field Label for additional field)
  lcl_column3 = lcl_columns3->get_column( `ACT_DISK` ).
  lcl_column3->set_long_text( `Actual`).


  lcl_column3 = lcl_columns3->get_column( `PROJ_DISK` ).
  lcl_column3->set_long_text( `Projected`).

  lo_obj_col = lcl_salv3->get_columns( ).
  TRY.
      lo_hide_col ?= lo_obj_col->get_column( 'MEM_MON_GRW' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

      lo_hide_col ?= lo_obj_col->get_column( 'AVG_MEM_GRW' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

      lo_hide_col ?= lo_obj_col->get_column( 'AVG_DISK_GRW' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

      lo_hide_col ?= lo_obj_col->get_column( 'ACT_MEM' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

      lo_hide_col ?= lo_obj_col->get_column( 'PROJ_MEM' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

    CATCH cx_salv_not_found.
  ENDTRY.

  DATA l_obj3 TYPE REF TO dbl_clk.
  CREATE OBJECT l_obj3.

  lr_event = lcl_salv3->get_event( ).
  SET HANDLER l_obj3->on_user_command FOR lr_event.

  CALL METHOD lcl_salv3->display.


  LOOP AT itab INTO DATA(ls_tab2).
    DATA(lv_tabix2) = sy-tabix.
    PERFORM values2 USING ls_tab2 lv_tabix2.

    fs_column_texts-coltxt = ls_tab2-poper.
    APPEND fs_column_texts TO it_column_texts.
    CLEAR fs_column_texts.
  ENDLOOP.

  l_mem_sum2 = g_disk_sum.

  CONCATENATE sy-sysid 'Size and Growth Estimates (GB) Average Monthly Growth =  ' l_mem_sum2 'GB' INTO heading2
                                                                                           SEPARATED BY space.

  CONCATENATE sy-sysid 'Volume (GB)' INTO lv_yaxis_tile2 SEPARATED BY space.

  CALL FUNCTION 'GFW_PRES_SHOW'
    EXPORTING
      container         = 'GRAPH_CONTAINER1'
      presentation_type = co_gfw_prestype_lines
*     presentation_type = co_gfw_prestype_area
      header            = heading2
      y_axis_title      = lv_yaxis_tile2
    TABLES
      values            = it_values
      column_texts      = it_column_texts
    EXCEPTIONS
      error_occurred    = 1
      OTHERS            = 2.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form values2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_TAB2
*&      --> LV_TABIX2
*&---------------------------------------------------------------------*
FORM values2  USING    p_ls_tab2 TYPE ty_disk
                       p_lv_tabix2.
  CONSTANTS lc_data_size2 TYPE string VALUE 'Size (Actual + Projected)'.
  CONSTANTS lc_advm2     TYPE string VALUE 'Aggresive Archiving (40%)'.
  CONSTANTS lc_mdvm2      TYPE string VALUE 'Moderate Archiving (25%)'.
  CLEAR fs_values.

  CASE p_lv_tabix2.
    WHEN 1.
      fs_values-rowtxt = lc_advm2.
      fs_values-val1 = p_ls_tab2-aggressive.
      APPEND fs_values TO it_values.

      fs_values-rowtxt = lc_mdvm2.
      fs_values-val1 = p_ls_tab2-moderate.
      APPEND fs_values TO it_values.

      fs_values-rowtxt = lc_data_size2.
      fs_values-val1 = p_ls_tab2-disk_used_data.
      APPEND fs_values TO it_values.

    WHEN 2.
      fs_values-val2 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val2 WHERE rowtxt = lc_advm2.

      fs_values-val2 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val2 WHERE rowtxt = lc_mdvm2.

      fs_values-val2 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val2 WHERE rowtxt = lc_data_size2.

    WHEN 3.
      fs_values-val3 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val3 WHERE rowtxt = lc_advm2.

      fs_values-val3 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val3 WHERE rowtxt = lc_mdvm2.

      fs_values-val3 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val3 WHERE rowtxt = lc_data_size2.

    WHEN 4.
      fs_values-val4 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val4 WHERE rowtxt = lc_advm2.

      fs_values-val4 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val4 WHERE rowtxt = lc_mdvm2.

      fs_values-val4 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val4 WHERE rowtxt = lc_data_size2.

    WHEN 5.
      fs_values-val5 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val5 WHERE rowtxt = lc_advm2.

      fs_values-val5 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val5 WHERE rowtxt = lc_mdvm2.

      fs_values-val5 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val5 WHERE rowtxt = lc_data_size2.

    WHEN 6.
      fs_values-val6 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val6 WHERE rowtxt = lc_advm2.

      fs_values-val6 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val6 WHERE rowtxt = lc_mdvm2.

      fs_values-val6 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val6 WHERE rowtxt = lc_data_size2.

    WHEN 7.
      fs_values-val7 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val7 WHERE rowtxt = lc_advm2.

      fs_values-val7 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val7 WHERE rowtxt = lc_mdvm2.

      fs_values-val7 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val7 WHERE rowtxt = lc_data_size2.

    WHEN 8.
      fs_values-val8 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val8 WHERE rowtxt = lc_advm2.

      fs_values-val8 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val8 WHERE rowtxt = lc_mdvm2.

      fs_values-val8 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val8 WHERE rowtxt = lc_data_size2.

    WHEN 9.
      fs_values-val9 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val9 WHERE rowtxt = lc_advm2.

      fs_values-val9 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val9 WHERE rowtxt = lc_mdvm2.

      fs_values-val9 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val9 WHERE rowtxt = lc_data_size2.

    WHEN 10.
      fs_values-val10 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val10 WHERE rowtxt = lc_advm2.

      fs_values-val10 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val10 WHERE rowtxt = lc_mdvm2.

      fs_values-val10 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val10 WHERE rowtxt = lc_data_size2.

    WHEN 11.
      fs_values-val11 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val11 WHERE rowtxt = lc_advm2.

      fs_values-val11 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val11 WHERE rowtxt = lc_mdvm2.

      fs_values-val11 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val11 WHERE rowtxt = lc_data_size2.

    WHEN 12.
      fs_values-val12 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val12 WHERE rowtxt = lc_advm2.

      fs_values-val12 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val12 WHERE rowtxt = lc_mdvm2.

      fs_values-val12 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val12 WHERE rowtxt = lc_data_size2.

    WHEN 13.
      fs_values-val13 = p_ls_tab2-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val13 WHERE rowtxt = lc_advm2.

      fs_values-val13 = p_ls_tab2-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val13 WHERE rowtxt = lc_mdvm2.

      fs_values-val13 = p_ls_tab2-disk_used_data.
      MODIFY it_values FROM fs_values TRANSPORTING val13 WHERE rowtxt = lc_data_size2.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
