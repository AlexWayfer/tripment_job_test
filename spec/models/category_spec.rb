# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  describe '.create' do
    subject do
      described_class.create(name: 'Diagnostic')
    end

    it { is_expected.to be_valid }
  end
end
