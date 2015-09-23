class CommonIndexer

  @@record_types << :onbase_document

  add_indexer_initialize_hook do |indexer|

    indexer.add_document_prepare_hook {|doc, record|
      if record['record']['jsonmodel_type'] == 'onbase_document'
        doc['title'] = record['record']['display_string']
      end
    }

  end

end
