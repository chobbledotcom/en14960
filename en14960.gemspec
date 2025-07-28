# frozen_string_literal: true

require_relative "lib/en14960/version"

Gem::Specification.new do |spec|
  spec.name = "en14960"
  spec.version = EN14960::VERSION
  spec.authors = ["Chobble.com"]
  spec.email = ["hello@chobble.com"]

  spec.summary = "BS EN 14960:2019 safety standard calculators for inflatable play equipment"
  spec.description = "A Ruby gem providing calculators and validators for BS EN 14960:2019 - the safety standard for inflatable play equipment. Includes calculations for anchoring requirements, slide safety, user capacity, and material specifications."
  spec.homepage = "https://github.com/chobbledotcom/en14960"
  spec.license = "AGPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile]) ||
        f.end_with?(".gem")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # No runtime dependencies - this gem is standalone

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.0"
  spec.add_development_dependency "simplecov", "~> 0.21"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
