require 'rails_helper'

RSpec.describe MockleyCrew::Configuration do
  describe "getting the default" do
    it "returns the correct configuration values" do
      expect(MockleyCrew.configuration.crew_header).to eq("crew-man-badge")
      expect(MockleyCrew.configuration.crew_folder).to eq("#{Rails.root}/db/crew")
      expect(MockleyCrew.configuration.heroku).to eq(false)
    end
  end

  describe "setting the attributes" do
    before(:each) do
      MockleyCrew.configure do |config|
        config.crew_header = "test_header"
        config.crew_folder = "test_folder"
        config.heroku = true
      end
    end

    after(:each) do
      MockleyCrew.reset_configuration
    end

    it "returns the correct configuration values" do
      expect(MockleyCrew.configuration.crew_header).to eq("test_header")
      expect(MockleyCrew.configuration.crew_folder).to eq("test_folder")
      expect(MockleyCrew.configuration.heroku).to eq(true)
    end

    it "resets the variables on reset" do
      MockleyCrew.reset_configuration
      expect(MockleyCrew.configuration.crew_header).to eq("crew-man-badge")
      expect(MockleyCrew.configuration.crew_folder).to eq("#{Rails.root}/db/crew")
      expect(MockleyCrew.configuration.heroku).to eq(false)
    end
  end

  it "should have the method default_database_path" do
    expect(subject.default_database_path).to eq("#{mockley_crew_base_path}default_database.db")
  end

  it "should have the method database_files_path" do
    expect(subject.database_files_path).to eq(mockley_crew_databases_path)
  end

  describe "When there are 5 database files" do
    before(:each) do
      create_dummy_databases 5
    end

    it "the method database_files should return 5 files" do
      expect(subject.database_files.length).to eq(5)
    end
  end

  describe "When there are 5 database files" do
    before(:each) do
      create_dummy_databases 5
    end

    it "the method database_files should return 5 files" do
      expect(subject.database_codes).to match_array(["0", "1", "2", "3", "4"])
    end
  end

  describe "registered_factory? method" do
    before(:each) do
      FactoryBot.factories.register(:test, "test")
    end

    it "should be returned in the factories method" do
      expect(MockleyCrew.configuration.registered_factory?(:test)).to be(true)
      expect(MockleyCrew.configuration.registered_factory?(:test1)).to be(false)
    end
  end

  # describe "configure heroku" do
  #   before(:each) do
  #     MockleyCrew.sqlite3_loaded = false
  #   end
    
  #   it "should install sqlite3" do
  #     expect {
  #       MockleyCrew.configure do |config|
  #         config.heroku = true
  #       end
  #     }.to change {
  #       MockleyCrew.sqlite3_loaded
  #     }.to(true)
  #   end
  # end

  describe "activated" do
    it "should be false as default" do
      expect(MockleyCrew.activated?).to eq(false)
    end

    describe "when connected" do
      before(:each) do
        @database = MockleyCrew::Database.create
        @database.connect
      end

      it "should be true" do
        expect(MockleyCrew.activated?).to eq(true)
      end

      describe "when disconnected" do
        before(:each) do
          @database.disconnect
        end

        it "should be false" do
          expect(MockleyCrew.activated?).to eq(false)
        end
      end
    end
  end
end