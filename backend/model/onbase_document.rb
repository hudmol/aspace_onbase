class OnbaseDocument < Sequel::Model(:onbase_document)
  include ASModel
  corresponds_to JSONModel(:onbase_document)

  set_model_scope :global

  def display_string
    "#{name} [#{onbase_id}]"
  end

  def self.sequel_to_jsonmodel(objs, opts = {})
    jsons = super

    jsons.zip(objs).each do |json, obj|
      json['display_string'] = obj.display_string
    end

    jsons
  end

end
