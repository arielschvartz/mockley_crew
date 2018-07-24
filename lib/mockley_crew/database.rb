module MockleyCrew
  class Database
    class << self
      def connect args = {}
        if args["filename"].present?
          args["database"] = "#{MockleyCrew.configuration.database_files_path}#{args["filename"]}"
        end

        self.commit_transactions

        ActiveRecord::Base.connection_handler.establish_connection({
          adapter: "sqlite3",
          database: args["database"],
          host: args["host"] || File.basename(args["database"], ".*"),
          username: "crew_master",
          password: "crew_man"
        }, {
          thread_name: args["thread_name"] || "mockley_crew"
        })
      end

      def migrate
        ActiveRecord::Migration.verbose = false
        ActiveRecord::Base.connection.migration_context.migrate
        ActiveRecord::Migration.verbose = true
      end

      def disconnect
        self.commit_transactions

        if ActiveRecord::Base.connected?
          ActiveRecord::Base.connection.close
          ActiveRecord::Base.connection.disconnect!

          self.restore_default_connection
        else
          raise "Cannot disconnect. You are already disconnected from the database."
        end
      end

      def restore_default_connection
        ActiveRecord::Base.connection_handler.establish_connection(
          ActiveRecord::Base.configurations[Rails.env], no_reaper: true
        )
      end

      def commit_transactions
        if ActiveRecord::Base.connected?
          if ActiveRecord::Base.connection.transaction_open?
            ActiveRecord::Base.connection.commit_transaction
          end
        else
          raise "Cannot commit transactions. You are disconnected from the database."
        end
      end

      def terminate_thread filename
        Thread.list.select { |t| t["thread_name"] == filename }.first.kill
      end

      def create_default_database
        MockleyCrew::Database.connect("database" => MockleyCrew.configuration.default_database_path)
        MockleyCrew::Database.migrate
      end

      def remove_file_by_filename filename
        File.delete(filename)
      end

      def clean_database_files seconds = 60
        MockleyCrew.configuration.database_files.each do |filename|
          filename_parts = File.basename(filename, ".db").split("_");
          if Time.zone.now.to_i - filename_parts.first.to_i >= seconds or filename_parts.length < 2
            self.remove_file_by_filename(filename)
          end
        end
      end

      def next_name
        "#{Time.zone.now.to_i}_#{generate_unique_code}.db"
      end

      def generate_unique_code
        loop do
          code = SecureRandom.hex(10)
          break code unless MockleyCrew.configuration.database_codes.include?(code)
        end
      end

      def create
        self.new.create
      end
    end

    attr_accessor :filename

    def initialize args = {}
      args.each do |k, v|
        self.send("#{k}=".to_sym, v)
      end

      unless self.filename.present?
        self.filename = self.class.next_name
      end
    end

    def get_name
      File.basename(@filename, ".*").split("_").last
    end

    def get_created_at
      Time.at(File.basename(@filename, ".*").split("_").first.to_i)
    end

    def save
      self.create_database_file unless File.exists?(full_file_path)
    end

    def full_file_path
      "#{MockleyCrew.configuration.database_files_path}#{@filename}"
    end

    def create_database_file
      self.class.create_default_database unless File.exists?(MockleyCrew.configuration.default_database_path)
      
      FileUtils.mkdir_p(File.dirname(full_file_path))
      FileUtils.cp MockleyCrew.configuration.default_database_path, full_file_path
    end

    def connect
      self.class.connect(
        "thread_name" => @filename,
        "filename" => @filename
      )
    end
    alias_method :on, :connect

    def disconnect
      self.class.disconnect
    end
    alias_method :off, :disconnect

    def destroy
      self.disconnect
      self.class.terminate_thread(self.filename)
    end
  end
end