require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::Builder do
  it "should be able to grab all needed config stuff and create a DpkgTools::Package::Rails::Data and a Builder instance" do
    DpkgTools::Package::Rails::Data.expects(:new).with('/path/to/app').returns(:data)
    DpkgTools::Package::Rails::Builder.expects(:new).with(:data).returns(:instance)
    
    DpkgTools::Package::Rails::Builder.from_path('/path/to/app').should == :instance
  end
end

describe DpkgTools::Package::Rails::Builder, "instances" do
  before(:each) do
    @config = DpkgTools::Package::Config.new('rails-app', '1.0.8')
    DpkgTools::Package::Rails::Data.expects(:load_package_data).with('/a/path/to/rails-app/working/dir', 'deb.yml').
      returns({'name' => 'rails-app', 'version' => '1.0.8'})
    DpkgTools::Package::Rails::Data.expects(:load_package_data).with('/a/path/to/rails-app/working/dir', 'mongrel_cluster.yml').
      returns({'port' => '8000', 'servers' => 3})
    @data = DpkgTools::Package::Rails::Data.new('/a/path/to/rails-app/working/dir')
    
    @builder = DpkgTools::Package::Rails::Builder.new(@data)
  end
  
  it "should provide the correct options for DpkgTools::Package::Config " do
    @builder.config_options.should == {:base_path => "/a/path/to/rails-app/working/dir"}
  end
  
  it "should be able to create the needed install dirs" do
    FileUtils.expects(:mkdir_p).with('/a/path/to/rails-app/working/dir/debian/tmp/etc/init.d')
    FileUtils.expects(:mkdir_p).with('/a/path/to/rails-app/working/dir/debian/tmp/etc/apache2/sites-available')
    FileUtils.expects(:mkdir_p).with('/a/path/to/rails-app/working/dir/debian/tmp/var/lib/rails-app-app')
    
    @builder.create_install_dirs
  end
  
  it "should be able to generate a config file from @data and an erb template" do
    File.expects(:read).with('/a/path/to/rails-app/working/dir/config/apache.conf.erb').returns('template')
    
    @builder.expects(:render_template).with('template').returns('conf file')
    
    mock_file = mock('File')
    mock_file.expects(:write).with('conf file')
    File.expects(:open).with('/a/path/to/rails-app/working/dir/debian/tmp/etc/apache2/sites-available/rails-app.conf', 'w').yields(mock_file)
    
    @builder.generate_apache_conf
  end
  
  it "should be able to copy the conf files to the right place" do
    @builder.expects(:generate_apache_conf)
    @builder.expects(:mongrel_cluster_init_script_path).returns('/path/to/mongrel_cluster/gem/resources/mongrel_cluster')
    FileUtils.expects(:cp).with('/path/to/mongrel_cluster/gem/resources/mongrel_cluster', 
                                '/a/path/to/rails-app/working/dir/debian/tmp/etc/init.d/mongrel_cluster')
    @builder.install_package_files
  end
  
  it "should be able to locate the mongrel_cluster init script in the gem..." do
    stub_spec = stub("Gem::Specification", :full_gem_path => "/path/to/mongrel_cluster/gem")
    stub_index = stub("Gem::SourceIndex")
    stub_index.stubs(:find_name).with('mongrel_cluster', [">0"]).returns([stub_spec])
    Gem.expects(:source_index).returns(stub_index)
    
    @builder.mongrel_cluster_init_script_path.should == "/path/to/mongrel_cluster/gem/resources/mongrel_cluster"
  end
end