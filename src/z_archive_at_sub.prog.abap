*&---------------------------------------------------------------------*
*& Include          Z_ARCHIVE_AT_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form values
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_TAB
*&---------------------------------------------------------------------*
FORM values  USING    p_ls_tab TYPE ty_disk
                      p_lv_tabix.
  CONSTANTS lc_data_size TYPE string VALUE 'Size (Actual + Projected)'.
  CONSTANTS lc_advm      TYPE string VALUE 'Aggresive Archiving (40%)'.
  CONSTANTS lc_mdvm      TYPE string VALUE 'Moderate Archiving (25%)'.
  CLEAR fs_values.

  CASE p_lv_tabix.
    WHEN 1.
*      fs_values-rowtxt = lc_data_size.
*      fs_values-val1 = p_ls_tab-disk_used_data.
*      APPEND fs_values TO it_values.

*      fs_values-rowtxt = lc_mdvm.
*      fs_values-val1 = p_ls_tab-moderate.
*      APPEND fs_values TO it_values.

      fs_values-rowtxt = lc_advm.
      fs_values-val1 = p_ls_tab-aggressive.
      APPEND fs_values TO it_values.

      fs_values-rowtxt = lc_mdvm.
      fs_values-val1 = p_ls_tab-moderate.
      APPEND fs_values TO it_values.

      fs_values-rowtxt = lc_data_size.
*      fs_values-val1 = p_ls_tab-disk_used_data. "Original Code
*Changes 21-05-24
      fs_values-val1 = p_ls_tab-mem_mon_grw.
      APPEND fs_values TO it_values.

    WHEN 2.
*      fs_values-val2 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val2 WHERE rowtxt = lc_data_size.

      fs_values-val2 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val2 WHERE rowtxt = lc_advm.

      fs_values-val2 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val2 WHERE rowtxt = lc_mdvm.

*      fs_values-val2 = p_ls_tab-disk_used_data. "original code
      fs_values-val2 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val2 WHERE rowtxt = lc_data_size.
    WHEN 3.
*      fs_values-val3 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val3 WHERE rowtxt = lc_data_size.

      fs_values-val3 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val3 WHERE rowtxt = lc_advm.

      fs_values-val3 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val3 WHERE rowtxt = lc_mdvm.

*      fs_values-val3 = p_ls_tab-disk_used_data. "Original Code
      fs_values-val3 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val3 WHERE rowtxt = lc_data_size.

    WHEN 4.
*      fs_values-val4 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val4 WHERE rowtxt = lc_data_size.

      fs_values-val4 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val4 WHERE rowtxt = lc_advm.

      fs_values-val4 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val4 WHERE rowtxt = lc_mdvm.

*      fs_values-val4 = p_ls_tab-disk_used_data. "Original Code
      fs_values-val4 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val4 WHERE rowtxt = lc_data_size.

    WHEN 5.
*      fs_values-val5 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val5 WHERE rowtxt = lc_data_size.

      fs_values-val5 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val5 WHERE rowtxt = lc_advm.

      fs_values-val5 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val5 WHERE rowtxt = lc_mdvm.

*      fs_values-val5 = p_ls_tab-disk_used_data. "Orginal Code
      fs_values-val5 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val5 WHERE rowtxt = lc_data_size.
    WHEN 6.
*      fs_values-val6 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val6 WHERE rowtxt = lc_data_size.

      fs_values-val6 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val6 WHERE rowtxt = lc_advm.

      fs_values-val6 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val6 WHERE rowtxt = lc_mdvm.

*      fs_values-val6 = p_ls_tab-disk_used_data. "Original Code
      fs_values-val6 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val6 WHERE rowtxt = lc_data_size.
    WHEN 7.
*      fs_values-val7 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val7 WHERE rowtxt = lc_data_size.

      fs_values-val7 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val7 WHERE rowtxt = lc_advm.

      fs_values-val7 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val7 WHERE rowtxt = lc_mdvm.

*      fs_values-val7 = p_ls_tab-disk_used_data. "Orginial COde
      fs_values-val7 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val7 WHERE rowtxt = lc_data_size.
    WHEN 8.
*      fs_values-val8 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val8 WHERE rowtxt = lc_data_size.

      fs_values-val8 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val8 WHERE rowtxt = lc_advm.

      fs_values-val8 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val8 WHERE rowtxt = lc_mdvm.

*      fs_values-val8 = p_ls_tab-disk_used_data. "Orginial COde
      fs_values-val8 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val8 WHERE rowtxt = lc_data_size.
    WHEN 9.
*      fs_values-val9 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val9 WHERE rowtxt = lc_data_size.

      fs_values-val9 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val9 WHERE rowtxt = lc_advm.

      fs_values-val9 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val9 WHERE rowtxt = lc_mdvm.

*      fs_values-val9 = p_ls_tab-disk_used_data. "Orginial COde
      fs_values-val9 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val9 WHERE rowtxt = lc_data_size.
    WHEN 10.
*      fs_values-val10 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val10 WHERE rowtxt = lc_data_size.

      fs_values-val10 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val10 WHERE rowtxt = lc_advm.

      fs_values-val10 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val10 WHERE rowtxt = lc_mdvm.

*      fs_values-val10 = p_ls_tab-disk_used_data. "Orginial COde
      fs_values-val10 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val10 WHERE rowtxt = lc_data_size.
    WHEN 11.
*      fs_values-val11 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val11 WHERE rowtxt = lc_data_size.

      fs_values-val11 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val11 WHERE rowtxt = lc_advm.

      fs_values-val11 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val11 WHERE rowtxt = lc_mdvm.

*      fs_values-val11 = p_ls_tab-disk_used_data. "Orginial COde
      fs_values-val11 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val11 WHERE rowtxt = lc_data_size.
    WHEN 12.
*      fs_values-val12 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val12 WHERE rowtxt = lc_data_size.

      fs_values-val12 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val12 WHERE rowtxt = lc_advm.

      fs_values-val12 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val12 WHERE rowtxt = lc_mdvm.

*      fs_values-val12 = p_ls_tab-disk_used_data. "Orginial COde
      fs_values-val12 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val12 WHERE rowtxt = lc_data_size.

*Changes 21-05-24
    WHEN 13.
*      fs_values-val12 = p_ls_tab-disk_used_data.
*      MODIFY it_values FROM fs_values TRANSPORTING val12 WHERE rowtxt = lc_data_size.

      fs_values-val13 = p_ls_tab-aggressive.
      MODIFY it_values FROM fs_values TRANSPORTING val13 WHERE rowtxt = lc_advm.

      fs_values-val13 = p_ls_tab-moderate.
      MODIFY it_values FROM fs_values TRANSPORTING val13 WHERE rowtxt = lc_mdvm.

*      fs_values-val12 = p_ls_tab-disk_used_data. "Orginial COde
      fs_values-val13 = p_ls_tab-mem_mon_grw.
      MODIFY it_values FROM fs_values TRANSPORTING val13 WHERE rowtxt = lc_data_size.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form job_schedule
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_OUTPUT
*&---------------------------------------------------------------------*
FORM job_schedule  TABLES   p_it_output STRUCTURE fs_output.
  DATA lv_flag TYPE c.
  DATA:
    fs_ref    TYPE REF TO data,
    it_ref    TYPE REF TO data,
    dyn_tab   TYPE REF TO data,
    lv_fields TYPE string.
*Value Assignment
  FIELD-SYMBOLS <fs> TYPE any.
  FIELD-SYMBOLS <fwa>   TYPE any.
  FIELD-SYMBOLS <fitab> TYPE ANY TABLE.

  LOOP AT p_it_output INTO fs_output WHERE check = abap_true.

* Fetch the Selection Screen Parameters from Z Table
    SELECT *
      FROM zarch_para_job
     WHERE object EQ @fs_output-arch_obj
      INTO TABLE @it_para.

    DATA(lv_date) = sy-datum.
    DATA(lv_time) = sy-uzeit.
    CONCATENATE fs_output-arch_obj '_' lv_date '_' lv_time INTO l_jobname.
    CLEAR fs_archprg.
    READ TABLE it_archprg INTO fs_archprg WITH KEY object = fs_output-arch_obj.
    IF sy-subrc EQ 0.
      CLEAR fs_tcode.
      READ TABLE it_tcode   INTO fs_tcode   WITH KEY object = fs_archprg-object.
      IF sy-subrc EQ 0.
        CLEAR fs_tstcp.
        READ TABLE it_tstcp   INTO fs_tstcp   WITH KEY tcode = fs_tcode-tcode.
        IF sy-subrc EQ 0.
          CLEAR fs_viewname.
          READ TABLE it_viewname INTO fs_viewname WITH KEY param = fs_tstcp-param.
          IF sy-subrc EQ 0.
            CLEAR fs_dd25vv.
            READ TABLE it_dd25vv  INTO fs_dd25vv  WITH KEY viewname = fs_viewname-viewname.
            IF sy-subrc EQ 0.
*Creating Dynamic ITAB for the table which we got from ROOTTAB Field from DD25VV Table
              CALL METHOD cl_abap_typedescr=>describe_by_name
                EXPORTING
                  p_name         = fs_dd25vv-roottab
                RECEIVING
                  p_descr_ref    = o_typedescr
                EXCEPTIONS
                  type_not_found = 1
                  OTHERS         = 2.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.

              IF o_typedescr IS BOUND.
                o_structdescr ?= o_typedescr.
              ENDIF.

              IF o_structdescr IS BOUND.
                CALL METHOD cl_abap_tabledescr=>create
                  EXPORTING
                    p_line_type = o_structdescr
                  RECEIVING
                    p_result    = o_tabledescr.
              ENDIF.

*Creating Object
              CREATE DATA fs_ref TYPE HANDLE o_structdescr.
              CREATE DATA it_ref TYPE HANDLE o_tabledescr.

*Mapping the values
              ASSIGN fs_ref->* TO <fwa>.
              ASSIGN it_ref->* TO <fitab>.

*Retriving the Data
*Dynamic Select Query to get the fields of Dynamic Table.
              SELECT *
              FROM (fs_dd25vv-roottab)
              INTO TABLE <fitab>.

*Looping that Dynamic ITAB and Checking whether the field has * in it
              IF sy-subrc EQ 0.
                LOOP AT <fitab> INTO <fwa>.
                  ASSIGN COMPONENT 2 OF STRUCTURE <fwa> TO <fs>.
                  IF sy-subrc EQ 0.
                    IF <fs> EQ '*'.
                      CLEAR lv_fields.
                      CLEAR dyn_tab.
                      PERFORM create_dynamic_table TABLES it_para
                                                 CHANGING dyn_tab
                                                          lv_fields.
                      IF sy-subrc EQ 0.
                        ASSIGN dyn_tab->* TO <it_tab>.
                        PERFORM schedule_job TABLES <it_tab>
                                             USING lv_fields.
                      ENDIF.
                      IF lv_jobname IS NOT INITIAL.
                        MESSAGE s007(zarch).
                      ENDIF.
                    ELSE.
                      CLEAR fs_para.
                      READ TABLE it_para INTO fs_para WITH KEY object = fs_output-arch_obj.
                      IF sy-subrc = 0.
                        fs_rsparam-selname = fs_para-selpar.
                        fs_rsparam-kind = fs_para-kind.
                        fs_rsparam-option = 'EQ'.
                        fs_rsparam-sign = 'I'.
                        fs_rsparam-low = <fs>.
                        APPEND fs_rsparam TO it_rsparam.
                        CLEAR fs_rsparam.
                        lv_jobname = fs_output-arch_obj && `_` && <fs> && '_' && |{ sy-datum }| && '_' &&  |{ sy-uzeit }|.
                        PERFORM job_open USING  lv_jobname
                                       CHANGING lv_jobcount.
                        IF lv_jobcount IS NOT INITIAL.
                          fs_output-job_name = lv_jobname.
                          fs_output-job_number = lv_jobcount.
                          MODIFY it_output FROM fs_output TRANSPORTING job_name job_number.
                        ENDIF.
                        DATA(l_prgname) = fs_archprg-reorga_prg.
                        IF l_prgname IS NOT INITIAL.
                          SUBMIT (l_prgname) WITH SELECTION-TABLE it_rsparam
                          VIA JOB lv_jobname NUMBER lv_jobcount AND RETURN.


                          SUBMIT z056_arch2_spool WITH p_jname EQ lv_jobname
                                                  WITH p_jnumb EQ lv_jobcount
                                                  WITH p_arobj EQ fs_output-arch_obj
                                                  WITH p_orgele EQ fs_para-selpar
                                                  WITH p_orgfld EQ <fs>
                                                  VIA JOB lv_jobname
                                                  NUMBER lv_jobcount AND RETURN.
                          PERFORM job_close USING lv_jobcount
                                                  lv_jobname.
                          CLEAR it_rsparam.
                          CLEAR l_prgname.
                        ENDIF.
                      ENDIF.
                      CLEAR <fs>.
                    ENDIF.
                  ENDIF.
                ENDLOOP.
                IF lv_jobname IS NOT INITIAL.
                  MESSAGE s007(zarch).
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          lv_flag = 'X'.
*          CLEAR lv_fields.
*          CLEAR dyn_tab.
*          PERFORM create_dynamic_table TABLES it_para
*                                     CHANGING dyn_tab
*                                              lv_fields.
*          IF sy-subrc EQ 0.
*            ASSIGN dyn_tab->* TO <it_tab>.
*            PERFORM schedule_job TABLES <it_tab>
*                                 USING lv_fields.
*          ENDIF.
*          IF lv_jobname IS NOT INITIAL.
*            MESSAGE s007(zarch).
*          ENDIF.
        ENDIF.
      ELSE.
        lv_flag = 'X'.
      ENDIF.
*    ELSE.
*      lv_flag = 'X'.
    ENDIF.
*      lv_flag = 'X'.
    IF lv_flag IS NOT INITIAL.
      CLEAR lv_fields.
      CLEAR dyn_tab.
      PERFORM create_dynamic_table TABLES it_para
                                 CHANGING dyn_tab
                                          lv_fields.
      IF sy-subrc EQ 0.
        ASSIGN dyn_tab->* TO <it_tab>.
        PERFORM schedule_job TABLES <it_tab>
                             USING lv_fields.
      ELSE.
        PERFORM schedule_job_no_params.
      ENDIF.
      IF lv_jobname IS NOT INITIAL.
        MESSAGE s007(zarch).
      ENDIF.
    ENDIF.
    CLEAR lv_flag.

*              l_prgname = fs_archprg-reorga_prg.

*Remove submit.
*              SUBMIT (l_prgname) AND RETURN
*                                 VIA JOB l_jobname
*                                 NUMBER l_jobcount.

*            SUBMIT z056_arch2_spool WITH p_jname EQ l_jobname
*                                    WITH p_jnumb EQ l_jobcount
*                                    WITH p_arobj EQ fs_output-arch_obj
*                                    VIA JOB lv_jobname
*                                    NUMBER lv_jobcount AND RETURN.

*    IF sy-subrc EQ 0.
*                CALL FUNCTION 'JOB_CLOSE'
*                  EXPORTING
*                    jobcount             = l_jobcount
*                    jobname              = l_jobname
*                    strtimmed            = 'X'
*                  EXCEPTIONS
*                    cant_start_immediate = 1
*                    invalid_startdate    = 2
*                    jobname_missing      = 3
*                    job_close_failed     = 4
*                    job_nosteps          = 5
*                    job_notex            = 6
*                    lock_failed          = 7
*                    invalid_target       = 8
*                    invalid_time_zone    = 9
*                    OTHERS               = 10.
*                Remove
*      IF sy-subrc EQ 0.
*      ELSE.
*        MESSAGE e002(zarch) WITH sy-subrc.
*      ENDIF.
*    ELSE.
*      MESSAGE e003(zarch) WITH sy-subrc.
*    ENDIF.
*      ELSE.
*        MESSAGE i005(zarch) WITH fs_output-table_name.
*      ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form job_open
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_JOBNAME
*&      --> LV_JOBCOUNT
*&---------------------------------------------------------------------*
FORM job_open  USING    p_lv_jobname
               CHANGING p_lv_jobcount.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname  = p_lv_jobname
    IMPORTING
      jobcount = p_lv_jobcount.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form job_close
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_JOBCOUNT
*&      --> LV_JOBNAME
*&---------------------------------------------------------------------*
FORM job_close  USING    p_lv_jobcount
                         p_lv_jobname.
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount  = p_lv_jobcount
      jobname   = p_lv_jobname
      strtimmed = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_dynamic_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_PARA
*&---------------------------------------------------------------------*
FORM create_dynamic_table  TABLES   p_it_para STRUCTURE fs_para
                           CHANGING p_dyn_tab TYPE data
                                    p_lv_fields.

  CLEAR it_fcat.
  CLEAR fs_fcat.
  CLEAR fs_para.

  READ TABLE p_it_para INTO fs_para WITH KEY tab_rel = 'X'.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  IF p_it_para[] IS INITIAL.
    sy-subrc = 4.
    EXIT.
  ENDIF.

  LOOP AT p_it_para INTO DATA(ls_para) WHERE tab_rel = 'X'.
    fs_fcat-fieldname = ls_para-selpar.
    fs_fcat-ref_field = ls_para-fieldname.
    fs_fcat-ref_table = ls_para-tabname.
    APPEND fs_fcat TO it_fcat.
    CLEAR fs_fcat.
    IF ls_para-tab_rel IS NOT INITIAL.
      CONCATENATE p_lv_fields ls_para-fieldname INTO p_lv_fields SEPARATED BY space.
    ENDIF.
  ENDLOOP.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = it_fcat
    IMPORTING
      ep_table                  = p_dyn_tab
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc NE 0.
    WRITE:/ fs_output-arch_obj.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form schedule_job
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <IT_TAB>
*&---------------------------------------------------------------------*
FORM schedule_job  TABLES   p_it_tab TYPE STANDARD TABLE
                   USING    p_lv_fields.

  DATA ls_para LIKE fs_para.
  DATA ls_where TYPE string.
  DATA lt_t001b TYPE TABLE OF t001b.
  DATA ls_t001b TYPE t001b.
  FIELD-SYMBOLS <fs> TYPE any.
  FIELD-SYMBOLS <Fs_bukrs> TYPE bukrs.

  CLEAR fs_para.
  READ TABLE it_para INTO ls_para WITH KEY object = fs_output-arch_obj
                                           tab_rel = 'X'.
  IF sy-subrc EQ 0.
    IF ls_para-default_val IS NOT INITIAL AND ls_para-kind = 'P'.
      CONCATENATE ls_para-selpar ` EQ '`  ls_para-default_val `'` INTO ls_where.
    ENDIF.
    IF ls_where IS NOT INITIAL.
      SELECT (p_lv_fields)
        FROM (ls_para-tabname)
        INTO TABLE <it_tab>
       WHERE (ls_where).
    ELSE.
      SELECT (p_lv_fields)
        FROM (ls_para-tabname)
        INTO TABLE <it_tab>.
    ENDIF.

    IF ls_para-object EQ 'FI_DOCUMNT'.
      SELECT *
        FROM t001b
        INTO TABLE lt_t001b.
      IF sy-subrc EQ 0.
        LOOP AT <it_tab> ASSIGNING <fs>.
          ASSIGN COMPONENT 'SO_BUKRS' OF STRUCTURE <fs> TO <fs_bukrs>.
          IF <fs_bukrs> IS ASSIGNED.
            READ TABLE lt_t001b INTO ls_t001b WITH KEY bukrs = <fs_bukrs>.
            IF ls_t001b-frye1 < sy-datum(4).
              DELETE TABLE <it_tab> FROM <fs>.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDIF.

  LOOP AT <it_tab> ASSIGNING FIELD-SYMBOL(<fs_tab>).
    LOOP AT it_fcat INTO fs_fcat.
      ASSIGN COMPONENT fs_fcat-fieldname OF STRUCTURE <fs_tab> TO FIELD-SYMBOL(<fs_any>).
      IF <fs_any> IS ASSIGNED.
        fs_rsparam-selname = ls_para-selpar.
        fs_rsparam-kind = ls_para-kind.
        fs_rsparam-option = 'EQ'.
        fs_rsparam-sign = 'I'.
        fs_rsparam-low = <fs_any>.
        APPEND fs_rsparam TO it_rsparam.
        CLEAR fs_rsparam.
        LOOP AT it_para INTO fs_para WHERE tab_rel = ' '.
          fs_rsparam-selname = fs_para-selpar.
          fs_rsparam-kind = fs_para-kind.
          fs_rsparam-option = 'EQ'.
          fs_rsparam-sign = 'I'.
          fs_rsparam-low = fs_para-default_val.
          APPEND fs_rsparam TO it_rsparam.
          CLEAR fs_rsparam.
        ENDLOOP.
        lv_jobname = fs_output-arch_obj && `_` && <fs_any> && '_' && |{ sy-datum }| && '_' && |{ sy-uzeit }|.
        PERFORM job_open USING  lv_jobname
                       CHANGING lv_jobcount.
        IF lv_jobcount IS NOT INITIAL.
          fs_output-job_name = lv_jobname.
          fs_output-job_number = lv_jobcount.
          MODIFY it_output FROM fs_output TRANSPORTING job_name job_number.
        ENDIF.
        DATA(l_prgname) = fs_archprg-reorga_prg.
        IF l_prgname IS NOT INITIAL.
          SUBMIT (l_prgname) WITH SELECTION-TABLE it_rsparam
          VIA JOB lv_jobname NUMBER lv_jobcount AND RETURN.


          SUBMIT z056_arch2_spool WITH p_jname EQ lv_jobname
                                  WITH p_jnumb EQ lv_jobcount
                                  WITH p_arobj EQ fs_output-arch_obj
                                  WITH p_orgele EQ fs_fcat-fieldname
                                  WITH p_orgfld EQ <fs_any>
                                  VIA JOB lv_jobname
                                  NUMBER lv_jobcount AND RETURN.

          PERFORM job_close USING lv_jobcount
                                  lv_jobname.
          CLEAR <fs_any>.
          CLEAR it_rsparam.
          CLEAR l_prgname.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form schedule_job_no_params
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM schedule_job_no_params .
  lv_jobname = fs_output-arch_obj && `_` && '_' && |{ sy-datum }| && '_' && |{ sy-uzeit }|.

  DATA lt_para_job TYPE TABLE OF zarch_para_job.
  DATA ls_para_job TYPE zarch_para_job.

  CLEAR it_rsparam.
  CLEAR fs_rsparam.

  SELECT *
    FROM zarch_para_job
    INTO TABLE lt_para_job
   WHERE object = fs_output-arch_obj.
*     AND period_chk = ' '.
  IF sy-subrc EQ 0.
    LOOP AT lt_para_job INTO ls_para_job.
      IF ls_para_job-period_chk <> ' '.
        RETURN.
      ENDIF.
      fs_rsparam-selname = ls_para_job-selpar.
      fs_rsparam-kind = ls_para_job-kind.
      fs_rsparam-option = 'EQ'.
      fs_rsparam-sign = 'I'.
      fs_rsparam-low = ls_para_job-default_val.
      APPEND fs_rsparam TO it_rsparam.
      CLEAR fs_rsparam.
    ENDLOOP.
  ENDIF.

  IF it_rsparam IS INITIAL.
    EXIT.
  ENDIF.

  PERFORM job_open USING  lv_jobname
                 CHANGING lv_jobcount.
  DATA(l_prgname) = fs_archprg-reorga_prg.
  IF l_prgname IS NOT INITIAL.

    SUBMIT (l_prgname) WITH SELECTION-TABLE it_rsparam
    VIA JOB lv_jobname NUMBER lv_jobcount AND RETURN.


    SUBMIT z056_arch2_spool WITH p_jname EQ lv_jobname
                            WITH p_jnumb EQ lv_jobcount
                            WITH p_arobj EQ fs_output-arch_obj
                            WITH p_orgele EQ fs_output-arch_obj
                            WITH p_orgfld EQ ' '
                            VIA JOB lv_jobname
                            NUMBER lv_jobcount AND RETURN.

    PERFORM job_close USING lv_jobcount
                            lv_jobname.
  ENDIF.
ENDFORM.
