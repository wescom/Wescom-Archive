set :application, "wescomarchive"
set :repository,  "git@github.com:wescom/Wescom-Archive.git"
set :ssh_options, { :forward_agent => true }
set :rails_env,   "production"
set :scm,         :git
set :scm_username,    "wescomarchive"     # Git user
set :scm_passphrase,  "Go2cmdarchive"  # Git password
set :branch,      "origin/master"
#set :deploy_via,  :remote_cache
set :deploy_via,  :copy

set :user,      "shoffmann"  # The server's user for deploys
set :group,     "archive"

require "bundler/capistrano"
require "rvm/capistrano"
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
set :rvm_ruby_string, 'ruby-1.9.3-p194'
set :rvm_bin_path, "/usr/local/rvm/bin"
#set :rvm_type, :system
set :rvm_install_ruby, :install

default_environment["RAILS_ENV"] = 'production'

default_run_options[:pty] =   true

#ARCHIVE1 = "216.228.165.100"
#ARCHIVE2 = "216.228.165.101"
#ARCHIVE3 = "216.228.165.102"
ARCHIVE1 = "archive1.wescompapers.com"
ARCHIVE2 = "archive2.wescompapers.com"
ARCHIVE3 = "archive3.wescompapers.com"

role :web, ARCHIVE1
role :app, ARCHIVE1
role :app, ARCHIVE2, :solr => true
role :db,  ARCHIVE3, :primary => true

namespace :deploy do
  desc "Deploy Wescom Archive"
  task :default do
    update
    restart
  end

  task :update do
    transaction do
      update_code
    end
  end

  desc "Update deployed code"
  task :update_code do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
    finalize_update
  end

  task :finalize_update do
    run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/system #{latest_release}/public/system &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids
    CMD
    #ln -sf /u/apps/wescomarchive/shared/system /u/apps/wescomarchive/current/public/system &&
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :roles => :web do
    run "kill -s USR2 `cat #{shared_path}/pids/unicorn.pid`"
  end

  desc "Start unicorn"
  task :start, :roles => :web do
    run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D"
  end

  desc "Stop unicorn"
  task :stop, :roled => :web do
    run "kill -s QUIT `cat #{shared_path}/pids/unicorn.pid`"
  end 
end

#after 'deploy:update_code' do
#  run_rake "assets:precompile"
#end

def run_rake(cmd)
  run "cd #{current_path}; #{rake} #{cmd}"
end
