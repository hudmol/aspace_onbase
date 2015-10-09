class ArchivesSpaceService < Sinatra::Base

  # TODO: use update_onbase_record permissions where needed

  Endpoint.post('/repositories/:repo_id/onbase_documents/:id')
    .description("Update an Onbase Document")
    .params(["id", :id],
            ["repo_id", :repo_id],
            ["onbase_document", JSONModel(:onbase_document), "The updated record", :body => true])
    .permissions([:update_onbase_record])
    .returns([200, :updated]) \
  do
    handle_update(OnbaseDocument, params[:id], params[:onbase_document])
  end


  Endpoint.get('/repositories/:repo_id/onbase_documents/:id/download')
    .description("Download an Onbase Document")
    .params(["id", :id],
            ["repo_id", :repo_id])
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


  Endpoint.post('/repositories/:repo_id/onbase_upload')
    .description("Upload a document to Onbase and return its assigned ID")
    .params(["file", UploadFile],
            ["document_type", String],
            ["keywords", String],
            ["repo_id", :repo_id])
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




  Endpoint.post('/repositories/:repo_id/onbase_documents')
    .description("Create an Onbase Document")
    .params(["onbase_document", JSONModel(:onbase_document), "The record to create", :body => true],
            ["repo_id", :repo_id])
    .permissions([:update_onbase_record])
    .returns([200, :created]) \
  do
    handle_create(OnbaseDocument, params[:onbase_document])
  end


  Endpoint.get('/repositories/:repo_id/onbase_documents')
    .description("Get a list of Onbase Documents")
    .params(["repo_id", :repo_id])
    .paginated(true)
    .permissions([])
    .returns([200, "[(:onbase_document)]"]) \
  do
    handle_listing(OnbaseDocument, params)
  end


  Endpoint.get('/repositories/:repo_id/onbase_documents/:id')
    .description("Get an Onbase Document by ID")
    .params(["id", :id],
            ["repo_id", :repo_id],
            ["resolve", :resolve])
    .permissions([])
    .returns([200, "(:onbase_document)"]) \
  do
    json = OnbaseDocument.to_jsonmodel(params[:id])
    json_response(resolve_references(json, params[:resolve]))
  end


  Endpoint.get('/repositories/:repo_id/onbase_documents/:id/keywords')
  .description("Fetch the keywords for an Onbase Document from the ROBI service")
  .params(["id", :id],
          ["repo_id", :repo_id])
  .permissions([])
  .returns([200, "(:onbase_document)"]) \
  do
    onbase_document = OnbaseDocument.to_jsonmodel(params[:id])
    client = OnbaseClient.new(:user => current_user.username)
    json_response(client.get_keywords(onbase_document['onbase_id']))
  end


  Endpoint.delete('/repositories/:repo_id/onbase_documents/:id')
    .description("Delete an Onbase Document")
    .params(["id", :id],
            ["repo_id", :repo_id])
    .permissions([:delete_onbase_record])
    .returns([200, :deleted]) \
  do
    client = OnbaseClient.new(:user => current_user.username)

    doc = OnbaseDocument[params[:id]]
    if client.delete(doc.onbase_id)
      handle_delete(OnbaseDocument, params[:id])
    end
  end


  Endpoint.get('/repositories/:repo_id/search/onbase_document')
  .description("Search across OnBase Documents")
  .params(*BASE_SEARCH_PARAMS,
          ["repo_id", :repo_id])
  .permissions([])
  .paginated(true)
  .returns([200, ""]) \
  do
    json_response(Search.search(params.merge(:type => ['onbase_document']), nil))
  end
end
