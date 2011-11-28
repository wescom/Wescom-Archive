set :application, "wescomarchive"
set :repository,  "git@github.com:wescom/Wescom-Archive.git"
default_run_options[:pty] = true

set :scm, :git

ARCHIVE1 = "216.228.165.100"
ARCHIVE2 = "216.228.165.101"
ARCHIVE3 = "216.228.165.102"

role :web, ARCHIVE1
role :app, ARCHIVE1
role :app, ARCHIVE2, :solr => true
role :db,  ARCHIVE3, :primary => true

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
