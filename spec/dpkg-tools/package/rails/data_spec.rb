require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::Data, ".load_package_data" do
  it "should be able to read in the config/*.yml file" do
    File.expects(:exist?).with('base_path/config/deb.yml').returns(true)
    YAML.expects(:load_file).with('base_path/config/deb.yml').returns({"name" => 'rails-app'})
    DpkgTools::Package::Rails::Data.load_package_data('base_path', 'deb.yml').should == {"name" => 'rails-app'}
  end
end

describe DpkgTools::Package::Rails::Data, "base dependencies" do
  it "should return a sensible list of base gem dependencies" do
    DpkgTools::Package::Rails::Data.base_gem_deps.
      should == [{:name => 'rails-rubygem', :requirements => ['>= 1.2.5-1']},
                 {:name => 'rake-rubygem', :requirements => ['>= 0.7.3-1']},
                 {:name => 'mysql-rubygem', :requirements => ['>= 2.7-1']},
                 {:name => 'mongrel-cluster-rubygem', :requirements => ['>= 1.0.1-1']}]
  end
  
  it "should return a sensible list of base package dependencies" do
    DpkgTools::Package::Rails::Data.base_package_deps.
      should == [{:name => 'mysql-client'}, {:name => 'mysql-server'}, {:name => 'apache2'}, 
                 {:name => 'ruby', :requirements => ['>= 1.8.2']}]    
  end
end

describe DpkgTools::Package::Rails::Data, ".new" do
  it "should raise an error without any arguments" do
    lambda { DpkgTools::Package::Gem::Data.new }.should raise_error
  end
  
  it "should take the rails app base path, then read in the config/deb.yml" do
    DpkgTools::Package::Rails::Data.expects(:load_package_data).with('base_path', 'deb.yml').returns({'name' => 'rails-app', 'version' => '1.0.8'})
    DpkgTools::Package::Rails::Data.expects(:load_package_data).with('base_path', 'database.yml').returns({'development' => {'database' => 'db_name'}})
    DpkgTools::Package::Rails::Data.expects(:process_dependencies).with({'name' => 'rails-app', 'version' => '1.0.8'}).returns(:deps)
    DpkgTools::Package::Rails::Data.new('base_path').should be_an_instance_of(DpkgTools::Package::Rails::Data)
  end
end

describe DpkgTools::Package::Rails::Data, "instances" do
  before(:each) do
    @mongrel_cluster_config_data = {'port' => '8000', 'servers' => 3}
    package_data = {'name' => 'rails-app', 'version' => '1.0.8', 'license' => '(c) Matt 4evah', 
                    'summary' => "Matt's great Rails app", 'server_name' => 'test.host', 
                    'server_aliases' => ['www.test.host'],
                    'mongrel_cluster' => @mongrel_cluster_config_data}
    DpkgTools::Package::Rails::Data.stubs(:load_package_data).with('base_path', 'deb.yml').
      returns(package_data)
    @database_configurations = YAML.load_file(File.dirname(__FILE__) + '/../../../fixtures/database.yml')
    DpkgTools::Package::Rails::Data.stubs(:load_package_data).with('base_path', 'database.yml').returns(@database_configurations)
    DpkgTools::Package::Rails::Data.expects(:process_dependencies).with(package_data).returns(:deps)
    @data = DpkgTools::Package::Rails::Data.new('base_path')
  end
  
  it "should provide access to its name" do
    @data.name.should == 'rails-app'
  end
  
  it "should convert the Gem::Version object to a string" do
    @data.version.should == '1.0.8'
  end
  
  it "should provide access to the changelog-derived debian_revision" do
    @data.debian_revision.should == "1"
  end
  
  it "should provide access to the debian architecture name" do
    @data.debian_arch.should == "all"
  end
  
  it "should provide access to its license" do
    @data.license.should == "(c) Matt 4evah"
  end
  
  it "should provide access to its install-time deps" do
    @data.dependencies.should == :deps
  end
  
  it "should provide access to its build-time deps" do
    @data.build_dependencies.should == :deps
  end
  
  it "should provide access to its summary" do
    @data.summary.should == "Matt's great Rails app"
  end
  
  it "should provide access to its 'full_name' equivalent" do
    @data.full_name.should == 'rails-app-1.0.8'
  end
  
  it "should provide access to its base_path" do
    @data.base_path.should == 'base_path'
  end
  
  it "should provide the rakefile_location information so the rakefile can be generated in the right place" do
    @data.rakefile_location.should == [:base_path, 'lib/tasks/dpkg-tools.rake']
  end
  
  it "should provide access to its mongrel starting port" do
    @data.mongrel_cluster_start_port.should == '8000'
  end
  
  it "should provide access to the number of mongrels specified" do
    @data.number_of_mongrels.should == 3
  end
  
  it "should provide access to an array of the port numbers to be used by the mongrels" do
    @data.mongrel_ports.should == ['8000', '8001', '8002']
  end
  
  it "should provide access to the path of the resources dir in the gem" do
    DpkgTools::Package::Rails::Data.resources_path.should == File.expand_path(File.dirname(__FILE__) + '/../../../../resources/rails')
  end
  
  it "should provide access to the target installation path for the app (i.e. /var/lib/blah)" do
    @data.app_install_path.should == '/var/lib/rails-app'
  end
  
  it "should provide access to the server's main DNS name" do
    @data.server_name.should == 'test.host'
  end
  
  it "should provide access to any DNS aliases the server will have" do
    @data.server_aliases.should == ['www.test.host']
  end
  
  it "should provide access to the apps' databases" do
    @data.database_configurations.should == @database_configurations
  end
  
  it "should provide the system user name for the app" do
    @data.username.should == 'rails-app'
  end
  
  it "should provide the path to the cluster's PIDfile dir" do
    @data.pidfile_dir_path.should == '/var/run/rails-app'
  end
  
  it "should provide the path to the logfile dirs" do
    @data.logfile_path.should == '/var/log/rails-app'
  end
  
  it "should provide the path to the cluster's config root in /etc" do
    @data.conf_dir_path.should == '/var/lib/rails-app/current/config'
  end
  
  it "should provide the capistrano application name" do
    @data.application.should == @data.name
  end
  
  it "should provide the name of the user to ssh into servers as" do
    @data.user.should == @data.name
  end
  
  it "should provide the path to the capistrano deploy_to location" do
    @data.deploy_to.should == @data.app_install_path
  end
  
  it "should provide the path to the deployer's ssh keys dir in the package dir" do
    @data.deployers_ssh_keys_dir.should == 'base_path/config/deployers_ssh_keys'
  end
  
  it "should provide access to the init script's path" do
    @data.init_script_path.should == '/etc/init.d/rails-app'
  end
  
  it "should provide access to the app user's .ssh path" do
    @data.dot_ssh_path.should == '/var/lib/rails-app/.ssh'
  end
  
  it "should provide access to the app user's ssh authorized_keys file" do
    @data.authorized_keys_path.should == '/var/lib/rails-app/.ssh/authorized_keys'
  end
  
  it "should provide access to the raw hash for mongrel_cluster data" do
    @data.mongrel_cluster_config_hash.should == @mongrel_cluster_config_data
  end
end