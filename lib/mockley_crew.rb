require "factory_bot"

require "mockley_crew/engine"
require "mockley_crew/configuration"

require "mockley_crew/errors/connection_not_made"
require "mockley_crew/errors/database_not_found"
require "mockley_crew/errors/database_with_no_name"
require "mockley_crew/errors/invalid_data"
require "mockley_crew/errors/invalid_factory"
require "mockley_crew/errors/invalid_amount"

require "mockley_crew/database"
require "mockley_crew/factory_builder"
require "mockley_crew/data"

require "mockley_crew/mockley_crew_handled"

module MockleyCrew
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset_configuration
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
    if configuration.heroku?
      set_sqlite3
    end
  end

  def self.set_sqlite3
    return if defined?(SQLite3)

    $: << "#{Rails.root}/vendor/gems/sqlite3/gems/sqlite3-1.3.13/lib/"
    require 'sqlite3'
    hack_active_record
  end

  def hack_active_record
      file_path = active_record_path + "/active_record/connection_adapters/sqlite3_adapter.rb"
      file_contents = File.read(file_path)
      new_contents = file_contents.gsub(/gem \"sqlite3\".*$/, "")
       write_to_file(file_path, new_contents)
       require 'active_record/connection_adapters/sqlite3_adapter'
      write_to_file(file_path, file_contents)
    end
     def load_active_record_sqlite3_adapter
      require 'active_record/connection_adapters/sqlite3_adapter'
    end
     def active_record_path
      (`gem which active_record`).split("/")[0..-2].join("/")
    end
     def write_to_file file, contents
      File.open(file, "w+") do |f|
        f.write(contents)
      end
    end

  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.activated?
    ActiveRecord::Base.connection.instance_variable_get(:@config)[:database].split("/")[0..-2].join("/") == configuration.database_files_path.gsub(/\/$/, "")
  end
end
