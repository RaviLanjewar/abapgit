
CLASS dbl_clk DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get_data,              " Method for Fetching the Data and Displaying
      get_dbsize,
      get_dbhist,
*changes on 22-05-24 (To Get Disk Data)
      get_dbdisk.
    METHODS:
*Get_Click is for Double Click Event
      get_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,
*Link Click is for Check Box
      link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column,

*      sel_chk FOR EVENT double_click OF cl_salv_events_table
*        IMPORTING row column,

*      clk_det FOR EVENT link_click OF cl_salv_events_table
*        IMPORTING row column,
*On User Command for Slt De-Slct and Execute Button
      on_user_command FOR EVENT added_function OF cl_salv_events.
ENDCLASS.

CLASS dbl_clk IMPLEMENTATION.
  METHOD get_data.

    DATA lt_dbsegments TYPE TABLE OF segments_f.
    DATA ls_dbsegments TYPE segments_f.
    DATA lv_lines      TYPE i.
    FIELD-SYMBOLS <fs_dbseg> TYPE any.

    IF p_disk IS NOT INITIAL.
      lv_disksize = p_disk * 1073741824.
    ENDIF.

    CASE sy-dbsys.
      WHEN 'HDB'.

        db6 = cl_db6_sys=>get_sys_ref( system_id   = system_id
                                       synchronize = abap_false ).

        TRY.
            CALL METHOD cl_dba_rdi=>get_instance
              EXPORTING
                sys_ref = db6
              RECEIVING
                rdi_ref = rdi.
          CATCH cx_dba_rdi.
        ENDTRY.

        rdi->query->reset( ).

        rdi->query->get_history( EXPORTING ddic_src = cl_hdb_rdi_meta=>co_ddic_column_tables_part_siz
                                 IMPORTING to_date  = lv_to_date
                                           to_time  = lv_to_time ).

        rdi->query->reset( ).
        rdi->query->set_history( from_time = lv_to_time
                                 from_date = lv_to_date ).

        rdi->query->set_filter_from_range_tab( ddic_field = 'SCHEMA_NAME'
                                               range_tab  = s_schema[] ).

        rdi->query->set_sort( order      = cl_dba_rdi_query=>co_descending
                              seq_no     = 1
                              ddic_field = lv_sort_field_col ).

        rdi->query->get_snapshot( EXPORTING ddic_src = cl_hdb_rdi_meta=>co_ddic_column_tables_part_siz
                                  IMPORTING data     = view_data-host_column_tables_part_size ).


*    DELETE view_data-host_column_tables_part_size WHERE memory_size_in_total < lv_disksize.
        DELETE view_data-host_column_tables_part_size WHERE estim_max_memory_size_in_total < lv_disksize.
      WHEN 'ORA'.
        CALL FUNCTION 'DB02_ORA_SELECT_SEGMENTS'
          EXPORTING
            seg_name     = '*'
            tb_space     = '*'
            seg_type     = 'TABLE'
          TABLES
            dba_segments = lt_dbsegments.

        LOOP AT lt_dbsegments INTO ls_dbsegments.
          APPEND INITIAL LINE TO view_data-host_column_tables_part_size.
          lv_lines = lines( view_data-host_column_tables_part_size ).
          READ TABLE view_data-host_column_tables_part_size ASSIGNING <fs_dbseg> INDEX lv_lines.
          IF sy-subrc EQ 0.
*            MOVE ls_dbsegments-sn TO <fs_dbseg>-
          ENDIF.
        ENDLOOP.

      WHEN OTHERS.
    ENDCASE.
    SELECT object,
           son
      FROM arch_def AS arch_def
      INNER JOIN @view_data-host_column_tables_part_size AS data
         ON data~table_name EQ arch_def~son
      INTO TABLE @DATA(it_arch_def).

*Changes on 21-06-2024 (Adding Alternate Archiving Object)
    IF it_arch_def IS NOT INITIAL.
      SELECT object,
             alt_arch_obj,
             obsolete
        FROM zarch_obsolete
        INTO TABLE @DATA(it_obsolete)
         FOR ALL ENTRIES IN @it_arch_def
        WHERE object = @it_arch_def-object.
    ENDIF.
*End of Changes

    SELECT tadir~obj_name,
           df14l~ps_posid,
           df14t~name
      FROM tdevc
     INNER JOIN tadir
        ON tadir~devclass EQ tdevc~devclass
     INNER JOIN @view_data-host_column_tables_part_size AS data
        ON tadir~obj_name EQ data~table_name
     INNER JOIN df14l
        ON df14l~fctr_id EQ tdevc~component
     INNER JOIN df14t
        ON df14t~langu EQ @sy-langu
       AND df14t~fctr_id EQ tdevc~component
      INTO TABLE @DATA(it_comp).

    LOOP AT view_data-host_column_tables_part_size INTO DATA(fs_data).
      CLEAR fs_output_col.
      MOVE-CORRESPONDING fs_data TO fs_output_col.
      fs_output_col-estim_max_memory_size_in_total = fs_output_col-estim_max_memory_size_in_total / 1073741824.

      READ TABLE it_comp INTO DATA(fs_comp) WITH KEY obj_name = fs_data-table_name.
      IF sy-subrc EQ 0.
        MOVE fs_comp-ps_posid TO fs_output_col-appli_tr01.
        MOVE fs_comp-name TO fs_output_col-appli_desc.
      ENDIF.

      LOOP AT it_arch_def INTO DATA(fs_arch_def) WHERE son = fs_data-table_name.
*Changes on 21-06-2024 (Reading Alternate Archiving Object Table)
        READ TABLE it_obsolete INTO DATA(fs_obsolete) WITH KEY object = fs_arch_def-object.
        IF sy-subrc = 0 AND fs_obsolete-obsolete = 'X'.
          fs_output_col-arch_obj = fs_obsolete-alt_arch_obj.
        ELSE.
          MOVE fs_arch_def-object TO fs_output_col-arch_obj.
        ENDIF.
*ENd of Changes
        APPEND fs_output_col TO it_output.
      ENDLOOP.
      IF sy-subrc NE 0.
        APPEND fs_output_col TO it_output.
      ENDIF.

    ENDLOOP.

*Capturing Program Name
    IF it_output IS NOT INITIAL.
      SELECT object
             reorga_prg
      FROM arch_obj
      INTO TABLE it_archprg
       FOR ALL ENTRIES IN it_output
        WHERE object = it_output-arch_obj.
    ENDIF.

*Capturing T-Code
    IF it_archprg IS NOT INITIAL.
      SELECT object
             tcode
        FROM arch_tcode
        INTO TABLE it_tcode
        FOR ALL ENTRIES IN it_archprg
        WHERE object = it_archprg-object.
    ENDIF.

*Capturing View Name
    IF it_tcode IS NOT INITIAL.
      SELECT tcode
             param
        FROM tstcp
        INTO TABLE it_tstcp
        FOR ALL ENTRIES IN it_tcode
        WHERE tcode = it_tcode-tcode.
    ENDIF.

    IF sy-subrc EQ 0.
      LOOP AT it_tstcp INTO fs_tstcp.
        SPLIT fs_tstcp-param AT ';' INTO DATA(lv_view) DATA(lv_dump).
        SPLIT lv_view AT '=' INTO DATA(lv_dump1) fs_viewname-viewname.
        fs_viewname-param = fs_tstcp-param.
        APPEND fs_viewname TO it_viewname.
        CLEAR fs_viewname.
      ENDLOOP.
    ENDIF.

*Capturing Table Name
    IF it_tstcp IS NOT INITIAL.
      SELECT viewname
             roottab
        FROM dd25vv
        INTO TABLE it_dd25vv
        FOR ALL ENTRIES IN it_viewname
        WHERE viewname = it_viewname-viewname.
    ENDIF.

*Capturing Value Table and Field
    IF it_output IS NOT INITIAL.
      SELECT *
    FROM zarch_para_job
        FOR ALL ENTRIES IN @it_output
        WHERE object = @it_output-arch_obj
    INTO TABLE @it_para.
    ENDIF.

*******************************Row type table*****************************
    IF sy-dbsys EQ 'HDB'.
      CLEAR view_data.

      rdi->query->reset( ).

      rdi->query->get_history( EXPORTING ddic_src = cl_hdb_rdi_meta=>co_ddic_global_rowstore_tbl_sz "cl_hdb_rdi_meta=>co_ddic_glob_persistence_stat
                               IMPORTING to_date  = lv_to_date
                                         to_time  = lv_to_time ).

      rdi->query->reset( ).
      rdi->query->set_history( from_time = lv_to_time
                               from_date = lv_to_date ).

      rdi->query->set_filter_from_range_tab( ddic_field = 'SCHEMA_NAME'
                                             range_tab  = s_schema[] ).

      rdi->query->set_sort( order      = cl_dba_rdi_query=>co_descending
                            seq_no     = 1
                            ddic_field = lv_sort_field_row ).

      rdi->query->get_snapshot( EXPORTING ddic_src = cl_hdb_rdi_meta=>co_ddic_global_rowstore_tbl_sz "cl_hdb_rdi_meta=>co_ddic_glob_persistence_stat
                                IMPORTING data     = view_data-hdb_global_rowstore_table_size ). "view_data-hdb_global_table_persist_stat ).

      DELETE view_data-hdb_global_rowstore_table_size WHERE allocated_part_size < lv_disksize.

      SELECT object,
             son
        FROM arch_def AS arch_def
        INNER JOIN @view_data-hdb_global_rowstore_table_size AS data
           ON data~table_name EQ arch_def~son
        INTO TABLE @DATA(it_arch_def_row).

      SELECT tadir~obj_name,
             df14l~ps_posid,
             df14t~name
        FROM tdevc
       INNER JOIN tadir
          ON tadir~devclass EQ tdevc~devclass
       INNER JOIN @view_data-hdb_global_rowstore_table_size AS data
          ON tadir~obj_name EQ data~table_name
       INNER JOIN df14l
          ON df14l~fctr_id EQ tdevc~component
       INNER JOIN df14t
          ON df14t~langu EQ @sy-langu
         AND df14t~fctr_id EQ tdevc~component
        INTO TABLE @DATA(it_comp_row).

      LOOP AT view_data-hdb_global_rowstore_table_size INTO DATA(fs_data_row).
        CLEAR fs_output_row.
        MOVE-CORRESPONDING fs_data_row TO fs_output_row.
        fs_output_row-allocated_part_size = fs_output_row-allocated_part_size / 1073741824.

        READ TABLE it_comp_row INTO DATA(fs_comp_row) WITH KEY obj_name = fs_data_row-table_name.
        IF sy-subrc EQ 0.
          MOVE fs_comp_row-ps_posid TO fs_output_row-appli_tr01.
          MOVE fs_comp_row-name TO fs_output_row-appli_desc.
        ENDIF.

        LOOP AT it_arch_def_row INTO DATA(fs_arch_def_row) WHERE son = fs_data_row-table_name.
          MOVE fs_arch_def_row-object TO fs_output_row-arch_obj.
          APPEND fs_output_row TO it_output.
        ENDLOOP.
        IF sy-subrc NE 0.
          APPEND fs_output_row TO it_output.
        ENDIF.
      ENDLOOP.
    ENDIF.

    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = lcl_salv
          CHANGING
            t_table      = it_output.
      CATCH cx_salv_msg.
    ENDTRY.

* Hiding Jobnumber and Jobname
    lo_cols_tab = lcl_salv->get_columns( ).
    TRY.
        lo_column ?= lo_cols_tab->get_column( 'JOB_NAME' ).
        lo_column->set_technical( if_salv_c_bool_sap=>true ).

        lo_column ?= lo_cols_tab->get_column( 'JOB_NUMBER' ).
        lo_column->set_technical( if_salv_c_bool_sap=>true ).

      CATCH cx_salv_not_found.
    ENDTRY.

* Application Tool Bar
    lcl_salv->set_screen_status(
      pfstatus      = 'Z056_STATUS1'
      report        = sy-repid
      set_functions = lcl_salv->c_functions_all ).

    CALL METHOD lcl_salv->get_columns
      RECEIVING
        value = DATA(lcl_columns).

    lcl_columns->set_optimize( 'X' ).
    DATA(lcl_column) = lcl_columns->get_column( `USED_SIZE` ).
    lcl_column->set_long_text( `Used Size in GB`).
    DATA(lcl_column_desc) = lcl_columns->get_column( `APPLI_DESC` ).
    lcl_column_desc->set_long_text( `Appli. Area Description`).

*Check Box
    g_cols ?= lcl_columns->get_column( 'CHECK' ).
    g_cols->set_cell_type(
      if_salv_c_cell_type=>checkbox_hotspot ).
    g_cols->set_output_length( 10 ).
    g_cols->set_long_text( 'Select').

    DATA(lcl_func) = lcl_salv->get_functions( ).
    lcl_func->set_all( if_salv_c_bool_sap=>true ).

*Event Handling (Dbl Clk)
    DATA l_obj TYPE REF TO dbl_clk.
    CREATE OBJECT l_obj.

    lr_event = lcl_salv->get_event( ).

    SET HANDLER l_obj->get_click FOR lr_event.
    SET HANDLER l_obj->link_click FOR lr_event.
    SET HANDLER l_obj->on_user_command FOR lr_event.

    CALL METHOD lcl_salv->display.
  ENDMETHOD.

*Changes on 22-05-24 (Creating Method for Disk Data)
  METHOD get_dbsize.
    DATA ok_code  TYPE sy-ucomm.
    DATA gv_disk  TYPE i.
    DATA lv_date  TYPE d.
    DATA lv_month TYPE numc2.
    DATA lv_year  TYPE numc4.
*Changes on 17-05-24 (Adding field for average calculation)
    DATA gv_mem   TYPE i.
    DATA gv_avg_disk   TYPE i.
    DATA gv_avg_mem  TYPE i.

    CREATE OBJECT adbc
      EXPORTING
        dbcname = dbcon.

    TRY.
        CALL METHOD adbc->get_db_size_history
          IMPORTING
            itab = db_size_tab.
      CATCH cx_dba_adbc.
    ENDTRY.

    LOOP AT db_size_tab ASSIGNING FIELD-SYMBOL(<fs_db_size_tab>).
      <fs_db_size_tab>-year = <fs_db_size_tab>-date(4).
      <fs_db_size_tab>-month = <fs_db_size_tab>-date+4(2).
    ENDLOOP.

    LOOP AT db_size_tab ASSIGNING <fs_db_size_tab>.
      AT NEW month.
        count = 0.
        sum_disk_data = 0.
*Changes on 17-05-24
        mem_used = 0.
      ENDAT.

      ADD 1 TO count.
      ADD <fs_db_size_tab>-disk_used_data TO sum_disk_data.
*Changes on 17-05-24 (capturing mem_used data into a variable)
      ADD <fs_db_size_tab>-memory_used TO mem_used.
      wa2-poper = |{ <fs_db_size_tab>-year }| && '/' && |{ <fs_db_size_tab>-month }|.

      AT END OF month.
        wa2-disk_used_data = sum_disk_data / count.
*Changes on 17-05-24 (Populating mem_used into workarea)
        wa2-mem_mon_grw = mem_used / count.
        APPEND wa2 TO itab.
        dattab-month = wa2-poper.
        dattab-disk_used_data = wa2-disk_used_data.
*Changes on 17-05-24 (Populating mem_used into workarea)
        dattab-mem_mon_grw    = wa2-mem_mon_grw.
        APPEND dattab TO it_dattab.
        CLEAR dattab.
        CLEAR wa2.
      ENDAT.
    ENDLOOP.

    SORT itab BY poper DESCENDING.    " Commenting (Uncomment for further use)
    DELETE itab FROM 8.               " Commenting to get all the data
*LOOP AT itab INTO wa2.

    SORT itab BY poper.

*Changes on 20-05-24 (Calculating Avg part)
    LOOP AT itab ASSIGNING FIELD-SYMBOL(<fs_avg_cal>).
      DATA(l_tabix) = sy-tabix +  1.
      READ TABLE itab INTO wa2 INDEX l_tabix.
*  gv_avg_disk = wa2-disk_used_data - gv_avg_disk.
      <fs_avg_cal>-avg_disk_grw = wa2-disk_used_data - <fs_avg_cal>-disk_used_data.
      g_disk_sum = g_disk_sum + <fs_avg_cal>-avg_disk_grw.
      <fs_avg_cal>-avg_mem_grw = wa2-mem_mon_grw - <fs_avg_cal>-mem_mon_grw.
      g_mem_sum = g_mem_sum + <fs_avg_cal>-avg_mem_grw.
*  <fs_avg_mem_grw>-avg_mem_grw = gv_avg_mem.
    ENDLOOP.

*Changes on 20-05-24 (Calculating Avg part)
    g_disk_sum = g_disk_sum / 6.
    g_mem_sum = g_mem_sum / 6.

*Changes on 20-05-24 (Sorting by Desc)
    SORT itab BY poper DESCENDING.

    READ TABLE itab INTO DATA(ls_wa2) INDEX 1.

*Changes on 03-06-24 (Adding Current in latest month)
    DATA(lv_poper) = ls_wa2-poper.
    CONCATENATE ls_wa2-poper '(Current)' INTO ls_wa2-poper SEPARATED BY space.
    MODIFY itab FROM ls_wa2 INDEX 1 TRANSPORTING poper.
*End of Chnages.

    IF sy-subrc EQ 0.
      SPLIT ls_wa2-poper AT '/' INTO lv_year lv_month.
    ENDIF.

    CLEAR wa2.
    DO 6 TIMES.
      lv_month = lv_month + 01.

      IF lv_month > 12.
        lv_month = 01.
        lv_year = lv_year + 1.
      ENDIF.

      CONCATENATE lv_year '/' lv_month INTO wa2-poper.
      APPEND wa2 TO itab.
    ENDDO.

*    LOOP AT itab INTO wa2.
*      gv_disk = wa2-disk_used_data + gv_disk. "Commenting Original Code
*    ENDLOOP.

*Changes on 20-05-24 (Calculating Future 6 Months)
    SORT itab BY poper.

    LOOP AT itab ASSIGNING FIELD-SYMBOL(<fs_growth>).
      DATA(l_sno) = sy-tabix - 1.
      IF <fs_growth>-mem_mon_grw IS INITIAL
      OR <fs_growth>-disk_used_data IS INITIAL.
        READ TABLE itab INTO wa2 INDEX l_sno.
        <fs_growth>-mem_mon_grw = wa2-mem_mon_grw + g_mem_sum.
        <fs_growth>-disk_used_data = wa2-disk_used_data + g_disk_sum.
      ENDIF.
      IF <fs_growth>-poper LT lv_poper.
        <fs_growth>-act_mem = <fs_growth>-mem_mon_grw.
        <fs_growth>-act_disk = <fs_growth>-disk_used_data.
      ELSEIF <fs_growth>-poper GT lv_poper AND <fs_growth>-poper NA '(Current)'.
        <fs_growth>-proj_mem = <fs_growth>-mem_mon_grw.
        <fs_growth>-proj_disk = <fs_growth>-disk_used_data.
      ENDIF.
    ENDLOOP.

    SORT itab BY poper.
  ENDMETHOD.

*Method for Getting DB Size History Data
  METHOD get_dbhist.

    CALL METHOD dbl_clk=>get_dbsize( ).

    LOOP AT itab ASSIGNING FIELD-SYMBOL(<fs_itab>).
      <fs_itab>-moderate = ( <fs_itab>-mem_mon_grw / 100 * 75 ).
      <fs_itab>-aggressive = ( <fs_itab>-mem_mon_grw / 100 * 60 ).
    ENDLOOP.

    CALL SCREEN 200.

  ENDMETHOD.

*Changes on 22-02-24 (To get Disk Data and Graph part)
  METHOD get_dbdisk.
    CALL METHOD dbl_clk=>get_dbsize( ).

    LOOP AT itab ASSIGNING FIELD-SYMBOL(<fs_itab2>).
      <fs_itab2>-moderate = ( <fs_itab2>-disk_used_data / 100 * 75 ).
      <fs_itab2>-aggressive = ( <fs_itab2>-disk_used_data / 100 * 60 ).
    ENDLOOP.
    CALL SCREEN 400.
  ENDMETHOD.

*Method for Double Click
  METHOD get_click.
    IF it_output IS NOT INITIAL.
      CLEAR fs_output.
      READ TABLE it_output INTO fs_output INDEX row.
    ENDIF.

    IF column EQ 'ARCH_OBJ'.
      CLEAR fs_archprg.
      READ TABLE it_archprg INTO fs_archprg WITH KEY object = fs_output-arch_obj.
      IF it_output[ row ]-arch_obj IS NOT INITIAL.
        SUBMIT (fs_archprg-reorga_prg) AND RETURN.
      ELSE.
        MESSAGE i000(zarch).
      ENDIF.
    ENDIF.
  ENDMETHOD.

*Method for Checkbox
  METHOD link_click.
    FIELD-SYMBOLS:
      <fs_final> TYPE ty_output.
    DATA: it_output_chk TYPE TABLE OF ty_output.
    IF column = 'CHECK'.
      ASSIGN fs_output TO <fs_final>.
      READ TABLE it_output ASSIGNING <fs_final> INDEX row.
      IF sy-subrc EQ 0.
        IF  <fs_final>-check = abap_true.
          <fs_final>-check = abap_false.
        ELSE.
          <fs_final>-check = abap_true.
        ENDIF.
        APPEND <fs_final> TO it_output_chk.
      ENDIF.
      UNASSIGN <fs_final>.
      lv_stable-row = 'X'.
      lcl_salv->refresh(
        EXPORTING
          s_stable     = lv_stable
          refresh_mode = if_salv_c_refresh=>soft ).
    ENDIF.
  ENDMETHOD.

*Method for Select and Deselect
  METHOD on_user_command.
    DATA lt_filters TYPE lvc_t_filt.
    DATA lt_scope   TYPE lvc_t_fidx.
    DATA ls_scope   LIKE LINE OF lt_scope.

    CASE sy-ucomm.
*Logic For Select All
      WHEN 'SLCT'.
        CLEAR lt_filters.
        CLEAR lt_scope.
        CLEAR ls_scope.

        lt_filters = cl_salv_controller_metadata=>get_lvc_filter( lcl_salv->get_filters( ) ).

        IF lt_filters IS NOT INITIAL.
          CALL FUNCTION 'LVC_FILTER_APPLY'
            EXPORTING
              it_filter              = lt_filters
            IMPORTING
              et_filter_index_inside = lt_scope
            TABLES
              it_data                = it_output.

          LOOP AT lt_scope INTO ls_scope.
            fs_output-check = abap_true.
            MODIFY it_output FROM fs_output INDEX ls_scope TRANSPORTING check.
            CLEAR fs_output.
          ENDLOOP.
        ELSE.
          LOOP AT it_output INTO fs_output.
            fs_output-check = abap_true.
            MODIFY it_output FROM fs_output.
            CLEAR fs_output.
          ENDLOOP.
        ENDIF.
        lcl_salv->refresh( ).

*Logic For De-Select All
      WHEN 'DSLCT'.
        LOOP AT it_output INTO fs_output.
          fs_output-check = abap_false.
          MODIFY it_output FROM fs_output.
          CLEAR fs_output.
        ENDLOOP.
        lcl_salv->refresh( ).

*Execute
      WHEN 'EXECUTE'.
        PERFORM job_schedule TABLES it_output.
      WHEN 'DETAILS'.
        CALL SCREEN 0300.
      WHEN 'DETAIL'.
        CALL SCREEN 0100.
      WHEN 'GRAPH'.
        CALL FUNCTION 'GRAPH_MATRIX_2D'
          EXPORTING
            inform      = '6'
            winpos      = '5'
            winszx      = '70'
            winszy      = '65'
          TABLES
*           data        = dattab[]
            data        = it_dattab
            opts        = opttab[]
            tcol        = sptitl[]
          EXCEPTIONS
            col_invalid = 1
            opt_invalid = 2
            OTHERS      = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        CALL FUNCTION 'GRAPH_DIALOG'
          EXPORTING
            close = 'X'.

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
*End of Class Implementation
