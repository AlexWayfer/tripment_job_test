# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Procedure, type: :model do
  let(:category) { Category.new(name: 'Diagnostic') }

  describe '.create' do
    subject(:procedure) do
      described_class.create(name: 'Colonoscopy', category: category, parent: parent)
    end

    let(:parent) { described_class.create(name: 'Endoscopy') }

    context 'without category' do
      let(:category) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'with category' do
      ## defined at the top

      context 'without parent' do
        let(:parent) { nil }

        it { is_expected.to be_valid }

        describe 'parent' do
          subject { super().parent }

          it { is_expected.to be_nil }
        end
      end

      context 'with parent' do
        ## defined at the top

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
    end
  end

  describe '.destroy' do
    subject(:destroy) { procedure.destroy }

    let!(:procedure) do
      described_class.create(name: 'Endoscopy', category: category, children: children)
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
