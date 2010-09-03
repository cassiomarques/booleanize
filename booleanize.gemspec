Gem::Specification.new do |s|
  s.name     = "booleanize"
  s.version  = "0.4"
  s.date     = "2010-09-03"
  s.summary  = "A Rails plugin that adds some new methods for boolean attributes in Active Record models."
  s.email    = "cassiommc@gmail.com"
  s.homepage = "http://github.com/cassiomarques/booleanize"
  s.description = "A Rails plugin that adds some new methods for boolean attributes in Active Record models."
  s.has_rdoc = true
  s.authors  = [ "Cássio Marques" ]
  s.files    = [
    "CHANGELOG",
    "MIT-LICENSE",
    "README.rdoc",
    "Rakefile",
    "init.rb",
    "lib/booleanize.rb"
  ]
  s.test_files = [
    "spec/booleanize_spec.rb",
    "spec/db/create_testing_structure.rb"
  ]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc"]
end
