# frozen_string_literal: true

require 'tasks/spec_helper'

describe Rake::Task['procedures:erase'] do
  before do
    category = Category.create(name: 'Diagnostic')

    root_procedure = Procedure.create(name: 'Endoscopy', parent: category)

    Procedure.create(name: 'Colonoscopy', parent: root_procedure)
    Procedure.create(name: 'Gastroscopy', parent: root_procedure)

    next unless invoke

    described_class.reenable
    described_class.invoke
  end

  describe 'categories count' do
    subject { Category.count }

    context 'without invocation' do
      let(:invoke) { false }

      it { is_expected.to eq 1 }
    end

    context 'with invocation' do
      let(:invoke) { true }

      it { is_expected.to be_zero }
    end
  end

  describe 'procedures count' do
    subject { Procedure.count }

    context 'without invocation' do
      let(:invoke) { false }

      it { is_expected.to eq 3 }
    end

    context 'with invocation' do
      let(:invoke) { true }

      it { is_expected.to be_zero }
    end
  end
end
