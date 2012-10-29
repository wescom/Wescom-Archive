env = ENV["RAILS_ENV"] || "development"

worker_processes 2
preload_app true
timeout 60

listen 6000

pid "/u/apps/wescomarchive/shared/pids/unicorn.pid"

if env == "production"
  working_directory "/u/apps/wescomarchive/current"
  shared_directory = "/u/apps/wescomarchive/shared"

  stderr_path "#{shared_directory}/log/unicorn.stderr.log"
  stdout_path "#{shared_directory}/log/unicorn.stdout.log"
end


before_fork do |server, worker|
  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid = "/u/apps/wescomarchive/shared/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined? ActiveRecord::Base
    ActiveRecord::Base.establish_connection
  end
end
