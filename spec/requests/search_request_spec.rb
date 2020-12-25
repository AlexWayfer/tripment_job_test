# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches', type: :request do
  describe 'GET /' do
    subject { response }

    before do
      system 'rake procedures:fetch'

      get '/search', params: { query: query }
    end

    context 'with query string' do
      ## I found suitable "cell", "neuro"
      ## There are firstly mid-contains procedures in Wiki, and only after start-contains
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

    ## I don't want to write specs for this case,
    ## because there are different behavior for different environments
    ## (correct 400 for production and exception for development and test)
    ## and I don't want to stub different environments here neither write custom JSON errors
    ## (I can, but don't see such point in task and 400 is OK when there is end-point documentation)

    # context 'without query string' do
    #   let(:query) { '' }
    #
    #   it { is_expected.to have_http_status(:bad_request) }
    # end
  end
end
