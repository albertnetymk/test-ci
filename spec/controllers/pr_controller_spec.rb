require 'rails_helper'

RSpec.describe PrController, type: :controller do

  describe "GET #event_handler" do
    it "returns http success" do
      get :event_handler
      expect(response).to have_http_status(:success)
    end
  end

end
