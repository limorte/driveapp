database_yml_path = "config/database.yml"
config = YAML::load(capture("cat #{deploy_to}/shared/#{database_yml_path}"))
adapter = config[rails_env]["postgresql"]
database = config[rails_env]["driveapp_production"]
db_username = config[rails_env]["driveapp"]
host = config[rails_env]["host"]

config = YAML::load(File.open(database_yml_path))
local_rails_env = 'development'
local_adapter = config[local_rails_env]["postgresql"]
local_database = config[local_rails_env]["driveapp_production"]
local_db_username = config[local_rails_env]["drivapp"]

set :timestamp, Time.now.strftime("%Y-%m-%d-%H-%M")
namespace :db do
  desc "upload local database to remote server"
  task :export do
    if adapter == "postgresql"
      run_locally("pg_dump -O #{local_database} > tmp/#{local_database}-#{timestamp}.sql")
      upload "tmp/#{local_database}-#{timestamp}.sql", "#{deploy_to}/shared/database/#{local_database}-#{timestamp}.sql"
      sudo "/etc/init.d/#{unicorn_instance_name} stop"
      run "cd #{deploy_to}/current && RAILS_ENV=production bin/rake db:drop && RAILS_ENV=production bin/rake db:create"
      run "psql -d #{database} -h #{host} -U #{db_username} -f #{deploy_to}/shared/database/#{local_database}-#{timestamp}.sql"
      sudo "/etc/init.d/#{unicorn_instance_name} start"
    else
      puts "Cannot backup, adapter #{adapter} is not implemented for backup yet"
    end
  end
end