class ArchivesSpaceService < Sinatra::Base

  # TODO: use update_onbase_record permissions where needed

  Endpoint.post('/onbase_documents/:id')
    .description("Update an Onbase Document")
    .params(["id", :id],
            ["onbase_document", JSONModel(:onbase_document), "The updated record", :body => true])
    .permissions([:update_onbase_record])
    .returns([200, :updated]) \
  do
    handle_update(OnbaseDocument, params[:id], params[:onbase_document])
  end


  Endpoint.post('/onbase_upload')
    .description("Upload a document to Onbase and return its assigned ID")
    .params(["file", UploadFile],
            ["document_type", String])
    .permissions([:update_onbase_record])
    .returns([200, :created]) \
  do
    client = OnbaseClient.new
    file = params[:file]

    # p client.upload(file.tempfile, file.original_filename, file.content_type, params[:document_type], current_user.username)

    onbase_id = SecureRandom.hex

    obj = OnbaseDocument.create_from_json(JSONModel(:onbase_document).from_hash(:onbase_id => onbase_id,
                                                                                :document_type => params[:document_type]), {})

    json_response(OnbaseDocument.to_jsonmodel(obj))
  end


  Endpoint.post('/onbase_documents')
    .description("Create an Onbase Document")
    .params(["onbase_document", JSONModel(:onbase_document), "The record to create", :body => true])
    .permissions([:update_onbase_record])
    .returns([200, :created]) \
  do
    handle_create(OnbaseDocument, params[:onbase_document])
  end


  Endpoint.get('/onbase_documents')
    .description("Get a list of Onbase Documents")
    .params()
    .paginated(true)
    .permissions([])
    .returns([200, "[(:onbase_document)]"]) \
  do
    handle_listing(OnbaseDocument, params)
  end


  Endpoint.get('/onbase_documents/:id')
    .description("Get an Onbase Document by ID")
    .params(["id", :id])
    .permissions([])
    .returns([200, "(:onbase_document)"]) \
  do
    json_response(OnbaseDocument.to_jsonmodel(params[:id]))
  end


  Endpoint.delete('/onbase_documents/:id')
    .description("Delete an Onbase Document")
    .params(["id", :id])
    .permissions([:delete_onbase_record])
    .returns([200, :deleted]) \
  do
    handle_delete(OnbaseDocument, params[:id])
  end


  Endpoint.get('/search/onbase_document')
  .description("Search across OnBase Documents")
  .params(*BASE_SEARCH_PARAMS)
  .permissions([])
  .paginated(true)
  .returns([200, ""]) \
  do
    json_response(Search.search(params.merge(:type => ['onbase_document']), nil))
  end
end
