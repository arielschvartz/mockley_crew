require 'rails_helper'

RSpec.describe MockleyCrew::Database::DataController, type: :controller do
  routes { MockleyCrew::Engine.routes }
  before(:each) do
    @database = MockleyCrew::Database.create
  end

  after(:each) do
    @database.destroy
  end

  context "POST CREATE" do
    [
      [{"teste" => 1}],
      [{"teste" => 1}, {"teste1" => 1}],
      [{"teste" => 1, "teste1" => 1}],
      [1, 2, 3],
      ["1", "2", "3"],
      { 1 => 1, 2 => 2 },
      1,
      "teste"
    ].each do |structure|
      describe "with the body structure #{structure}" do
        before(:each) do
          create_data_request(structure)
        end

        it "should show the correct resposne" do
          expect(formatted_response).to eq({
            "success" => false,
            "message" => "Invalid body structure"
          })
          expect(response.code.to_i).to eq(400)
        end
      end
    end

    [
      [{"factory" => "user3"}, {"factory" => "user2"}],
      [{"factory" => "user3"}]
    ].each do |structure|
      describe "with the body structure #{structure}" do
        before(:each) do
          create_data_request(structure)
        end

        it "should show the correct resposne" do
          expect(formatted_response).to eq({
            "success" => false,
            "message" => "Invalid Factory",
            "detailed_error" => "MockleyCrew::Errors::InvalidFactoryError"
          })
          expect(response.code.to_i).to eq(400)
        end
      end
    end

  #   describe "when creating a valid database" do
  #     it "should add a database file" do
  #       expect {
  #         create_database_request
  #       }.to change {
  #         Dir["#{mockley_crew_databases_path}*.db"].length
  #       }.by(1)
  #     end
  #   end

  #   describe "when creating a valid database" do
  #     before(:each) do
  #       create_database_request
  #     end

  #     it 'should respond the created status' do
  #       expect(response).to have_http_status(:created)
  #     end

  #     it 'should respond a well formatted json' do
  #       expect(formatted_response).to have_key("success")
  #       expect(formatted_response["success"]).to be true
  #     end

  #     it 'should respond a correct header' do
  #       expect(response.headers).to have_key(MockleyCrew.configuration.crew_header)
  #       expect(response.headers[MockleyCrew.configuration.crew_header]).to eq(@db_name)
  #     end
  #   end
  end

  def create_data_request body = {}, headers = {}
    headers.reverse_merge!(
      MockleyCrew.configuration.crew_header => @database.filename
    )
    request.headers.merge! headers

    post :create, params: { "_json" => body }
  end
end