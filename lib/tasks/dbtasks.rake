require 'erb'
require 'zlib'

def find_command(cmd)
  dirs_on_path = ENV['PATH'].to_s.split(File::PATH_SEPARATOR)
  
  alternatives = dirs_on_path.collect { |path| File.join(path, cmd) }
  alternatives += dirs_on_path.collect { |path| File.join(path, cmd + ".exe") } if RUBY_PLATFORM =~ /win32/

  alternatives.detect { |path| File.executable? path } || abort("Couldn't find database client: #{cmd}. Check your $PATH and try again.")
end

namespace :dbtask do
  
  namespace :dump do
    task :download => "dreamhost:get_backup"
    
      
    task :import => ["db:drop", "db:create"] do
      env = ENV['RAILS_ENV'] || 'development'
      unless config = YAML::load(ERB.new(IO.read(RAILS_ROOT + "/config/database.yml")).result)[env]
        abort "No database is configured for the environment '#{env}'"
      end
      dbcommand = find_command("mysql")
      
      args = {
        'host'      => '--host',
        'port'      => '--port',
        'socket'    => '--socket',
        'username'  => '--user',
      }.map { |opt, arg| "#{arg}=#{config[opt]}" if config[opt] }.join(" ")
    
      IO.popen(%Q("#{dbcommand}" #{args} #{config["database"]}), "w") do
        |db|
        dump = Zlib::GzipReader.open("db/latest-dump.gz")
        db.write(dump.read)
      end
    end

    desc "Load the latest database dump into the development database"
    task :load => ["import", "db:migrate"]


    desc "Downloads the latest backup and installs it"
    task :full_restore => [:download, :load]
  end
end