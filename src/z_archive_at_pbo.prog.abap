*&---------------------------------------------------------------------*
*& Include          Z_ARCHIVE_AT_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*& THIS MODULE IS FOR THE DETAILS SCREEN WHEN CLICKED ON DETAIL BUTTON
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA gv_tabix TYPE i.

  SET PF-STATUS 'Z056_STATUS1'.

  CLEAR fs_output.
  CLEAR it_details.
  LOOP AT it_output INTO fs_output WHERE check = 'X'.
    SELECT archiving_object
           org_field
           zdate
           ztime
           zseq
           message
           no_of_entries
      FROM z056_archive
      INTO TABLE it_detail
     WHERE archiving_object = fs_output-arch_obj
     ORDER BY zdate DESCENDING
              ztime DESCENDING.

*"Changes made on 03-06-24 (Data displaying repeatedly)
*        sort it_detail by archiving_object DESCENDING org_field DESCENDING zseq DESCENDING message DESCENDING number DESCENDING.
*        DELETE ADJACENT DUPLICATES FROM it_detail COMPARING archiving_object org_field zseq message number.
*"End of Changes 03-06-24

*Changes on 04-06-24.

    READ TABLE it_detail ASSIGNING FIELD-SYMBOL(<fs_date>) INDEX 1.
    IF sy-subrc EQ 0.
      lv_curr_date = <fs_date>-zdate.
*          lv_curr_time = <fs_date>-ztime.
    ENDIF.
    DELETE it_detail WHERE zdate NE lv_curr_date. "AND
*                               ztime NE lv_curr_time.


    SORT it_detail BY org_field DESCENDING zseq DESCENDING message DESCENDING number DESCENDING.
    DELETE ADJACENT DUPLICATES FROM it_detail COMPARING org_field zseq message number.

*    IF sy-subrc EQ 0.
    READ TABLE it_detail INTO DATA(fs_detail) INDEX 1.
    IF sy-subrc EQ 0.
*        DELETE it_detail WHERE archiving_object NE fs_detail-archiving_object
*                            OR zdate NE fs_detail-zdate
*                            OR ztime NE fs_detail-ztime.
    ENDIF.
    APPEND LINES OF it_detail TO it_details.
    CLEAR it_detail.
*      APPEND LINES OF it_detail TO it_details2.
*    ENDIF.
  ENDLOOP.

  SELECT *
    FROM zunarch_document
    INTO TABLE @DATA(it_unarch)
   WHERE archiving_object EQ @fs_output-arch_obj.

  SORT it_unarch BY archiving_object docno.
  DELETE ADJACENT DUPLICATES FROM it_unarch COMPARING archiving_object docno.

  LOOP AT it_dsumm INTO fs_dsumm. "WHERE check EQ 'X'.
    LOOP AT it_details INTO DATA(fs_details) WHERE archiving_object EQ fs_dsumm-arobj.
      fs_detail2-archiving_object = fs_details-archiving_object.
      fs_detail2-org_field = fs_details-org_field.
      fs_detail2-zdate = fs_details-zdate.
      fs_detail2-ztime = fs_details-ztime.
      fs_detail2-zseq = fs_details-zseq.
      fs_detail2-message = fs_details-message.
      CALL FUNCTION 'MOVE_CHAR_TO_NUM'
        EXPORTING
          chr             = fs_details-number
        IMPORTING
          num             = fs_detail2-number
        EXCEPTIONS
          convt_no_number = 1
          convt_overflow  = 2
          OTHERS          = 3.
      CLEAR gv_tabix.
      LOOP AT it_unarch INTO DATA(fs_unarch) WHERE message EQ fs_details-message.
        gv_tabix = gv_tabix + 1.
        fs_detail2-number = gv_tabix.
        MOVE fs_unarch-docno TO fs_detail2-docno.
        APPEND fs_detail2 TO it_detail2.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        APPEND fs_detail2 TO it_detail2.
      ENDIF.
      CLEAR fs_detail2.
    ENDLOOP.
  ENDLOOP.

*  SORT it_detail2 BY zdate ztime zseq.
*  SORT it_detail2 BY org_field zseq. "message.
  SORT it_detail2 BY archiving_object org_field zseq number. "message.

  IF it_detail2 IS NOT INITIAL.

    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = lcl_msg
      CHANGING
        t_table      = it_detail2.

    DATA(lcl_columns) = lcl_msg->get_columns( ).
    lcl_columns->set_optimize( ). " Optimize column width

    lo_get_col = lcl_msg->get_columns( ).

    TRY.
        lo_text ?= lo_get_col->get_column( 'NUMBER' ).
        lo_text->set_short_text( 'Number' ).
        lo_text->set_medium_text( 'No of Entries' ).
        lo_text->set_long_text( 'Number of Entries' ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lo_text ?= lo_get_col->get_column( 'DOCNO' ).
        lo_text->set_short_text( 'Doc. No' ).
        lo_text->set_medium_text( 'Document No.' ).
        lo_text->set_long_text( 'Document Number' ).
      CATCH cx_salv_not_found.
    ENDTRY.

    lcl_msg->set_screen_status(
      pfstatus      = 'Z056_STATUS2'
      report        = sy-repid
      set_functions = lcl_msg->c_functions_all ).

**Changes on 06th Feb
*  DATA l_obj_det TYPE REF TO dbl_clk.
*  CREATE OBJECT l_obj_det.
*
*  DATA(lo_event) = lcl_msg->get_event( ).
**
**  SET HANDLER l_obj_det->sel_chk FOR lo_event.
*  SET HANDLER l_obj_det->clk_det FOR lo_event.
*  SET HANDLER l_obj_det->on_user_command FOR lo_event.

    CALL METHOD lcl_msg->display.

    CLEAR it_detail2.
  ENDIF.
  LEAVE TO SCREEN 0.
*  LEAVE TO SCREEN 0300.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  DATA:
    l_mem_sum TYPE string.

  SET PF-STATUS 'DBHIST'.
* SET TITLEBAR 'xxx'.t

  IF lcl_cust IS INITIAL.
    CREATE OBJECT lcl_cust
      EXPORTING
*       parent         = parent
        container_name = 'CONTAINER'.
  ENDIF.

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = if_salv_c_bool_sap=>false
          r_container  = lcl_cust
        IMPORTING
          r_salv_table = DATA(lcl_salv2)
        CHANGING
          t_table      = itab.
    CATCH cx_salv_msg.
  ENDTRY.

  CALL METHOD lcl_salv2->get_columns
    RECEIVING
      value = DATA(lcl_columns2).

  lcl_columns2->set_optimize( 'X' ).
*  DATA(lcl_column2) = lcl_columns2->get_column( `YEAR` ).
*  lcl_column2->set_long_text( `Year`).
*
*  lcl_column2 = lcl_columns2->get_column( `MONTH` ).
*  lcl_column2->set_long_text( `Month`).

  DATA(lcl_column2) = lcl_columns2->get_column( `POPER` ).
  lcl_column2->set_long_text( `Period`).

  lcl_column2 = lcl_columns2->get_column( `AGGRESSIVE` ).
  lcl_column2->set_long_text( `Aggressive Archiving (40%)`).

  lcl_column2 = lcl_columns2->get_column( `MODERATE` ).
  lcl_column2->set_long_text( `Moderate Archiving (25%)`).

*  lcl_column2 = lcl_columns2->get_column( `DISK_USED_DATA` ).
*  lcl_column2->set_long_text( `Size (Actual + Projected)`).    "Actual Code

*Changes on 21-05-24
  lcl_column2 = lcl_columns2->get_column( `MEM_MON_GRW` ).
  lcl_column2->set_long_text( `Memory Size(GB)`).

*Changes on 21-05-24
  lcl_column2 = lcl_columns2->get_column( `ACT_MEM` ).
  lcl_column2->set_long_text( `Actual`).

  lcl_column2 = lcl_columns2->get_column( `PROJ_MEM` ).
  lcl_column2->set_long_text( `Projected`).

*  lcl_column2 = lcl_columns2->get_column( `DISK_USED_DATA` ).
*  lcl_column2->set_long_text( `Disk Size (Actual + Projected)`).

  lo_obj_col = lcl_salv2->get_columns( ).
  TRY.
      lo_hide_col ?= lo_obj_col->get_column( 'DISK_USED_DATA' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

      lo_hide_col ?= lo_obj_col->get_column( 'AVG_MEM_GRW' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

      lo_hide_col ?= lo_obj_col->get_column( 'AVG_DISK_GRW' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

      lo_hide_col ?= lo_obj_col->get_column( 'ACT_DISK' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

      lo_hide_col ?= lo_obj_col->get_column( 'PROJ_DISK' ).
      lo_hide_col->set_technical( if_salv_c_bool_sap=>true ).

    CATCH cx_salv_not_found.
  ENDTRY.

  DATA l_obj2 TYPE REF TO dbl_clk.
  CREATE OBJECT l_obj2.

  lr_event = lcl_salv2->get_event( ).
  SET HANDLER l_obj2->on_user_command FOR lr_event.

  CALL METHOD lcl_salv2->display.


  LOOP AT itab INTO DATA(ls_tab).
    DATA(lv_tabix) = sy-tabix.
    PERFORM values USING ls_tab lv_tabix.

    fs_column_texts-coltxt = ls_tab-poper.
    APPEND fs_column_texts TO it_column_texts.
    CLEAR fs_column_texts.
  ENDLOOP.

  l_mem_sum = g_mem_sum.

  CONCATENATE sy-sysid 'Size and Growth Estimates (GB) Average Monthly Growth =  ' l_mem_sum 'GB' INTO heading
                                                                                           SEPARATED BY space.

  CONCATENATE sy-sysid 'Volume (GB)' INTO lv_yaxis_tile SEPARATED BY space.

  CALL FUNCTION 'GFW_PRES_SHOW'
    EXPORTING
      container         = 'GRAPH_CONTAINER'
      presentation_type = co_gfw_prestype_lines
*     presentation_type = co_gfw_prestype_area
      header            = heading
      y_axis_title      = lv_yaxis_tile
    TABLES
      values            = it_values
      column_texts      = it_column_texts
    EXCEPTIONS
      error_occurred    = 1
      OTHERS            = 2.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

*  DATA: BEGIN OF fs_dsumm,
*          check TYPE char1,
*          arobj TYPE objct_tr01,
**          sarch TYPE i,
**          earch TYPE i,
*          sarch(8) TYPE c,
*          earch(8) TYPE c,
*        END OF fs_dsumm.
*  DATA:
*    it_dsumm LIKE TABLE OF fs_dsumm,
*    g_cols1  TYPE REF TO cl_salv_column_list.

  CLEAR it_dsumm.

  SET PF-STATUS 'DETAIL'.

  CLEAR:
    fs_output,
    fs_detail,
    fs_dsumm-sarch,
    fs_dsumm-earch,
    g_cols1.


  IF it_dsumm IS INITIAL.
    LOOP AT it_output INTO fs_output WHERE check = 'X'.
      SELECT archiving_object
             org_field
             zdate
             ztime
             zseq
             message
             no_of_entries
        FROM z056_archive
        INTO TABLE it_detail
       WHERE archiving_object = fs_output-arch_obj
*        ORDER BY zdate DESCENDING.
       ORDER BY zdate DESCENDING
                ztime DESCENDING.

*Changes on 04-06-24.

*   sort it_detail by archiving_object DESCENDING org_field DESCENDING zdate DESCENDING
*                     ztime DESCENDING zseq DESCENDING.
*   DELETE ADJACENT DUPLICATES FROM it_detail COMPARING archiving_object org_field zdate ztime zseq.

      READ TABLE it_detail ASSIGNING FIELD-SYMBOL(<fs_date1>) INDEX 1.
      IF sy-subrc EQ 0.
        lv_curr_date = <fs_date1>-zdate.
*          lv_curr_time = <fs_date1>-ztime.
      ENDIF.
      DELETE it_detail WHERE zdate NE lv_curr_date. "AND
*                               ztime NE lv_curr_time.
*
*        IF sy-subrc EQ 0.
      "Changes made on 03-06-24 (Archiving and Not Archiving Records not matching the data)
      SORT it_detail BY org_field DESCENDING zseq DESCENDING message DESCENDING number DESCENDING.
      DELETE ADJACENT DUPLICATES FROM it_detail COMPARING org_field zseq message number.
*"End of Changes 03-06-24
*        ENDIF.

*        sort it_detail by archiving_object DESCENDING org_field DESCENDING zdate DESCENDING ztime DESCENDING zseq DESCENDING .
*        DELETE ADJACENT DUPLICATES FROM it_detail COMPARING archiving_object org_field zdate ztime zseq.

*      IF sy-subrc EQ 0.
      READ TABLE it_detail INTO fs_detail INDEX 1.
      IF sy-subrc EQ 0.
*        DELETE it_detail WHERE archiving_object NE fs_detail-archiving_object
*                            OR zdate NE fs_detail-zdate
*                            OR ztime NE fs_detail-ztime.
      ENDIF.
      SELECT smsg
          UP TO 1 ROWS
        FROM zarch_para_job
        INTO @DATA(lv_msg)
       WHERE object EQ @fs_output-arch_obj
         AND smsg NE ' '.
      ENDSELECT.
      IF sy-subrc EQ 0.
        SORT it_detail BY archiving_object zseq.
        CLEAR fs_detail.
        LOOP AT it_detail INTO fs_detail.
          fs_dsumm-arobj = fs_detail-archiving_object.
          TRANSLATE fs_detail-message TO UPPER CASE.
          IF fs_detail-message EQ lv_msg.
            fs_dsumm-sarch = fs_detail-number + fs_dsumm-sarch.
          ELSE.
            fs_dsumm-earch = fs_detail-number + fs_dsumm-earch.
          ENDIF.
          AT END OF archiving_object.
*Changes on 03-06-24 (Adding Total Column in the detail button for archived and not archived records)
            fs_dsumm-total = fs_dsumm-sarch + fs_dsumm-earch.
            APPEND fs_dsumm TO it_dsumm.
            CLEAR fs_dsumm.
          ENDAT.
        ENDLOOP.
      ENDIF.
*      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lcl_sum_cont IS INITIAL.
    CREATE OBJECT lcl_sum_cont
      EXPORTING
        container_name = 'SUMDATA'.
  ENDIF.

  IF sy-ucomm NE 'BACK'.
    CALL METHOD cl_salv_table=>factory
      EXPORTING
        list_display = if_salv_c_bool_sap=>false
        r_container  = lcl_sum_cont
      IMPORTING
        r_salv_table = lcl_sum
      CHANGING
        t_table      = it_dsumm.


    CALL METHOD lcl_sum->get_columns
      RECEIVING
        value = DATA(lcl_sum_cols).

    lcl_sum_cols->set_optimize( 'X' ).

    DATA(lcl_sum_col) = lcl_sum_cols->get_column( `AROBJ` ).
    lcl_sum_col->set_long_text( `Archiving Object`).

    lcl_sum_col = lcl_sum_cols->get_column( `SARCH` ).
    lcl_sum_col->set_long_text( `Records can be Archived`).

    lcl_sum_col = lcl_sum_cols->get_column( `EARCH` ).
    lcl_sum_col->set_long_text( `Records cannot be Archived`).

    lcl_sum_col = lcl_sum_cols->get_column( `TOTAL` ).
    lcl_sum_col->set_long_text( `Total Number of Records`).

*  g_cols1 ?= lcl_sum_cols->get_column( 'CHECK' ).
*  g_cols1->set_cell_type(
*  if_salv_c_cell_type=>checkbox_hotspot ).
*  g_cols1->set_output_length( 10 ).
*  g_cols1->set_long_text( 'Select').
*
*  DATA(lcl_func1) = lcl_sum->get_functions( ).
*  lcl_func1->set_all( if_salv_c_bool_sap=>true ).

*  g_sel = lcl_sum->get_selections( ).
*  g_sel->get_selection_mode( if_salv_c_selection_mode=>multiple ).
*  g_sel->get_selected_rows( ).
  ENDIF.

*  data:
*  lo_selections type ref to cl_salv_selections,
*  lt_rows   type salv_t_row,
*  ls_row type i.
*
*
*  lo_selections = lcl_sum->get_selections( ).
*  lt_rows = lo_selections->get_selected_rows( ).
*
*  LOOP AT lt_rows INTO ls_row.
*    CLEAR fs_dsumm.
*    READ TABLE it_dsumm INTO fs_dsumm INDEX ls_row.
*    IF sy-subrc EQ 0.
*      CASE sy-ucomm.
*        WHEN 'DETAIL'.
*          CALL SCREEN 0100.
*
*          WHEN OTHERS.
*            LEAVE TO SCREEN 0.
*          ENDCASE.
*
*    ENDIF.
*
*  ENDLOOP.



*Changes on 06th Feb
*  DATA l_obj_det TYPE REF TO dbl_clk.
***  DATA l_obj_det TYPE REF TO cl_salv_table.
*  IF l_obj_det IS NOT BOUND.
*    CREATE OBJECT l_obj_det.
*  ENDIF.
*
*  DATA(lo_event) = lcl_sum->get_event( ).

*  SET HANDLER l_obj_det->sel_chk FOR lo_event.
*  SET HANDLER l_obj_det->clk_det FOR lo_event.
*  SET HANDLER l_obj_det->on_user_command FOR lo_event.

  CLEAR it_values.
  CLEAR it_column_texts.

*  REFRESH it_values.
*  REFRESH it_column_texts.

  fs_values-rowtxt = 'Can be Archived'.
  APPEND fs_values TO it_values.
  CLEAR fs_values.
  fs_values-rowtxt = 'Cannot be Archived'.
  APPEND fs_values TO it_values.
  CLEAR fs_values.

  LOOP AT it_dsumm INTO fs_dsumm.
    CASE sy-tabix.
      WHEN 1.
*    fs_values-rowtxt = 'Can be Archived'.
        fs_values-val1 = fs_dsumm-sarch.
        MODIFY it_values FROM fs_values TRANSPORTING val1 WHERE rowtxt = 'Can be Archived'.
*    APPEND fs_values TO it_values.
*    CLEAR fs_values.

*    fs_values-rowtxt = 'Cannot be Archived'.
        fs_values-val1 = fs_dsumm-earch.
        MODIFY it_values FROM fs_values TRANSPORTING val1 WHERE rowtxt = 'Cannot be Archived'.
*    APPEND fs_values TO it_values.
*    CLEAR fs_values.

      WHEN 2.
        fs_values-val2 = fs_dsumm-sarch.
        MODIFY it_values FROM fs_values TRANSPORTING val2 WHERE rowtxt = 'Can be Archived'.

        fs_values-val2 = fs_dsumm-earch.
        MODIFY it_values FROM fs_values TRANSPORTING val2 WHERE rowtxt = 'Cannot be Archived'.

      WHEN 3.
        fs_values-val3 = fs_dsumm-sarch.
        MODIFY it_values FROM fs_values TRANSPORTING val3 WHERE rowtxt = 'Can be Archived'.

        fs_values-val3 = fs_dsumm-earch.
        MODIFY it_values FROM fs_values TRANSPORTING val3 WHERE rowtxt = 'Cannot be Archived'.

      WHEN 4.
        fs_values-val4 = fs_dsumm-sarch.
        MODIFY it_values FROM fs_values TRANSPORTING val4 WHERE rowtxt = 'Can be Archived'.

        fs_values-val4 = fs_dsumm-earch.
        MODIFY it_values FROM fs_values TRANSPORTING val4 WHERE rowtxt = 'Cannot be Archived'.

*    fs_column_texts-coltxt = fs_dsumm-arobj.
*    APPEND fs_column_texts TO it_column_texts.
*    CLEAR fs_column_texts.
    ENDCASE.
    fs_column_texts-coltxt = fs_dsumm-arobj.
    APPEND fs_column_texts TO it_column_texts.
    CLEAR:
      fs_column_texts,
      fs_values,
      fs_dsumm.
  ENDLOOP.

  CALL FUNCTION 'GFW_PRES_SHOW'
    EXPORTING
      container         = 'SUMGRAPH'
      presentation_type = co_gfw_prestype_vbar
      y_axis_title      = lv_yaxis_tile1
    TABLES
      values            = it_values
      column_texts      = it_column_texts
    EXCEPTIONS
      error_occurred    = 1
      OTHERS            = 2.

  CALL METHOD lcl_sum->display.
  CLEAR it_values.
*  CLEAR it_dsumm.

*data:
*  lo_selections type ref to cl_salv_selections,
*  lt_rows   type salv_t_row,
*  ls_row type i.
*
*
*  lo_selections = lcl_sum->get_selections( ).
*  lt_rows = lo_selections->get_selected_rows( ).
*
*  LOOP AT lt_rows INTO ls_row.
*    CLEAR fs_dsumm.
*    READ TABLE it_dsumm INTO fs_dsumm INDEX ls_row.
*    IF sy-subrc EQ 0.
*      CASE sy-ucomm.
*        WHEN 'DETAIL'.
*          CALL SCREEN 0100.
*
*          WHEN OTHERS.
*            LEAVE TO SCREEN 0.
*          ENDCASE.
*
*    ENDIF.
*
*  ENDLOOP.


ENDMODULE.
