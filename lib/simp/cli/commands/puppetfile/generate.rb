require 'simp/cli/commands/command'

class Simp::Cli::Commands::Puppetfile::Generate < Simp::Cli::Commands::Command
  class PuppetModuleRpmRepoScanner
    def initialize
      @simp_rpm_module_path = '/usr/share/simp/modules'
      @simp_git_repo_path = '/var/simp/git_repos'
    end

    def run
    end

    def scan_module
      # For each module:
      # get variables
      forge_org   = nil
      module_name = nil
      # check: do RPM files exist? || fail()
      module_version = nil # metadata.json
      # check: local git repo exists || fail()
      puts forge_org, module_name, module_version
    end
  end

  def self.description
    'Generate a Puppetfile from SIMP RPM-managed local git repos'
  end

  # Run the command's `--help` action
  def help
    parse_command_line( [ '--help' ] )
  end

  # Parse command-line options for the command
  # @param args [Array<String>] ARGV-style args array
  def parse_command_line(args)
    opt_parser = OptionParser.new do |opts|
      opts.banner = "simp puppetfile generate [options]"
      opts.separator <<-HELP_MSG.gsub(%r{^ {8}}, '')

        #{self.class.description}

        Options:

      HELP_MSG

      opts.on('-k', '--kill_agent', 'Ignore the status of agent_catalog_run_lockfile, and',
              'force kill active puppet agents at the beginning of',
              'bootstrap') do |_k|
        @kill_agent = true
      end

      opts.separator ""
      opts.on_tail('-h', '--help', 'Print this message') do
        puts opts
        exit
      end
    end
    opt_parser.order!(args)
  end

  # Run command
  def run(args)
    parse_command_line(args)
    pmrr_scanner = PuppetModuleRpmRepoScanner.new
  end
end

