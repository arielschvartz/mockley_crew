require 'rails_helper'

RSpec.describe MockleyCrew::Database do
  subject { MockleyCrew::Database }

  describe "testing the remove_file_by_filename" do
    before(:each) do
      create_dummy_databases 1
      @filename = MockleyCrew.configuration.database_files.first
    end

    it "should remove the database when the remove_file_by_filename method is called" do
      expect {
        subject.remove_file_by_filename(@filename)
      }.to change {
        Dir["#{mockley_crew_databases_path}/*.db"].length
      }.by(-1)
    end
  end

  describe "when there is a database" do
    before(:each) do
      Timecop.freeze
      @database = create_databases(1).first
    end

    after(:each) do
      Timecop.return
    end

    it 'should have the correct name' do
      expect(@database.get_name).to eq("0")
    end

    it 'should have the correct created_at' do
      expect(@database.get_created_at.to_i).to eq(Time.zone.now.to_i)
    end
  end

  describe "testing the initializer" do
    it "should receive the filename variable" do
      expect(MockleyCrew::Database.new(filename: "teste").filename).to eq("teste")
    end

    it "should set the default name if nothing is passed" do
      expect(MockleyCrew::Database.new.filename).not_to be_blank
    end

    describe "the first part of the name shoud be the time now" do
      before(:each) do
        Timecop.freeze
      end

      after(:each) do
        Timecop.return
      end

      it "should be correct" do
        expect(MockleyCrew::Database.new.get_created_at.to_i).to eq(Time.zone.now.to_i)
      end
    end
  end

  describe "testing the full file path method" do
    it "should return the right method" do
      expect(MockleyCrew::Database.new(filename: "teste").full_file_path).to eq(
        "#{mockley_crew_databases_path}teste"
      )
    end
  end

  describe "testing the clean_database_files method" do
    describe "when there are different databases created in different times" do
      before(:each) do
        3.times do
          Timecop.freeze(Time.zone.now + 60.seconds)
          create_dummy_databases 2
        end
      end

      after(:each) do
        Timecop.return
      end

      it "should delete the ones older than 60 seconds by default" do
        expect {
          MockleyCrew::Database.clean_database_files
        }.to change {
          Dir["#{mockley_crew_databases_path}/*.db"].length
        }.by(-4)
      end

      it "should delete the right ones with 120" do
        expect {
          MockleyCrew::Database.clean_database_files(120)
        }.to change {
          Dir["#{mockley_crew_databases_path}/*.db"].length
        }.by(-2)
      end

      it "should delete the right ones with 121" do
        expect {
          MockleyCrew::Database.clean_database_files(121)
        }.not_to change {
          Dir["#{mockley_crew_databases_path}/*.db"].length
        }
      end

      it "should delete the right ones with 0" do
        expect {
          MockleyCrew::Database.clean_database_files(0)
        }.to change {
          Dir["#{mockley_crew_databases_path}/*.db"].length
        }.by(-6)
      end
    end
  end

  describe "the default database" do
    it "should create the correct file" do
      expect {
        MockleyCrew::Database.create_default_database
      }.to change {
        Dir[mockley_crew_default_database_path].length
      }.by(1)
    end

    it "should change the thread count by 1" do
      expect {
        MockleyCrew::Database.create_default_database
      }.to change {
        Thread.list.length
      }.by(1)
    end

    it "should change the thread from mockley_crew_default count by 1" do
      expect {
        MockleyCrew::Database.create_default_database
      }.to change {
        sleep 0.01
        Thread.list.select { |x| x["thread_name"] == "mockley_crew_default" }.length
      }.by(1)
    end

    it "should not change any files when calling the delete default database with no database created" do
      expect {
        MockleyCrew::Database.delete_default_databse
      }.not_to change {
        Dir[mockley_crew_default_database_path].length
      }
    end

    it "should not change any threads when calling the delete default database with no database created" do
      expect {
        MockleyCrew::Database.delete_default_databse
      }.not_to change {
        Thread.list.length
      }
    end

    describe "when the default database already exists" do
      before(:each) do
        MockleyCrew::Database.create_default_database
      end

      it "should to remove 1 file when calling the delete default database" do
        expect {
          MockleyCrew::Database.delete_default_databse
        }.to change {
          Dir[mockley_crew_default_database_path].length
        }.by(-1)
      end

      it "should to remove 1 thread when calling the delete default database" do
        expect {
          MockleyCrew::Database.delete_default_databse
        }.to change {
          sleep 0.01
          Thread.list.length
        }.by(-1)
      end
    end
  end

  describe "when creating a new database" do
    describe "and the default database does not exist" do
      it "should create the default database" do
        expect {
          MockleyCrew::Database.new.save
        }.to change {
          Dir[mockley_crew_default_database_path].length
        }.by(1)
      end

      it "should create a new database" do
        expect {
          MockleyCrew::Database.new.save
        }.to change {
          Dir["#{mockley_crew_databases_path}/*.db"].length
        }.by(1)
      end

      it "should create a new thread" do
        expect {
          MockleyCrew::Database.new.save
        }.to change {
          sleep 0.01
          Thread.list.length
        }.by(1)
      end

      it "should create the default database" do
        expect {
          MockleyCrew::Database.create
        }.to change {
          Dir[mockley_crew_default_database_path].length
        }.by(1)
      end

      it "should create a new database" do
        expect {
          MockleyCrew::Database.create
        }.to change {
          Dir["#{mockley_crew_databases_path}/*.db"].length
        }.by(1)
      end

      it "should create a new thread" do
        expect {
          MockleyCrew::Database.create
        }.to change {
          sleep 0.01
          Thread.list.length
        }.by(1)
      end
    end

    describe "and the default database already exists" do
      before(:each) do
        File.open(mockley_crew_default_database_path, "w+") do |f|
          f.write("teste")
        end
      end

      it "should not create the default database" do
        expect {
          MockleyCrew::Database.new.save
        }.not_to change {
          Dir[mockley_crew_default_database_path].length
        }
      end

      it "should create a new database" do
        expect {
          MockleyCrew::Database.new.save
        }.to change {
          Dir["#{mockley_crew_databases_path}/*.db"].length
        }.by(1)
      end

      it "should have the same content as the default database" do
        db = MockleyCrew::Database.new
        db.save
        expect(File.read("#{mockley_crew_databases_path}#{db.filename}")).to eq("teste")
      end
    end
  end

  describe "when connecting to a database after creating it" do
    before(:each) do
      @database = MockleyCrew::Database.new
      @database.save
    end

    it "should create a thread with the db filename as its name" do
      expect {
        @database.connect
      }.to change {
        Thread.list.select { |t| t["thread_name"] == @database.filename }.length
      }.by(1)
    end

    it "should change the activerecord connection database" do
      expect {
        @database.connect
      }.to change {
        ActiveRecord::Base.connection.instance_variable_get(:@config)[:database]
      }.to("#{mockley_crew_databases_path}#{@database.filename}")
    end

    it "should terminate a thread when calling the terminate_thread method" do
      @database.connect
      expect {
        MockleyCrew::Database.terminate_thread(@database.filename)
      }.to change {
        sleep 0.01
        Thread.list.length
      }.by(-1)
    end

    it "should terminate the correct thread when calling the terminate_thread method" do
      @database.connect
      expect {
        MockleyCrew::Database.terminate_thread(@database.filename)
      }.to change {
        sleep 0.01
        Thread.list.select { |t| t["thread_name"] == @database.filename }.length
      }.by(-1)
    end
  end

  describe "when disconnecting from the database" do
    before(:each) do
      @database = MockleyCrew::Database.new
      @database.save
      @database.connect
    end

    it "should reconnect to the default databasse the connection" do
      expect {
        @database.disconnect
      }.to change {
        ActiveRecord::Base.connection.instance_variable_get(:@config)[:database]
      }.to("#{Rails.root}/db/test.sqlite3")
    end

    it "should not create a new thread" do
      expect {
        @database.disconnect
      }.not_to change {
        Thread.list.length
      }
    end
  end

  describe "testing restore_default_connection method" do
    it "should not create a new thread" do
      expect {
        MockleyCrew::Database.restore_default_connection
      }.not_to change {
        Thread.list.length
      }
    end
  end
end