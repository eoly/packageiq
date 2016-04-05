require 'packageiq/command'
require 'socket'

module Packageiq
  module Provider
    # rhel based system package provider
    class RHEL
      # mapping of yum info query tags to symbol
      RPM_INFO_KEY = {
        :name         => '%{NAME}',
        :epoch        => '%{EPOCH}',
        :version      => '%{VERSION}',
        :release      => '%{RELEASE}',
        :arch         => '%{ARCH}',
        :install_date => '%{INSTALLTIME:date}',
        :group        => '%{GROUP}',
        :size         => '%{SIZE}',
        :license      => '%{LICENSE}',
        :signature    => '%|DSAHEADER?{%{DSAHEADER:pgpsig}}:{%|RSAHEADER?{%{RSAHEADER:pgpsig}}:{%|SIGGPG?{%{SIGGPG:pgpsig}}:{%|SIGPGP?{%{SIGPGP:pgpsig}}:{(none)}|}|}|}|',
        :source_rpm   => '%{SOURCERPM}',
        :build_date   => '%{BUILDTIME:date}',
        :build_host   => '%{BUILDHOST}',
        :packager     => '%{PACKAGER}',
        :vendor       => '%{VENDOR}',
        :url          => '%{URL}',
        :summary      => '%{SUMMARY}'
      }

      attr_reader :command_handler, :hostname, :timestamp, :os_release

      def initialize
        @command_handler  = Packageiq::Command.new
        @hostname         = Socket.gethostname
        @timestamp        = Time.new
        @os_release       = rhel_release.strip
      end

      # returns array of installed packages
      def installed
        installed = run('rpm -qa')
        installed.split("\n")
      end

      # returns array of available yum update hashes
      def updates
        updates = run('yum list updates')
        parse_list(updates)
      end

      # returns hash of rpm info
      def info(package)
        queryformat = ''
        RPM_INFO_KEY.each do |symbol, query|
          queryformat += "#{symbol}: #{query}\\n"
        end
        info = run("rpm -q --queryformat \"#{queryformat}\" #{package}")
        parse_info(info)
      end

      # returns redhat relase string
      def rhel_release
        run('cat /etc/redhat-release')
      end

      # returns hash of server info
      def server_info
        {
          server:
          {
            hostname: hostname,
            os_release: os_release,
            collection_time: timestamp
          }
        }
      end

      # build full package inventory
      # returns array of package_entry hashes
      def build_inventory
        inventory = []
        updates_array = updates
        installed.each do |package|
          package_info  = info(package)
          package_entry = updateable(package_info, updates_array)
          package_entry.merge!(server_info)
          inventory << package_entry
        end
        inventory
      end

      # adds available update info to package_info hash
      def updateable(package_info, updates)
        update_info = { update: { available: 'no', version: '-', repo: '-' } }
        updates.each do |update|
          next unless update[:name] == package_info[:package][:name]
          update_info[:update][:available]  = 'yes'
          update_info[:update][:version]    = update[:version]
          update_info[:update][:repo]       = update[:repo]
          break
        end
        package_info.merge(update_info)
      end

      private

      # use command handler to run command
      def run(command)
        command_handler.command = command
        command_handler.run
        command_handler.stdout
      end

      # normalize output so each package listing is on one line
      def unwrap(output)
        output.gsub(/\n/, '#').gsub(/#\s/, ' ').gsub(/#/, "\n")
      end

      # parse list output to hash, return array of hashes
      def parse_list(list)
        list          = unwrap(list)
        lines         = list.split("\n")
        package_list  = []
        lines.each do |line|
          package_info = {}
          next if line =~ Regexp.new(/^(Installed|Updated) Packages$/)
          parts   = line.split
          package = parts[0]
          package_info[:name] = package.split('.')[0]
          package_info[:arch] = package.split('.')[1]
          package_info[:version] = parts[1]
          package_info[:repo]    = parts[2]
          package_list << package_info
        end
        package_list
      end

      # parse rpm info into hash
      def parse_info(info)
        lines      = info.split("\n")
        info_hash  = { package: {} }
        lines.each do |line|
          RPM_INFO_KEY.each do |symbol, query|
            parse_regex = Regexp.new("^(#{symbol})+\s*:{1}\s{1}(.*)$")
            parts = parse_regex.match(line)
            info_hash[:package][symbol] = parts[2] if parts
          end
        end
        info_hash
      end
    end
  end
end
