worker_processes 2
working_directory "/u/apps/wescomarchive/current"

preload_app true
timeout 60

listen 6000

pid "/u/apps/wescomarchive/current/tmp/pids/unicorn.pid"

stderr_path "/u/apps/wescomarchive/current/log/unicorn.stderr.log"
stdout_path "/u/apps/wescomarchive/current/log/unicorn.stdout.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
