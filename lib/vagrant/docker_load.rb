require "vagrant/docker_load/version"

module Vagrant
  module DockerLoad
    class Plugin < Vagrant.plugin("2")
      name "Vagrant Docker image loader"

      command "docker-load" do
        require_relative "docker_load/command"
        Command
      end
    end
  end
end
