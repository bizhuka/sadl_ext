class ZCL_SADL_FILTER definition
  public
  final
  create public .

public section.

  types:
    tt_condition_provider TYPE STANDARD TABLE OF REF TO if_sadl_condition_provider
                                         WITH UNIQUE SORTED KEY provider COMPONENTS table_line .

  class-methods GET_FILTER
    importing
      !IT_SADL_CONDITIONS type IF_SADL_QUERY_ENGINE_TYPES=>TT_COMPLEX_CONDITION
      !IT_CONDITION_PROVIDER type TT_CONDITION_PROVIDER
    exporting
      !EV_WHERE type STRING
      !ET_RANGE type IF_SADL_COND_PROVIDER_GRPD_RNG=>TT_GROUPED_RANGE .
  class-methods GET_STREAM_FILTER
    importing
      !IO_REQUEST type ref to /IWBEP/IF_MGW_REQ_ENTITY
    returning
      value(RV_FILTER) type STRING .
  class-methods GET_STREAM_RUNTIME
    importing
      !IV_SERVICE_NAME type CSEQUENCE
      !IV_ENTITY_SET_NAME type CSEQUENCE
    returning
      value(RO_RUNTIME) type ref to ZIF_SADL_STREAM_RUNTIME
    raising
      CX_SADL_STATIC .
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


  METHOD get_filter.
    CLEAR: et_range,
           ev_where.

    DATA(l_cursor) = lines( it_sadl_conditions ).
    _map_conditions_sql( EXPORTING it_sadl_conditions      = it_sadl_conditions
                         IMPORTING ev_condition_expression = ev_where
                         CHANGING  cv_cursor               = l_cursor ).

**********************************************************************
    LOOP AT it_condition_provider INTO DATA(lo_provider).
      CHECK lo_provider IS INSTANCE OF cl_sadl_cond_grouped_ranges.

      _merge_ranges( EXPORTING it_ranges = lcl_provider=>get_range( CAST #( lo_provider ) )
                     CHANGING  ct_ranges = et_range ).
    ENDLOOP.
  ENDMETHOD.


  METHOD get_stream_filter.
    CHECK io_request IS INSTANCE OF /iwbep/cl_mgw_request.
    rv_filter = lcl_request=>get_filter( CAST #( io_request ) ).
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
