# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches', type: :request do
  describe 'GET /' do
    subject { response }

    before do
      system 'rake procedures:fetch'

      get '/search', params: { query: query }
    end

    ## cell, neuro
    let(:query) { 'neuro' }

    it { is_expected.to have_http_status(:success) }

    describe 'body' do
      subject { JSON.parse(super().body) }

      let(:expected_procedures) do
        [
          include('name' => 'Neuroimaging'),
          include('name' => 'Electroneuronography')
        ]
      end

      it { is_expected.to match expected_procedures }
    end
  end
end
