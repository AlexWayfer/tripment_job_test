# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches', type: :request do
  describe 'GET /' do
    subject { response }

    before { get '/search' }

    it { is_expected.to have_http_status(:success) }
  end
end
