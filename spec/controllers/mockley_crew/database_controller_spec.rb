require 'rails_helper'

RSpec.describe MockleyCrew::DatabaseController, type: :controller do
  routes { MockleyCrew::Engine.routes }
  after(:all) do
    MockleyCrew::Database.disconnect
  end

  context "POST CREATE" do
    describe "when creating a valid database" do
      it "should add a database file" do
        expect {
          create_database_request
        }.to change {
          Dir["#{mockley_crew_databases_path}*.db"].length
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

  context "DELETE DESTROY" do
    describe "when there is a database" do
      before(:each) do
        create_database_request
      end

      describe "with a valid badge" do
        it "should remove a database file" do
          expect {
            destroy_database_request({
              MockleyCrew.configuration.crew_header => @db_name
            })
          }.to change {
            Dir["#{mockley_crew_databases_path}*.db"].length
          }.by(-1)
        end

        it "should not remove a thread" do
          expect {
            destroy_database_request({
              MockleyCrew.configuration.crew_header => @db_name
            })
          }.not_to change {
            sleep 0.01
            Thread.list.length
          }
        end

        describe "when the database has connected" do
          before(:each) do
            MockleyCrew::Database.new(filename: @db_name).connect
          end

          it "should remove a thread" do
            expect {
              destroy_database_request({
                MockleyCrew.configuration.crew_header => @db_name
              })
            }.to change {
              sleep 0.01
              Thread.list.length
            }.by(-1)
          end
        end
      end

      describe "with a valid badge" do
        before(:each) do
          destroy_database_request({
            MockleyCrew.configuration.crew_header => @db_name
          })
        end

        it 'should respond the success response' do
          expect(response).to have_http_status(200)
        end

        it 'should respond a well formatted json' do
          expect(formatted_response).to have_key("success")
          expect(formatted_response["success"]).to be true
        end

        it 'should respond a correct header' do
          expect(response.headers).not_to have_key(MockleyCrew.configuration.crew_header)
        end
      end
    end

    describe "with no badge" do
      it "should not remove a database file" do
        expect {
          destroy_database_request
        }.not_to change {
         Dir[mockley_crew_databases_path].length
        }
      end

      it "should not remove a thread" do
        expect {
          destroy_database_request
        }.not_to change {
          sleep 0.01
          Thread.list.length
        }
      end
    end

    describe "with no badge" do
      before(:each) do
        destroy_database_request
      end

      it 'should respond the forbidden status' do
        expect(response).to have_http_status(:forbidden)
      end

      it 'should respond a well formatted json' do
        expect(formatted_response).to have_key("success")
        expect(formatted_response["success"]).to be false
        expect(formatted_response).to have_key("error")
      end

      it 'should respond a correct header' do
        expect(response.headers).not_to have_key(MockleyCrew.configuration.crew_header)
      end
    end

    let(:invalid_badge) do
      {
        MockleyCrew.configuration.crew_header => "123_test.db"
      }
    end

    describe "with an invalid badge" do
      it "should not remove a database file" do
        expect {
          destroy_database_request(invalid_badge)
        }.not_to change {
         Dir[mockley_crew_databases_path].length
        }
      end

      it "should not remove a thread" do
        expect {
          destroy_database_request(invalid_badge)
        }.not_to change {
          sleep 0.01
          Thread.list.length
        }
      end
    end

    describe "with an invalid badge" do
      before(:each) do
        destroy_database_request(invalid_badge)
      end

      it 'should respond the forbidden status' do
        expect(response).to have_http_status(:forbidden)
      end

      it 'should respond a well formatted json' do
        expect(formatted_response).to have_key("success")
        expect(formatted_response["success"]).to be false
        expect(formatted_response).to have_key("error")
      end

      it 'should respond a correct header' do
        expect(response.headers).not_to have_key(MockleyCrew.configuration.crew_header)
      end
    end
  end

  def destroy_database_request headers = {}
    request.headers.merge! headers
    delete :destroy
  end
end