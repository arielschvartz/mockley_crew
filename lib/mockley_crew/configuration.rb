module MockleyCrew
  class Configuration
    attr_accessor :crew_folder, :factories, :crew_header, :heroku

    def initialize args = {}
      @crew_header = args["crew_header"] || "crew-man-badge"
      @crew_folder = args["crew_folder"] || "#{Rails.root}/db/crew"
      @heroku = args["heroku"] || false
    end

    def default_database_path
      "#{@crew_folder}/default_database.db"
    end

    def database_files_path
      "#{@crew_folder}/databases/"
    end

    def database_files
      Dir["#{database_files_path}*.db"]
    end

    def database_codes
      database_files.map do |filename|
        File.basename(filename, ".db").split("_").last
      end
    end

    def registered_factory? factory_name
      FactoryBot.factories.registered?(factory_name)
    end

    def heroku?
      @heroku == true
    end
  end
end