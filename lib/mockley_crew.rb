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
    attr_accessor :sqlite3_loaded
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
    return if self.sqlite3_loaded == true

    $: << "#{root}/vendor/gems/sqlite3/gems/sqlite3-1.3.13/lib/"
    require 'sqlite3'
    require 'active_record/connection_adapters/sqlite3_adapter'
    self.sqlite3_loaded = true
  end

  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.activated?
    ActiveRecord::Base.connection.instance_variable_get(:@config)[:database].split("/")[0..-2].join("/") == configuration.database_files_path.gsub(/\/$/, "")
  end
end
