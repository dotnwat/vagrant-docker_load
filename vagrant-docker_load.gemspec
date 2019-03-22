lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vagrant/docker_load/version"

Gem::Specification.new do |spec|
  spec.name          = "vagrant-docker_load"
  spec.version       = Vagrant::DockerLoad::VERSION
  spec.authors       = ["Noah Watkins"]
  spec.email         = ["noahwatkins@gmail.com"]
  spec.summary       = "Load Docker images into Vagrant machines"
  spec.homepage      = "https://github.com/noahdesu/vagrant-docker_load"
  spec.license       = "MIT"
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
