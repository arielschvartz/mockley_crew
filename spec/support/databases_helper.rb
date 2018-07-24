module DatabasesHelper
  def mockley_crew_base_path
    "#{Rails.root}/db/crew/"
  end

  def mockley_crew_databases_path
    "#{mockley_crew_base_path}databases/"
  end

  def mockley_crew_default_database_path
    "#{mockley_crew_base_path}default_database.db"
  end

  def create_dummy_databases n
    n.times do |i|
      unless File.directory? mockley_crew_databases_path
        FileUtils.mkdir_p(mockley_crew_databases_path)
      end
      FileUtils.touch("#{mockley_crew_databases_path}#{Time.zone.now.to_i}_#{i}.db")
    end
  end

  def create_databases n
    n.times.map do |i|
      unless File.directory? mockley_crew_databases_path
        FileUtils.mkdir_p(mockley_crew_databases_path)
      end
      filename = "#{Time.zone.now.to_i}_#{i}.db"
      FileUtils.touch("#{mockley_crew_databases_path}#{filename}")

      MockleyCrew::Database.new(filename: filename)
    end
  end

  def clear_all_databases
    FileUtils.rm_rf("#{mockley_crew_databases_path}/.", secure: true)
    if File.exists?(mockley_crew_default_database_path)
      File.delete(mockley_crew_default_database_path) 
    end

    Thread.list.select { |t| t["thread_name"] != nil }.each { |t| t.kill }
  end
end