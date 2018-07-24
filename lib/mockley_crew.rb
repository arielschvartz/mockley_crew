require "pry"

require "mockley_crew/engine"
require "mockley_crew/configuration"

require "mockley_crew/errors/connection_not_made"
require "mockley_crew/errors/database_not_found"
require "mockley_crew/errors/database_with_no_name"
require "mockley_crew/errors/invalid_data"
require "mockley_crew/errors/invalid_factory"

require "mockley_crew/database"

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
  end
end