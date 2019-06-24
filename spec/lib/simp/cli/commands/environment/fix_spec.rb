# frozen_string_literal: true

require 'simp/cli/commands/environment'
require 'simp/cli/commands/environment/fix'
require 'simp/cli/environment/omni_env_controller'
require 'spec_helper'

describe Simp::Cli::Commands::Environment::Fix do
  describe '#run' do
    context 'with default arguments' do
      subject(:run) { proc { described_class.new.run([]) } }

      it 'requires an ENVIRONMENT argument' do
        allow($stdout).to receive(:write)
        allow($stderr).to receive(:write)
        expect { run.call }.to raise_error(Simp::Cli::ProcessingError, %r{ENVIRONMENT.*is required})
      end
    end

    context 'with an invalid environment' do
      it 'requires a valid ENVIRONMENT argument' do
        allow($stdout).to receive(:write)
        allow($stderr).to receive(:write)
        expect { described_class.new.run(['.40ris']) }.to raise_error(
          Simp::Cli::ProcessingError, %r{is not an acceptable environment name}
        )
      end
    end

    context 'with default options' do
      let(:omni_spy) { instance_double('OmniEnvController') }

      before(:each) do
        allow(Simp::Cli::Environment::OmniEnvController).to receive(:new).and_return(omni_spy)
        allow(omni_spy).to receive(:fix)
      end

      it 'runs OmniEnvController#fix' do
        described_class.new.run(['foo', '--console-only'])

        expect(Simp::Cli::Environment::OmniEnvController).to have_received(:new).with(
          hash_including(
            types: hash_including(
              puppet: hash_including(backend: :directory),
              secondary: hash_including(backend: :directory),
              writable: hash_including(backend: :directory)
            )
          ), 'foo'
        )
      end

      it 'runs OmniEnvController#fix' do
        described_class.new.run(['foo', '--console-only'])
        expect(omni_spy).to have_received(:fix).once
      end
    end
  end
end
