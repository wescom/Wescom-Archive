require "bundler/capistrano"

set :application, "wescomarchive"
set :repository,  "git@github.com:wescom/Wescom-Archive.git"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.2-p290@wescomarchive'

set :scm, :git
set :branch, "master"

set :deploy_via, :remote_cache

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
