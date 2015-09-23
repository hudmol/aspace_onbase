class OnbaseDocumentsController < ApplicationController

  # FIXME: use proper permission here
  set_access_control  "view_repository" => [:index, :show, :download],
                      "manage_repository" => [:new, :edit, :create, :update, :merge, :delete, :keywords_form]



  def index
    @search_data = Search.global({"sort" => "title_sort asc"}.merge(params_for_backend_search.merge({"facet[]" => SearchResultData.BASE_FACETS})),
                                 "onbase_document")
  end

  def show
    @onbase_document = JSONModel(:onbase_document).find(params[:id])
  end

  def new
    @onbase_document = JSONModel(:onbase_document).new._always_valid!
    @parent_type = params[:parent_type].intern

    raise "Can only create an OnBase document from within the context of another record" if !inline?

    render_aspace_partial :partial => "onbase_documents/new"
  end

  def edit
    @onbase_document = JSONModel(:onbase_document).find(params[:id])
  end

  def create
    file = params[:onbase_document][:file]
    keywords = params[:keywords] || {}
    document_type = params[:onbase_document][:document_type]

    errors = []

    errors << I18n.t("plugins.onbase_document._frontend.messages.file_required") if file.blank?

    if document_type.blank?
      errors << I18n.t("plugins.onbase_document._frontend.messages.document_type_required")
    else
      errors << validate_keywords(document_type, keywords)
    end

    errors.flatten!

    if !errors.empty?
      return render :json => errors, :status => 500
    end

    File.open(file.tempfile) do |fh|
      response = JSONModel::HTTP.post_form("/onbase_upload",
                                           {
                                             'file' => UploadIO.new(fh, file.content_type, file.original_filename),
                                             'document_type' => params[:onbase_document][:document_type],
                                             'keywords' => keywords.to_json
                                           },
                                           :multipart_form_data)

      render :json => ASUtils.json_parse(response.body), :status => response.code
    end
  end

  def update
    handle_crud(:instance => :onbase_document,
                :model => JSONModel(:onbase_document),
                :obj => JSONModel(:onbase_document).find(params[:id]),
                :on_invalid => ->(){ return render :action => :edit },
                :on_valid => ->(id){
                  flash[:success] = I18n.t("plugins.onbase_document._frontend.messages.updated")
                  redirect_to :controller => :onbase_documents, :action => :edit, :id => id
                })
  end

  def delete
    onbase_document = JSONModel(:onbase_document).find(params[:id])
    onbase_document.delete

    flash[:success] = I18n.t("plugins.onbase_document._frontend.messages.deleted", JSONModelI18nWrapper.new(:onbase_document => onbase_document))
    redirect_to(:controller => :onbase_documents, :action => :index, :deleted_uri => onbase_document.uri)
  end


  def keywords_form
    definitions = DocumentKeywordDefinitions.new
    @doctype = params[:doctype]

    if @doctype.blank?
      return render :text => ""
    end

    @definition = definitions.definitions_for_document_type(@doctype)

    render_aspace_partial :partial => "onbase_documents/keywords_form"
  end


  def download
    render :text => "DOING THINGS"
  end


  private

  helper_method :onbase_document_doctype_options
  def onbase_document_doctype_options(record_type)
    definitions = DocumentKeywordDefinitions.new
    [""] + definitions.document_types_for_record(record_type).keys
  end


  def validate_keywords(doctype, keywords)
    errors = []

    definitions = DocumentKeywordDefinitions.new

    definitions.definitions_for_document_type(doctype).each do |field|
      if field[:type] != "generated"
        value = keywords[field[:code]]

        if value.blank?
          errors << I18n.t("plugins.onbase_document._frontend.messages.keyword_required", :code => I18n.t("plugins.onbase_document_keyword.#{field[:code]}"))
        end
      end
    end

    errors
  end

end
