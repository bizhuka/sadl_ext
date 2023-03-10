"Name: \TY:/IWBEP/CL_MGW_ABS_DATA\IN:/IWBEP/IF_MGW_APPL_SRV_RUNTIME\ME:GET_STREAM\SE:BEGIN\EI
ENHANCEMENT 0 ZSADL_EXT_SADL_STREAM_ENTITY.

    DO 1 TIMES.
      CHECK mr_service_document_name IS NOT INITIAL.

      TRY.
          DATA(lo_zabap_stream_runtime) = zcl_sadl_filter=>get_stream_runtime(
             iv_service_name    = mr_service_document_name->*
             iv_entity_set_name = iv_entity_set_name " iv_entity_name
          ).
          CHECK lo_zabap_stream_runtime IS NOT INITIAL.

          zcl_sadl_filter=>get_stream_filter( EXPORTING io_request = io_tech_request_context
                                              IMPORTING ev_filter  = DATA(zz_lv_filter)
                                                        et_filter  = DATA(zz_lt_filter) ).
          CAST zif_sadl_stream_runtime( lo_zabap_stream_runtime )->get_stream(
            EXPORTING io_srv_runtime          = me
                      iv_filter               = zz_lv_filter
                      it_filter               = zz_lt_filter
                      iv_entity_name          = iv_entity_name
                      iv_entity_set_name      = iv_entity_set_name
                      iv_source_name          = iv_source_name
                      it_key_tab              = it_key_tab
                      it_navigation_path      = it_navigation_path
                      io_tech_request_context = io_tech_request_context
            IMPORTING er_stream               = er_stream
                      es_response_context     = es_response_context ).
          RETURN.
        CATCH cx_sadl_static INTO DATA(lo_zabap_error).
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
            EXPORTING
              previous = lo_zabap_error.
      ENDTRY.
    ENDDO.

ENDENHANCEMENT.
