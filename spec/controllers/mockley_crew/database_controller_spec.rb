require 'rails_helper'

RSpec.describe MockleyCrew::DatabaseController, type: :controller do
  routes { MockleyCrew::Engine.routes }

  context "POST CREATE" do
    describe "when creating a valid database" do
      it "should add a database file" do
        expect {
          create_database_request
        }.to change {
          Dir[mockley_crew_default_database_path].length
        }.by(1)
      end
    end

    describe "when creating a valid database" do
      before(:each) do
        create_database_request
      end

      it 'should respond the created status' do
        expect(response).to have_http_status(:created)
      end

      it 'should respond a well formatted json' do
        expect(formatted_response).to have_key("success")
        expect(formatted_response["success"]).to be true
      end

      it 'should respond a correct header' do
        expect(response.headers).to have_key(MockleyCrew.configuration.crew_header)
        expect(response.headers[MockleyCrew.configuration.crew_header]).to eq(@db_name)
      end
    end
  end

  def create_database_request
    post :create
    @db_name = response.headers[MockleyCrew.configuration.crew_header]
  end
end