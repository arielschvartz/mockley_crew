require 'rails_helper'

RSpec.describe "mockley_crew:clear" do
  let!(:dirname) { mockley_crew_databases_path }
  include_context "rake"

  before(:each) do
    create_dummy_databases 5
  end
  
  # it "should clear all the databases" do
  #   expect {
  #     subject.invoke
  #   }.to change {
  #     sleep 1
  #     Dir["#{dirname}*.db"].length
  #   }.by(-5)
  # end
end