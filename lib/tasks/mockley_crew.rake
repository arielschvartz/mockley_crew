namespace :mockley_crew do
  desc "Clear the mockley crew created database files"
  task :clear do
    MockleyCrew::Database.clean_database_files(0)
  end
end

# require 'thor'
# require 'mockley_crew'

# module MockleyCrew
#   class CLI < Thor

#     desc "clear", "Clear the mockley crew SQLite3 created database files"
#     def clear
#       MockleyCrew.
#       puts "Clearing"
#     end

#   end
# end