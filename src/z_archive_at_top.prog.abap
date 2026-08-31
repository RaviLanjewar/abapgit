TYPES:
* structure holds final data
  BEGIN OF ty_output,
    check      TYPE char1,
    table_name TYPE tabname,
    used_size  TYPE p DECIMALS 2,
    arch_obj   TYPE objct_tr01,
    appli_tr01 TYPE ufps_posid,
    appli_desc TYPE ddtext,
    job_name   TYPE btcjob,
    job_number TYPE btcjobcnt,
  END OF ty_output,

  BEGIN OF ty_output_col,
    check                          TYPE char1,
    table_name                     TYPE tabname,
    estim_max_memory_size_in_total TYPE p DECIMALS 2,
    arch_obj                       TYPE objct_tr01,
    appli_tr01                     TYPE ufps_posid,
    appli_desc                     TYPE ddtext,
    job_name                       TYPE btcjob,
    job_number                     TYPE btcjobcnt,
  END OF ty_output_col,

  BEGIN OF ty_output_row,
    char                TYPE char1,
    table_name          TYPE tabname,
    allocated_part_size TYPE p DECIMALS 2,
    arch_obj            TYPE objct_tr01,
    appli_tr01          TYPE ufps_posid,
    appli_desc          TYPE ddtext,
    job_name            TYPE btcjob,
    job_number          TYPE btcjobcnt,

  END OF ty_output_row.

*Begin of Changes by Shubham
*Structure to Get Archive Object Program Name
TYPES:
  BEGIN OF ty_archprg,
    object     TYPE objct_tr01,
    reorga_prg TYPE rrgid_tr01,
  END OF ty_archprg.


*Structure to Get Spool Number
TYPES:
  BEGIN OF ty_tbtcp,
    jobname   TYPE btcjob,
    jobcount  TYPE btcjobcnt,
    stepcount TYPE btcstepcnt,
    listident TYPE btclistid,
  END OF ty_tbtcp.


*Structure to Get Data From Z_Archive Table
TYPES:
  BEGIN OF ty_detail,
    archiving_object TYPE z056_archive-archiving_object,
    org_field        TYPE z056_archive-org_field,
    zdate            TYPE z056_archive-zdate,
    ztime            TYPE z056_archive-ztime,
    zseq             TYPE z056_archive-zseq,
    message          TYPE z056_archive-message,
    number           TYPE z056_archive-no_of_entries,
  END OF ty_detail.

*Structure to Get Viewname
TYPES:
  BEGIN OF ty_viewname,
    param    TYPE tcdparam,
    viewname TYPE char30,
  END OF ty_viewname.

TYPES:
  BEGIN OF ty_tcode,
    object TYPE objct_tr01,
    tcode  TYPE tcode,
  END OF ty_tcode.

TYPES:
  BEGIN OF ty_tstcp,
    tcode TYPE tcode,
    param TYPE tcdparam,
  END OF ty_tstcp.

TYPES:
  BEGIN OF ty_dd25vv,
    viewname TYPE viewname,
    roottab  TYPE roottab,
  END OF ty_dd25vv.

*Bnd of Changes by Shubham


*Workareas and Internal Tables
*Begin of Changes by Shubham
*ITAB and Work-Area For From Z_Archive Table
DATA:
  fs_tbtcp   TYPE ty_tbtcp,
  temp       TYPE TABLE OF rspo_ds,
  fs_cust    TYPE z056_archive,
  it_cust    TYPE TABLE OF z056_archive,
  it_detail  TYPE TABLE OF ty_detail,
  it_details TYPE TABLE OF ty_detail.
*Bnd of Changes by Shubham

DATA:
  fs_output_col TYPE ty_output_col,
  it_output_col TYPE TABLE OF ty_output_col,
  fs_output_row TYPE ty_output_row,
  it_output_row TYPE TABLE OF ty_output_row,
  fs_output     TYPE ty_output,
  it_output     TYPE TABLE OF ty_output,
  it_archprg    TYPE TABLE OF ty_archprg,
  fs_archprg    TYPE ty_archprg,
  it_viewname   TYPE TABLE OF ty_viewname,
  fs_viewname   TYPE ty_viewname,
  it_tcode      TYPE TABLE OF ty_tcode,
  fs_tcode      TYPE ty_tcode,
  it_tstcp      TYPE TABLE OF ty_tstcp,
  fs_tstcp      TYPE ty_tstcp,
  it_dd25vv     TYPE TABLE OF ty_dd25vv,
  fs_dd25vv     TYPE ty_dd25vv.

DATA:
  rdi               TYPE REF TO cl_dba_rdi,
  db6               TYPE REF TO cl_db6_sys,
  lv_to_date        TYPE sydatum,
  lv_to_time        TYPE syuzeit,
  lv_schema         TYPE char128,
  lv_sort_field_col TYPE string VALUE 'ESTIM_MAX_MEMORY_SIZE_IN_TOTAL', "'DISK_SIZE'.
  lv_sort_field_row TYPE string VALUE 'ALLOCATED_PART_SIZE', "'DISK_SIZE'.
  system_id         TYPE sysysid,
  view_data         TYPE hdb_column_tables_part_sizealv,
  lv_disksize       TYPE p LENGTH 16.


* Begin of Changes by Shubham
*Object Declaration
DATA:
  lr_event            TYPE REF TO cl_salv_events_table,
  g_table             TYPE REF TO cl_salv_table,
  g_cols              TYPE REF TO cl_salv_column_list,
  g_cx_salv_not_found TYPE REF TO cx_salv_not_found,
  lcl_salv            TYPE REF TO cl_salv_table,
  lcl_msg             TYPE REF TO cl_salv_table,
  lcl_sum             TYPE REF TO cl_salv_table,
  lo_cols_tab         TYPE REF TO cl_salv_columns_table,
  lo_column           TYPE REF TO cl_salv_column_table,
  lo_get_col          TYPE REF TO cl_salv_columns_table,
  lo_text             TYPE REF TO cl_salv_column_table,
  adbc                TYPE REF TO cl_hdb_adbc.

*Variables Declaration
DATA:
  g_message    TYPE string,
  l_jobname    TYPE tbtcjob-jobname,
  l_jobcount   TYPE tbtcjob-jobcount,
  gs_detail    TYPE ty_detail,
  lv_stable    TYPE lvc_s_stbl,
  lv_stable2   TYPE lvc_s_stbl,
  refresh_mode TYPE salv_de_constant.

DATA:
  it_para TYPE TABLE OF zarch_para_job,
  fs_para TYPE zarch_para_job.

DATA:
  o_typedescr   TYPE REF TO cl_abap_typedescr,
  o_structdescr TYPE REF TO cl_abap_structdescr,
  o_tabledescr  TYPE REF TO cl_abap_tabledescr.

DATA:
  lv_table TYPE tabname.

DATA:
  it_rsparam TYPE TABLE OF rsparams,
  fs_rsparam TYPE rsparams.

DATA:
  lv_jobcount TYPE tbtcjob-jobcount,
  lv_jobname  TYPE tbtcjob-jobname.

FIELD-SYMBOLS <it_tab> TYPE STANDARD TABLE.
DATA:
  it_fcat   TYPE lvc_t_fcat,
  fs_fcat   TYPE lvc_s_fcat,
  lv_fields TYPE string.
*End of Changes by Shubham

TYPES:
  BEGIN OF ty_detail2,
    archiving_object TYPE z056_archive-archiving_object,
    org_field        TYPE z056_archive-org_field,
    zdate            TYPE z056_archive-zdate,
    ztime            TYPE z056_archive-ztime,
    zseq             TYPE z056_archive-zseq,
    message          TYPE z056_archive-message,
    docno            TYPE char32,
    number           TYPE p,
  END OF ty_detail2.

DATA:
  it_detail2 TYPE TABLE OF ty_detail2,
  fs_detail2 TYPE ty_detail2.

DATA:
  db_size_tab    TYPE hdb_db_size_tab,
  dbcon          TYPE dbcon_name,
*  wa2            TYPE hdb_db_size,
  count          TYPE i,
  sum_mem        TYPE dec20_2,
  sum_disk_data  TYPE dec20_2,
  sum_disk_log   TYPE dec20_2,
  sum_disk_trace TYPE dec20_2,
*Changes on 17-05-24(Fetching Memory Used Field from HDB_DB_SIZE struc)
  mem_used       TYPE dec20_2.
*  itab           TYPE hdb_db_size_tab.

TYPES: BEGIN OF dattab,
         month          TYPE char6,
         disk_used_data TYPE hdb_db_size-disk_used_data,
*Changes on 17-05-24(Adding Memory Used Field from HDB_DB_SIZE struc)
         mem_mon_grw    TYPE hdb_db_size-memory_used,
       END OF dattab,

       BEGIN OF opttab,
         c(20),
       END OF opttab,

       BEGIN OF sptitl,
         c(20),
       END OF sptitl.

DATA:
  it_dattab TYPE TABLE OF dattab,
  dattab    TYPE dattab,
  opttab    TYPE TABLE OF opttab,
  sptitl    TYPE TABLE OF sptitl.

TYPES:
  BEGIN OF ty_disk,
    poper(20)      TYPE c,
    aggressive     TYPE p DECIMALS 2,
    moderate       TYPE p DECIMALS 2,
    disk_used_data TYPE i,
*Changes on 17-05-24y(Adding memory used column)
    mem_mon_grw    TYPE i,
*Changes on 20-05-24y(Adding calculation column for mem and disk)
    avg_mem_grw    TYPE i,
    avg_disk_grw   TYPE i,
*Changes on 03-06-24 (Adding actual + projeted column)
    act_mem        TYPE string,
    act_disk       TYPE string,
    proj_mem       TYPE string,
    proj_disk      TYPE string,
  END OF ty_disk.

DATA:
  itab TYPE TABLE OF ty_disk,
  wa2  TYPE ty_disk.

DATA lcl_cust     TYPE REF TO cl_gui_custom_container.
*Changes on 22-05-24
DATA lcl_cust2    TYPE REF TO cl_gui_custom_container.
DATA lcl_sum_cont TYPE REF TO cl_gui_custom_container.
DATA lcl_cont1    TYPE REF TO cl_gui_container.
DATA lcl_split    TYPE REF TO cl_gui_splitter_container.
DATA lcl_cont2    TYPE REF TO cl_gui_container.


CONSTANTS co_gfw_prestype_lines TYPE i VALUE 17.
CONSTANTS co_gfw_prestype_vbar  TYPE i VALUE 1.


DATA it_values       TYPE TABLE OF gprval.
DATA fs_values       TYPE gprval.
DATA it_column_texts TYPE TABLE OF gprtxt.
DATA fs_column_texts TYPE gprtxt.
DATA lv_yaxis_tile   TYPE gfwlabel.
DATA lv_yaxis_tile1  TYPE gfwlabel VALUE 'Records'.
DATA heading(70)     TYPE c.

*Changes 22-05-24
DATA lv_yaxis_tile2  TYPE gfwlabel.
DATA lv_yaxis_tile12 TYPE gfwlabel VALUE 'Records'.
DATA heading2(70)    TYPE c.

DATA: BEGIN OF fs_dsumm,
        check     TYPE char1,
*       arobj    TYPE objct_tr01,
        arobj(20) TYPE c,
*       sarch TYPE i,
*       earch TYPE i,
        sarch(8)  TYPE c,
        earch(8)  TYPE c,
        total(8)  TYPE c,
      END OF fs_dsumm.
DATA:
  it_dsumm LIKE TABLE OF fs_dsumm,
  g_cols1  TYPE REF TO cl_salv_column_list,
  g_sel    TYPE REF TO cl_salv_selections.

*Chnages on 21-05-24
DATA:
  g_disk_sum  TYPE i,
  g_mem_sum   TYPE i,
  lo_obj_col  TYPE REF TO cl_salv_columns_table,
  lo_hide_col TYPE REF TO cl_salv_column_table.

*Changes on 04-06-24
DATA:
  lv_curr_date TYPE dats,
  lv_curr_time TYPE zcreate_time.
