require "mockley_crew/engine"
require "mockley_crew/configuration"

require "mockley_crew/database"
require "pry"

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