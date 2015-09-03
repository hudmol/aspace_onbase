{
  :schema => {
    "$schema" => "http://www.archivesspace.org/archivesspace.json",
    "version" => 1,
    "type" => "object",
    "uri" => "/onbase_documents",
    "properties" => {
      "uri" => {"type" => "string", "required" => false},
      "onbase_id" => {"type" => "string", "maxLength" => 255, "ifmissing" => "error"},
      "name" => {"type" => "string", "ifmissing" => "error"},
      "keywords" => {"type" => "string"},
    },
  },
}
