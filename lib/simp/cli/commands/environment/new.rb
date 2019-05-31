require 'simp/cli/commands/command'
require 'simp/cli/environment/omni_env_controller'

# Cli command to create a new Extra/Omni environment
#
# TODO: As more `simp environment` sub-commands are added, a lot of this code
#      could probably be abstracted into a common class or mixin
class Simp::Cli::Commands::Environment::New < Simp::Cli::Commands::Command
  # @return [String] description of command
  def self.description
    'Create a new SIMP "Extra" (default) or "omni" environment'
  end

  # Run the command's `--help` strategy
  def help
    parse_command_line(['--help'])
  end

  # Parse command-line options for this simp command
  # @param args [Array<String>] ARGV-style args array
  def parse_command_line(args)
    # TODO: simp cli should read a config file that can override these defaults
    # these options (preferrable mimicking cmd-line args)
    default_strategy = :skeleton
    options = {
      action:   :create,
      strategy: :skeleton,
      types: {
        puppet: {
          enabled:            true,
          strategy:           default_strategy, # :skeleton, :copy
          puppetfile:         false,
          puppetfile_install: false,
          deploy:             false,
          backend:            :directory,
          environmentpath:    Simp::Cli::Utils.puppet_info[:config]['environmentpath']
        },
        secondary: {
          enabled:         true,
          strategy:        default_strategy,   # :skeleton, :copy, :link
          backend:         :directory,
          environmentpath: Simp::Cli::Utils.puppet_info[:secondary_environment_path]
        },
        writable: {
          enabled:         true,
          strategy:        default_strategy,   # :skeleton, :copy, :link
          backend:         :directory,
          environmentpath: Simp::Cli::Utils.puppet_info[:writable_environment_path]
        }
      }
    }

    opt_parser = OptionParser.new do |opts|
      opts.banner = '== simp environment new [options]'
      opts.separator <<-HELP_MSG.gsub(%r{^ {8}}, '')

        #{self.class.description}

        Usage:

          simp environment new ENVIRONMENT [OPTIONS]

        By default, this command will:

          * create a new environment (–-skeleton)
          * raise an error if an environment directory already exists

        It can create a complete SIMP omni-environment with --puppet-env

        Examples:

             # Create a skeleton new development environment
             simp env new development

             # Link staging's Secondary and Writable env dirs to production
             simp env new staging --link production

             # Create a separate copy of production (will diverge over time)
             simp env new newprod --copy production

             # Create new omni environment
             simp env new local_prod --puppetfile

        Options:

      HELP_MSG

      opts.on('--skeleton',
              '(default) Generate environments from skeleton templates.',
              'Implies --puppetfile') do
                options[:strategy]   = :skeleton
                options[:puppetfile] = true
                # TODO: implement
                fail NotImplementedError, 'TODO: implement --skeleton'
              end

      opts.on('--copy ENVIRONMENT', Simp::Cli::Utils::REGEXP_PUPPET_ENV_NAME,
              'Copy assets from ENVIRONMENT') do |_src_env|
                # TODO: implement
                fail NotImplementedError, 'TODO: implement --copy'
              end

      opts.on('--link ENVIRONMENT', Simp::Cli::Utils::REGEXP_PUPPET_ENV_NAME,
              'Symlink Secondary and Writeable environment directories',
              'to ENVIRONMENT.  If --puppet-env is set, the Puppet',
              'environment will --copy.') do |_src_env|
                # TODO: implement
                # TODO: implement --puppet-env => --copy logic
                fail NotImplementedError, 'TODO: implement --link'
              end

      opts.on('--[no-]puppetfile',
              'Generate Puppetfiles in Puppet env directory',
              '  * `Puppetfile` will only be created if missing',
              '  * `Puppetfile.simp` will be generated from RPM/',
              '  * implies `--puppet-env`') do |v|
        if (options[:types][:puppet][:puppetfile] = v)
          options[:types][:puppet][:enabled] = true
        end
      end

      opts.on('--[no-]puppetfile-install',
              'Automatically deploys Puppetfile in Puppet environment',
              'directory after creating it',
              '  * implies `--puppet-env`',
              '  * Does NOT imply `--puppetfile`') do |v|
        if (options[:types][:puppet][:puppetfile_install] = v)
          options[:types][:puppet][:enabled] = true
        end
      end

      opts.on('--[no-]puppet-env',
              'Includes Puppet environment when `--puppet-env`',
              '(default: --no-puppet-env)') { |v| options[:types][:puppet][:enabled] = v }

      opts.on('--[no-]secondary-env',
              'Includes Secondary environment when `--secondary-env`',
              '(default: --secondary-env)') { |v| options[:types][:secondary][:enabled] = v }

      opts.on('--[no-]writable-env',
              'Includes writable environment when `--writable-env`',
              '(default: --writable-env)') { |v| options[:types][:writable][:enabled] = v }

      opts.separator ''
      opts.on_tail('-h', '--help', 'Print this message') do
        puts opts
        exit
      end
    end
    opt_parser.parse!(args)
    options
  end

  # Run command logic
  # @param args [Array<String>] ARGV-style args array
  def run(args)
    options = parse_command_line(args)
    action  = options.delete(:action)

    if args.empty?
      fail(Simp::Cli::ProcessingError, "ERROR: 'ENVIRONMENT' is required.")
    end

    env = args.shift

    unless env =~ Simp::Cli::Utils::REGEXP_PUPPET_ENV_NAME
      fail(
        Simp::Cli::ProcessingError,
        "ERROR: '#{env}' is not an acceptable environment name"
      )
    end

    require 'yaml'
    puts options.to_yaml, '', ''

    omni_controller = Simp::Cli::Environment::OmniEnvController.new(options, env)
    omni_controller.send(action)
  end
end
