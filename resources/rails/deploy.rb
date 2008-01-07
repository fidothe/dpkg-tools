require 'rubygems'
require 'dpkg-tools'

set :user, DpkgTools::Package::Rails.cap.user
set :application, DpkgTools::Package::Rails.cap.application
set :repository,  "set your repository location here"

set :deploy_via, :copy
set :deploy_to, DpkgTools::Package::Rails.cap.deploy_to

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "your app-server here"
role :web, "your web-server here"
role :db,  "your db-server here", :primary => true

namespace :deploy do
  desc <<-DESC
    Restarts your application. This works by calling the /etc/init.d script for the 
    app, with 'restart' as an option.
    
    This will (and should) be invoked via sudo as the `app' user.
  DESC
  task :restart, :roles => :app, :except => { :no_release => true } do
    sudo "/etc/init.d/#{application} restart"
  end
  
  desc <<-DESC
    Restarts your application. This works by calling the /etc/init.d script for the 
    app, with 'restart' as an option.
  
    This will (and should) be invoked via sudo as the `app' user.
  DESC
  task :start, :roles => :app do
    sudo "/etc/init.d/#{application} start"
  end

  desc <<-DESC
    Restarts your application. This works by calling the /etc/init.d script for the 
    app, with 'restart' as an option.
  
    This will (and should) be invoked via sudo as the `app' user.
  DESC
  task :stop, :roles => :app do
    sudo "/etc/init.d/#{application} stop"
  end
end


