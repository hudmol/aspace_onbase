ArchivesSpace::Application.routes.draw do
  match('/plugins/onbase_documents/upload' => 'onbase_documents#upload', :via => [:post])
  resources :onbase_document
  match('/plugins/onbase_documents/:id' => 'onbase_documents#update', :via => [:post])
  match('/plugins/onbase_documents/:id/delete' => 'onbase_documents#delete', :via => [:post])
end
