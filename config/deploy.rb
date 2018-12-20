# config valid only for current version of Capistrano
# lock "3.7.1"

set :rails_env,   "production"

set :migration_role, :app
set :assets_role, [:web, :app, :worker]

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :linked_files is []
append :linked_files, "config/database.yml", "config/application.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

##### Need change to your own configs #####
ARCHIVE1 = "192.168.112.109"
ARCHIVE2 = "192.168.112.87"
ARCHIVE3 = "192.168.112.93"
#ARCHIVE1 = "archive1.wescompapers.com"
#ARCHIVE2 = "archive2.wescompapers.com"
#ARCHIVE3 = "archive3.wescompapers.com"
role :web, ARCHIVE1
role :app, ARCHIVE1
role :app, ARCHIVE2, :solr => true
role :db,  ARCHIVE3, :primary => true
#server 'wescomarchive.com', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url, "git@github.com:wescom/Wescom-Archive.git"
set :application, "wescomarchive"

# Settings for Git
set :scm_username,    "wescomarchive"     # Git user
set :scm_passphrase,  "Go2cmdarchive"     # Git password

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/u/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
#set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
#set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
#set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
# 
namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:web) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end
  
  desc "Upload files not included in GitHub repository due to security"
  before :deploy, :upload_files do
    on roles(:all) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(File.read("config/database.yml")), "#{shared_path}/config/database.yml"
      upload! StringIO.new(File.read("config/application.yml")), "#{shared_path}/config/application.yml"
    end
  end

  desc "Update links"
  after :finished, :update_links do
    on roles(:all) do
      execute "rm -rf #{release_path}/solr #{release_path}/log #{release_path}/public/system #{release_path}/tmp/pids"
#
# TURN BACK ON WHEN READY TO BE LIVE
#      execute "ln -s /WescomArchive/solr #{release_path}/solr"
      execute "ln -s #{shared_path}/solr #{release_path}/solr"
#
      execute "mkdir -p #{release_path}/public && ln -s #{shared_path}/public/system #{release_path}/public/system"
      #execute "ln -s /WescomArchive/db_images #{shared_path}/public/system/db_images && ln -s /WescomArchive/pdf_images #{shared_path}/public/system/pdf_images"
      execute "ln -s #{shared_path}/banner_images #{release_path}/public/images/banner_images"
      execute "ln -s #{shared_path}/site_images #{release_path}/public/images/site_images"
      execute "ln -s #{shared_path}/log #{release_path}/log"
    end
  end
  
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma