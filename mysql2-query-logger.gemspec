require_relative 'lib/mysql2-query-logger'

Gem::Specification.new do |spec|
  spec.name          = "mysql2-query-logger"
  spec.version       = Mysql2QueryLogger::VERSION
  spec.authors       = ["Kazuhito Hokamura"]
  spec.email         = ["kazuhito-hokamura@cookpad.com"]

  spec.summary       = "-"
  spec.description   = "-"
  spec.homepage      = "https://example.com/"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "mysql2-cs-bind"
end
