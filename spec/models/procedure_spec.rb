# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Procedure, type: :model do
  let(:category) { Category.new(name: 'Diagnostic') }

  describe '.create' do
    subject(:procedure) do
      described_class.create(name: 'Colonoscopy', parent: parent)
    end

    context 'without parent' do
      let(:parent) { nil }

      it { is_expected.not_to be_valid }

      describe 'parent' do
        subject { super().parent }

        it { is_expected.to be_nil }
      end
    end

    context 'with parent' do
      shared_examples 'correct behavior with parent' do
        it { is_expected.to be_valid }

        describe 'parent' do
          subject { super().parent }

          it { is_expected.to eq parent }

          describe 'children' do
            subject { super().children }

            let!(:additional_procedure) do
              described_class.create(name: 'Gastroscopy', parent: parent)
            end

            it { is_expected.to contain_exactly procedure, additional_procedure }
          end
        end
      end

      context 'when parent is Category' do
        let(:parent) { category }

        include_examples 'correct behavior with parent'
      end

      context 'when parent is Procedure' do
        let(:parent) { described_class.create(name: 'Endoscopy', parent: category) }

        include_examples 'correct behavior with parent'
      end
    end
  end

  describe '.destroy' do
    subject(:destroy) { procedure.destroy }

    let!(:procedure) do
      described_class.create(name: 'Endoscopy', parent: category, children: children)
    end

    context 'without children' do
      let(:children) { [] }

      it { expect { destroy }.to change(described_class, :count).by(-1) }
    end

    context 'with children' do
      let(:children) do
        [
          described_class.new(name: 'Colonoscopy')
        ]
      end

      it { expect { destroy }.not_to change(described_class, :count) }
    end
  end
end
