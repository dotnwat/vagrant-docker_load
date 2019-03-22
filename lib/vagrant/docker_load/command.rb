require "tempfile"
require "open3"

module Vagrant
  module DockerLoad
    class Command < Vagrant.plugin(2, :command)
      def self.synopsis
        "loads a host docker image into vagrant machines"
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant docker-load src-img dst-img"
          o.separator ""
        end

        src_img, dst_img = parse_options(opts)
        return if dst_img.nil?

        src = Tempfile.new("vagrant-docker_load")

        run("docker save -o #{src.path} #{src_img}")

        with_target_vms(nil) do |machine|
          ssh_info = machine.ssh_info
          raise Vagrant::Errors::SSHNotReady if ssh_info.nil?

          log_level = ssh_info[:log_level] || "FATAL"

          args = [
            "-p", ssh_info[:port].to_s,
            "-o", "LogLevel=#{log_level}"]

          if ssh_info[:verify_host_key] == :never || !ssh_info[:verify_host_key]
            args += [
              "-o", "StrictHostKeyChecking=no",
              "-o", "UserKnownHostsFile=/dev/null"]
          end

          if ssh_info[:proxy_command]
            args += ["-o", "ProxyCommand=#{ssh_info[:proxy_command]}"]
          end

          if ssh_info[:private_key_path]
            ssh_info[:private_key_path].each do |path|
              args += ["-i", path]
            end
          end

          args += ["#{ssh_info[:username]}@#{ssh_info[:host]}"]

          ssh_command = ["ssh", args]

          load_command = ssh_command + ["sudo", "docker", "load"]
          Open3.pipeline(load_command.join(" "), :in => src.path)

          tag_command = ssh_command + ["sudo", "docker", "tag", src_img, dst_img]
          system(tag_command.join(" "))
        end
      end

      def run(command)
        stdout, stderr, status = Open3.capture3(command)
        unless status.success?
          @env.ui.error(stderr)
          raise Vagrant::Errors::SSHNotReady
        end
      end
    end
  end
end
