module MockleyCrew
  class Sqlite3
    class << self
      def full_process
        sqlite3 = `which sqlite3`
        puts "\n\n\nSQLITE3: #{sqlite3}\n\n\n"
        if sqlite3 == ""
          install_sqlite3
        end
        full_gem_install
      end

      attr_accessor :current_location

      def current_location
        @current_location ||= `pwd`[0..-2]
      end

      def sqlite3_url
        "https://www.sqlite.org/2018/sqlite-autoconf-3230100.tar.gz"
      end

      def safe_root
        Rails.root.to_s.gsub(" ", "\\ ")
      end

      def prepare_folders
        system("mkdir -p #{safe_root}/vendor/sqlite3")
        system("mkdir -p #{safe_root}/vendor/gems/sqlite3")
        system("cd #{safe_root}/vendor; rm sqlite-autoconf-3230100.tar.gz")
      end

      def download_sqlite3
        system("cd #{safe_root}/vendor; wget #{sqlite3_url}")
        system("cd #{safe_root}/vendor; tar zxf sqlite-autoconf-3230100.tar.gz")
      end

      def make_install_sqlite3
        system("cd #{safe_root}/vendor/sqlite-autoconf-3230100; ./configure --prefix=#{safe_root}/vendor/sqlite3")
        system("cd #{safe_root}/vendor/sqlite-autoconf-3230100; make")
        system("cd #{safe_root}/vendor/sqlite-autoconf-3230100; make install")
      end

      def install_sqlite3
        prepare_folders
        download_sqlite3
        make_install_sqlite3
      end

      def full_gem_install
        install_sqlite3_gem
        load_sqlite3_gem
        hack_active_record
      end

      def install_sqlite3_gem
        system("gem install -v 1.3.13 --install-dir #{Rails.root}/vendor/gems/sqlite3/ sqlite3 -- --with-sqlite3-dir=#{Rails.root}/vendor/sqlite3")
      end

      def load_sqlite3_gem
        $: << "#{Rails.root}/vendor/gems/sqlite3/gems/sqlite3-1.3.13/lib/"
        require 'sqlite3'
      end

      def hack_active_record
        file_path = active_record_path + "/active_record/connection_adapters/sqlite3_adapter.rb"
        file_contents = File.read(file_path)
        new_contents = file_contents.gsub(/gem \"sqlite3\".*$/, "")

        write_to_file(file_path, new_contents)
        load_active_record_sqlite3_adapter
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
    end
  end
end