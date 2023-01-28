require_relative "lib/fake_services/version"

Gem::Specification.new do |spec|
  spec.name = "fake_services"
  spec.version = FakeServices::VERSION
  spec.authors = ["Diego Selzlein"]
  spec.email = ["diegoselzlein@gmail.com"]

  spec.summary = "Fake Services"
  spec.description = "Fake objects for some famous services to allow you to easily test your client code"
  spec.homepage = "https://github.com/diego-aslz/fake_services"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/diego-aslz/fake_services"
  spec.metadata["changelog_uri"] = "https://github.com/diego-aslz/fake_services/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rack", "~> 2.2.3"
  spec.add_dependency "webmock", "~> 1.24.6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
