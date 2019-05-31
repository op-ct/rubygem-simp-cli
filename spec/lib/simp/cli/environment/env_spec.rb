# frozen_string_literal: true

require 'simp/cli/environment/env'
require 'spec_helper'

describe Simp::Cli::Environment::Env do
  describe '#new' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'requires an acceptable environment name' do
      expect { described_class.new('acceptable_name', {}) }.not_to raise_error
      expect { described_class.new('-2354', {}) }.to raise_error(ArgumentError, %r{Illegal environment name})
      expect { described_class.new('2abc_def', {}) }.to raise_error(ArgumentError, %r{Illegal environment name})
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'with abstract methods' do
    subject(:described_object) { described_class.new('acceptable_name', {}) }

    let(:regex) { %r{Implement .[a-z_]+ in a subclass} }

    %i[create fix update validate remove].each do |action|
      describe "##{action}" do
        it { expect { described_object.create }.to raise_error(NotImplementedError, regex) }
      end
    end
  end
end
