CLASS zcl_sadl_annotation_ext DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CONSTANTS id TYPE string VALUE 'ZABAP.VIRTUALENTITY' ##NO_TEXT.

    CLASS-METHODS create
      IMPORTING
        !iv_class_name TYPE csequence
      RETURNING
        VALUE(ro_exit) TYPE REF TO zif_sadl_exit .

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ts_cache,
        name TYPE string,
        exit TYPE REF TO zif_sadl_exit,
      END OF ts_cache .

    CLASS-DATA:
      mt_cache TYPE SORTED TABLE OF ts_cache WITH UNIQUE KEY name .
ENDCLASS.



CLASS ZCL_SADL_ANNOTATION_EXT IMPLEMENTATION.


  METHOD create.
    ASSIGN mt_cache[ name = iv_class_name ] TO FIELD-SYMBOL(<ls_cache>).
    IF sy-subrc = 0.
      ro_exit = <ls_cache>-exit.
      RETURN.
    ENDIF.

    TRY.
        DATA(lv_class_name) = CONV string( iv_class_name ).
        IF lv_class_name CP `'*'`.
          REPLACE ALL OCCURRENCES OF `'` IN lv_class_name WITH ``.
        ENDIF.

        CREATE OBJECT ro_exit TYPE (lv_class_name).
      CATCH cx_dynamic_check INTO DATA(lo_error).
        CLEAR ro_exit.
    ENDTRY.

    INSERT VALUE #( name = iv_class_name
                    exit = ro_exit ) INTO TABLE mt_cache.
  ENDMETHOD.
ENDCLASS.
