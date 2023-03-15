CLASS zcl_sadl_filter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_condition_provider TYPE STANDARD TABLE OF REF TO if_sadl_condition_provider
                                           WITH UNIQUE SORTED KEY provider COMPONENTS table_line .

    CLASS-METHODS get_sadl_where
      IMPORTING it_sadl_conditions TYPE if_sadl_query_engine_types=>tt_complex_condition
      RETURNING VALUE(rv_where)    TYPE string .

    CLASS-METHODS get_provider_range
      IMPORTING it_condition_provider TYPE tt_condition_provider
      RETURNING VALUE(rt_range)       TYPE if_sadl_cond_provider_grpd_rng=>tt_grouped_range.

    CLASS-METHODS get_key_from_range
      IMPORTING it_range      TYPE if_sadl_cond_provider_grpd_rng=>tt_grouped_range
      RETURNING VALUE(rr_key) TYPE REF TO data.

    CLASS-METHODS get_stream_filter
      IMPORTING
                io_request TYPE REF TO /iwbep/if_mgw_req_entity
      EXPORTING ev_filter  TYPE string
                et_filter  TYPE /iwbep/t_mgw_select_option.
    CLASS-METHODS get_stream_runtime
      IMPORTING
        !iv_service_name    TYPE csequence
        !iv_entity_set_name TYPE csequence
      RETURNING
        VALUE(ro_runtime)   TYPE REF TO zif_sadl_stream_runtime
      RAISING
        cx_sadl_static .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS _map_conditions_sql
      IMPORTING
        !it_sadl_conditions      TYPE if_sadl_query_engine_types=>tt_complex_condition
      EXPORTING
        !ev_condition_expression TYPE string
      CHANGING
        !cv_cursor               TYPE i .
    CLASS-METHODS _map_operator
      IMPORTING
        !iv_operator     TYPE string
      EXPORTING
        !ev_sql_operator TYPE string .
    CLASS-METHODS _merge_ranges
      IMPORTING
        !it_ranges TYPE if_sadl_cond_provider_grpd_rng=>tt_grouped_range
      CHANGING
        !ct_ranges TYPE if_sadl_cond_provider_grpd_rng=>tt_grouped_range .
ENDCLASS.



CLASS ZCL_SADL_FILTER IMPLEMENTATION.


  METHOD get_key_from_range.
    DATA(lt_comp) = VALUE cl_abap_structdescr=>component_table( ).
    LOOP AT it_range ASSIGNING FIELD-SYMBOL(<ls_range>).
      INSERT VALUE #( name = <ls_range>-column_name
                      type = cl_abap_elemdescr=>get_string( ) ) INTO TABLE lt_comp.
    ENDLOOP.
    CHECK lt_comp[] IS NOT INITIAL.

    DATA(lr_handle) = cl_abap_structdescr=>create( lt_comp ).
    CREATE DATA rr_key TYPE HANDLE lr_handle.
    ASSIGN rr_key->* TO FIELD-SYMBOL(<ls_key>).

    LOOP AT it_range ASSIGNING <ls_range>.
      CHECK lines( <ls_range>-t_selopt[] ) = 1.

      ASSIGN COMPONENT <ls_range>-column_name OF STRUCTURE <ls_key> TO FIELD-SYMBOL(<lv_field>).
      <lv_field> = <ls_range>-t_selopt[ 1 ]-low.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_provider_range.
    LOOP AT it_condition_provider INTO DATA(lo_provider).
      DATA(lt_range) = COND #( WHEN lo_provider IS INSTANCE OF cl_sadl_cond_grouped_ranges
                               THEN lcl_provider=>get_range( CAST #( lo_provider ) )

                               WHEN lo_provider IS INSTANCE OF cl_sadl_condition_merger
                               THEN CAST cl_sadl_condition_merger( lo_provider )->zz_mt_range

                               WHEN lo_provider IS INSTANCE OF cl_sadl_cond_prov_navigation
                               THEN CAST cl_sadl_cond_prov_navigation( lo_provider )->zz_mt_range ).
      CHECK lt_range IS NOT INITIAL.

      _merge_ranges( EXPORTING it_ranges = lt_range
                     CHANGING  ct_ranges = rt_range ).
    ENDLOOP.
  ENDMETHOD.


  METHOD  get_sadl_where.
    DATA(l_cursor) = lines( it_sadl_conditions ).
    _map_conditions_sql( EXPORTING it_sadl_conditions      = it_sadl_conditions
                         IMPORTING ev_condition_expression = rv_where
                         CHANGING  cv_cursor               = l_cursor ).
  ENDMETHOD.


  METHOD get_stream_filter.
    CHECK io_request IS INSTANCE OF /iwbep/cl_mgw_request.
    lcl_request=>get_filter( EXPORTING io_request = CAST #( io_request )
                             IMPORTING ev_filter  = ev_filter
                                       et_filter  = et_filter ).
  ENDMETHOD.


  METHOD get_stream_runtime.
    CHECK iv_service_name CP 'Z*_CDS'.

    DATA(lv_len) = strlen( iv_service_name ) - 4.
    DATA(lo_mp)  = NEW cl_sadl_mp_entity_exposure(
        it_paths = VALUE #( ( |CDS~{ iv_service_name(lv_len) }| ) )
        iv_expose_associations = abap_true
        iv_sadl_id = |CDS_{ iv_service_name(lv_len) }| ). " `cl_sadl_metadata_provider_rds`

    DATA(lo_mdp) = cl_sadl_metadata_provider=>get( lo_mp ).
    DATA(ls_load) = lo_mdp->get_entity_load( iv_entity_set_name ).
    CHECK ls_load IS NOT INITIAL.

    ASSIGN ls_load->sadl_entity-cds_entity_annotations[ annoname = zcl_sadl_annotation_ext=>id ] TO FIELD-SYMBOL(<ls_anno>).
    CHECK sy-subrc = 0.

    DATA(lo_sadl_exit) = zcl_sadl_annotation_ext=>create( <ls_anno>-value ).
    CHECK lo_sadl_exit IS NOT INITIAL
      AND lo_sadl_exit IS INSTANCE OF zif_sadl_stream_runtime.

    ro_runtime = CAST #( lo_sadl_exit ).
  ENDMETHOD.


  METHOD _map_conditions_sql.
    DATA: ls_condition_1  LIKE LINE OF it_sadl_conditions.
    DATA: ls_condition_2  LIKE LINE OF it_sadl_conditions.
    DATA: ls_condition_3  LIKE LINE OF it_sadl_conditions.
    DATA: lv_expression1  TYPE string.
    DATA: lv_expression2  TYPE string.

    CLEAR ev_condition_expression.
    IF cv_cursor = 0. RETURN. ENDIF.

    READ TABLE it_sadl_conditions INDEX cv_cursor INTO ls_condition_1.
    cv_cursor = cv_cursor - 1.

    ls_condition_1-attribute = cl_abap_dyn_prg=>escape_quotes_str( ls_condition_1-attribute ).
    ls_condition_1-value = cl_abap_dyn_prg=>escape_quotes_str( ls_condition_1-value ).
    ls_condition_2-value = cl_abap_dyn_prg=>escape_quotes_str( ls_condition_2-value ).

    CASE ls_condition_1-type.
      WHEN  if_sadl_query_engine_types=>co_condition_types-equals OR
            if_sadl_query_engine_types=>co_condition_types-contains_pattern OR
            if_sadl_query_engine_types=>co_condition_types-not_contains_pattern OR
            if_sadl_query_engine_types=>co_condition_types-less_than OR
            if_sadl_query_engine_types=>co_condition_types-less_than_or_equal OR
            if_sadl_query_engine_types=>co_condition_types-greater_than OR
            if_sadl_query_engine_types=>co_condition_types-greater_than_or_equal OR
            if_sadl_query_engine_types=>co_condition_types-not_equal.

        READ TABLE it_sadl_conditions INDEX cv_cursor INTO ls_condition_2.
        cv_cursor = cv_cursor - 1.

        ls_condition_2-value = cl_abap_dyn_prg=>escape_quotes_str( ls_condition_2-value ).

        _map_operator( EXPORTING iv_operator     = ls_condition_1-type
                       IMPORTING ev_sql_operator = DATA(lv_operator) ).
        ev_condition_expression = |{ ev_condition_expression }{ ls_condition_1-attribute } { lv_operator } `{ ls_condition_2-value }`|.

      WHEN if_sadl_query_engine_types=>co_condition_types-is_null.
        _map_operator( EXPORTING iv_operator     = if_sadl_query_engine_types=>co_condition_types-equals
                       IMPORTING ev_sql_operator = lv_operator ).
        ev_condition_expression = |{ ev_condition_expression }{ ls_condition_1-attribute } { lv_operator } `{ ls_condition_2-value }`|.

      WHEN if_sadl_query_engine_types=>co_condition_types-not.
        _map_conditions_sql( EXPORTING it_sadl_conditions      = it_sadl_conditions
                             IMPORTING ev_condition_expression = lv_expression1
                             CHANGING  cv_cursor               = cv_cursor ).
        ev_condition_expression = |{ ev_condition_expression }not ( { lv_expression1 } )|.

      WHEN if_sadl_query_engine_types=>co_condition_types-and.
        _map_conditions_sql( EXPORTING it_sadl_conditions      = it_sadl_conditions
                            IMPORTING ev_condition_expression = lv_expression1
                            CHANGING  cv_cursor               = cv_cursor ).
        _map_conditions_sql( EXPORTING it_sadl_conditions      = it_sadl_conditions
                             IMPORTING ev_condition_expression = lv_expression2
                             CHANGING  cv_cursor               = cv_cursor ).
        ev_condition_expression = |{ ev_condition_expression }( { lv_expression1 } and { lv_expression2 } )|.

      WHEN if_sadl_query_engine_types=>co_condition_types-or.
        _map_conditions_sql( EXPORTING it_sadl_conditions      = it_sadl_conditions
                            IMPORTING ev_condition_expression = lv_expression1
                            CHANGING  cv_cursor               = cv_cursor ).
        _map_conditions_sql( EXPORTING it_sadl_conditions      = it_sadl_conditions
                             IMPORTING ev_condition_expression = lv_expression2
                             CHANGING  cv_cursor               = cv_cursor ).
        ev_condition_expression = |{ ev_condition_expression }( { lv_expression1 } or { lv_expression2 } )|.

      WHEN if_sadl_query_engine_types=>co_condition_types-between.
        READ TABLE it_sadl_conditions INDEX cv_cursor INTO ls_condition_2.
        ls_condition_2-value = cl_abap_dyn_prg=>escape_quotes_str( ls_condition_2-value ).
        cv_cursor = cv_cursor - 1.
        READ TABLE it_sadl_conditions INDEX cv_cursor INTO ls_condition_3.
        ls_condition_3-value = cl_abap_dyn_prg=>escape_quotes_str( ls_condition_3-value ).
        cv_cursor = cv_cursor - 1.
        ev_condition_expression = |{ ev_condition_expression }{ ls_condition_1-attribute } between `{ ls_condition_3-value }` and `{ ls_condition_2-value }`|.

      WHEN if_sadl_query_engine_types=>co_condition_types-not_between.
        READ TABLE it_sadl_conditions INDEX cv_cursor INTO ls_condition_2.
        ls_condition_2-value = cl_abap_dyn_prg=>escape_quotes_str( ls_condition_2-value ).
        cv_cursor = cv_cursor - 1.
        READ TABLE it_sadl_conditions INDEX cv_cursor INTO ls_condition_3.
        ls_condition_3-value = cl_abap_dyn_prg=>escape_quotes_str( ls_condition_3-value ).
        cv_cursor = cv_cursor - 1.
        ev_condition_expression = |{ ev_condition_expression }{ ls_condition_1-attribute } not between `{ ls_condition_3-value }` and `{ ls_condition_2-value }`|.

      WHEN OTHERS.
        ASSERT 1 = 2.
    ENDCASE.
  ENDMETHOD.


  METHOD _map_operator.
    CASE iv_operator.
      WHEN if_sadl_query_engine_types=>co_condition_types-equals OR 'EQ'.
        ev_sql_operator = '='.
      WHEN if_sadl_query_engine_types=>co_condition_types-not_equal OR 'NE'.
        ev_sql_operator = '<>'.
      WHEN if_sadl_query_engine_types=>co_condition_types-less_than OR 'LT'.
        ev_sql_operator = '<'.
      WHEN if_sadl_query_engine_types=>co_condition_types-less_than_or_equal OR 'LE'.
        ev_sql_operator = '<='.
      WHEN if_sadl_query_engine_types=>co_condition_types-greater_than OR 'GT'.
        ev_sql_operator = '>'.
      WHEN if_sadl_query_engine_types=>co_condition_types-greater_than_or_equal OR 'GE'.
        ev_sql_operator = '>='.
      WHEN if_sadl_query_engine_types=>co_condition_types-contains_pattern OR 'CP'.
*        cv_rhs_value = map_pattern( cv_rhs_value ).
        ev_sql_operator = 'cp'.
      WHEN if_sadl_query_engine_types=>co_condition_types-not_contains_pattern OR 'NP'.
*        cv_rhs_value = map_pattern( cv_rhs_value ).
        ev_sql_operator = 'np'.
      WHEN OTHERS.
        ASSERT 0 = 1.
    ENDCASE.
  ENDMETHOD.


  METHOD _merge_ranges.
    LOOP AT it_ranges ASSIGNING FIELD-SYMBOL(<s_range>).
      READ TABLE ct_ranges WITH KEY field_path = <s_range>-field_path column_name = <s_range>-column_name rule_group = <s_range>-rule_group ASSIGNING FIELD-SYMBOL(<s_erange>).
      IF sy-subrc <> 0.
        INSERT VALUE #( field_path = <s_range>-field_path column_name = <s_range>-column_name rule_group = <s_range>-rule_group ) INTO TABLE ct_ranges ASSIGNING <s_erange>.
      ENDIF.
      INSERT LINES OF <s_range>-t_selopt INTO TABLE <s_erange>-t_selopt.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
