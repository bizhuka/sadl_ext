INTERFACE zif_sadl_read_runtime PUBLIC.

  INTERFACES zif_sadl_exit.

  METHODS execute
    IMPORTING
      !iv_node_name       TYPE string
      !is_filter          TYPE any
      !iv_where           TYPE string
      !is_requested       TYPE if_sadl_query_engine_types=>ty_requested
    CHANGING
      !ct_data_rows       TYPE STANDARD TABLE
      !cv_number_all_hits TYPE i
    RAISING
      "cx_sadl_contract_violation
      cx_sadl_static.

ENDINTERFACE.
