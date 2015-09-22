my_routes = [File.join(File.dirname(__FILE__), "routes.rb")]
ArchivesSpace::Application.config.paths['config/routes'].concat(my_routes)

require_relative "../lib/document_keyword_definitions"

Rails.application.config.after_initialize do

  ActionView::PartialRenderer.class_eval do
    alias_method :render_pre_aspace_onbase, :render
    def render(context, options, block)
      result = render_pre_aspace_onbase(context, options, block);

      # Add missing plugin hook for events
      if options[:partial] == "events/form"
        # required until PR is released: https://github.com/archivesspace/archivesspace/pull/247
        result += render(context, options.merge(:partial => "events/form_ext"), nil)
      end

      result
    end
  end


  ApplicationController.class_eval do

    alias_method :find_opts_pre_aspace_onbase, :find_opts

    def find_opts
      orig = find_opts_pre_aspace_onbase
      orig.merge('resolve[]' => orig['resolve[]'] + ['onbase_documents'])
    end

  end


end