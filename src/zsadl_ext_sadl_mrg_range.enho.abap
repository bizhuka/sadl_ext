CLASS lcl_zsadl_ext_sadl_mrg_range DEFINITION DEFERRED.

CLASS cl_sadl_condition_merger DEFINITION LOCAL FRIENDS lcl_zsadl_ext_sadl_mrg_range.

CLASS lcl_zsadl_ext_sadl_mrg_range DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA obj TYPE REF TO lcl_zsadl_ext_sadl_mrg_range. "#EC NEEDED
    DATA core_object TYPE REF TO cl_sadl_condition_merger . "#EC NEEDED
 INTERFACES  IPR_ZSADL_EXT_SADL_MRG_RANGE.
    METHODS:
      constructor IMPORTING core_object TYPE REF TO cl_sadl_condition_merger OPTIONAL.
ENDCLASS.

CLASS lcl_zsadl_ext_sadl_mrg_range IMPLEMENTATION.
  METHOD constructor.
    me->core_object = core_object.
  ENDMETHOD.

  METHOD ipr_zsadl_ext_sadl_mrg_range~add_condition_from_provider.
*"------------------------------------------------------------------------*
*" Declaration of PRE-method, do not insert any comments here please!
*"
*"methods ADD_CONDITION_FROM_PROVIDER
*"  importing
*"    !IO_SADL_CONDITION_PROVIDER type ref to IF_SADL_CONDITION_PROVIDER
*"    !IT_ELEMENTS type IF_SADL_QUERY_ENGINE_TYPES=>TT_ELEMENT_INFO optional
*"  raising
*"    CX_SADL_STATIC
*"    CX_SADL_CONTRACT_VIOLATION .
*"------------------------------------------------------------------------*
    INSERT LINES OF zcl_sadl_filter=>get_provider_range( VALUE #( ( io_sadl_condition_provider ) ) ) INTO TABLE core_object->zz_mt_range[].
  ENDMETHOD.
ENDCLASS.
