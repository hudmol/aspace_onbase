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


  Endpoint.get('/onbase_documents/:id/download')
    .description("Download an Onbase Document")
    .params(["id", :id],)
    .permissions([])
    .returns([200, :updated]) \
  do
    client = OnbaseClient.new(:user => current_user.username)

    onbase_document = OnbaseDocument.to_jsonmodel(params[:id])

    document = client.stream_record(onbase_document["onbase_id"])

    if document
      [200, {"Content-Type" => document.content_type,
             "Content-Length" => document.content_length},
       document.body]
    else
      [404, {}, ""]
    end
  end


  Endpoint.post('/onbase_upload')
    .description("Upload a document to Onbase and return its assigned ID")
    .params(["file", UploadFile],
            ["document_type", String],
            ["keywords", String])
    .permissions([:update_onbase_record])
    .returns([200, :created]) \
  do
    client = OnbaseClient.new(:user => current_user.username)
    file = params[:file]
    keywords = ASUtils.json_parse(params[:keywords] || "{}")

    upload_response = client.upload(file.tempfile, file.filename, file.type, params[:document_type], keywords)

    onbase_id = upload_response["documentId"].to_s

    obj = OnbaseDocument.create_from_json(JSONModel(:onbase_document).from_hash(:onbase_id => onbase_id,
                                                                                :document_type => params[:document_type],
                                                                                :filename => file.filename,
                                                                                :mime_type => file.type), {})

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
    client = OnbaseClient.new(:user => current_user.username)

    json_response(OnbaseDocument.to_jsonmodel(params[:id]))
  end


  Endpoint.get('/onbase_documents/:id/keywords')
  .description("Fetch the keywords for an Onbase Document from the ROBI service")
  .params(["id", :id])
  .permissions([])
  .returns([200, "(:onbase_document)"]) \
  do
    onbase_document = OnbaseDocument.to_jsonmodel(params[:id])
    client = OnbaseClient.new(:user => current_user.username)
    json_response(client.get_keywords(onbase_document['onbase_id']))
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
