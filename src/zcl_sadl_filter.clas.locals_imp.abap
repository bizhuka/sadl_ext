*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_provider DEFINITION INHERITING FROM cl_sadl_cond_grouped_ranges ABSTRACT.
  PUBLIC SECTION.
    CLASS-METHODS:
      get_range IMPORTING io_sadl_cond    TYPE REF TO cl_sadl_cond_grouped_ranges
                RETURNING VALUE(rt_range) TYPE if_sadl_cond_provider_grpd_rng=>tt_grouped_range.
ENDCLASS.

CLASS lcl_provider IMPLEMENTATION.
  METHOD get_range.
    rt_range = io_sadl_cond->mt_ranges[].
  ENDMETHOD.
ENDCLASS.

**********************************************************************
**********************************************************************

CLASS lcl_request DEFINITION INHERITING FROM /iwbep/cl_mgw_request FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      get_filter IMPORTING io_request TYPE REF TO /iwbep/cl_mgw_request
                 EXPORTING ev_filter  TYPE string
                           et_filter  TYPE /iwbep/t_mgw_select_option.
ENDCLASS.

CLASS lcl_request IMPLEMENTATION.
  METHOD get_filter.
    ev_filter = io_request->mo_filter->get_filter_string( ).
    et_filter = io_request->mo_filter->get_filter_select_options( ).
  ENDMETHOD.
ENDCLASS.
