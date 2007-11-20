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
    @config = DpkgTools::Package::Config.new('rails-app', '1.0.8', :base_path => "/a/path/to/rails-app/working/dir")
    @config.stubs(:root_path).returns("/a/path/to")
    @stub_data = stub("stub DpkgTools::Package::Rails::Data", :name => 'rails-app', :version => '1.0.8', :deb_filename => 'deb_filename',
                 :full_name => 'rails-app-1.0.8', :config_key => ['rails-app', '1.0.8'], :config => @config)
    
    @builder = DpkgTools::Package::Rails::Builder.new(@stub_data)
  end
  
  it "should provide access to @data" do
    @builder.data.should == @stub_data
  end
  
  it "should be able to provide access to its DpkgTools::Package::Config entry" do
    @builder.config.should == @config
  end
  
  it "should be able to create the debian/tmp buildroot dir" do
    Dir.expects(:mkdir).with('/a/path/to/rails-app/working/dir/debian/tmp')
    File.expects(:directory?).with('/a/path/to/rails-app/working/dir/debian/tmp').returns(false)
    
    @builder.create_buildroot
  end
  
  it "should be able to create the needed install dirs" do
    FileUtils.expects(:mkdir_p).with('/a/path/to/rails-app/working/dir/debian/tmp/etc/init.d')
    FileUtils.expects(:mkdir_p).with('/a/path/to/rails-app/working/dir/debian/tmp/etc/apache2/sites-available')
    FileUtils.expects(:mkdir_p).with('/a/path/to/rails-app/working/dir/debian/tmp/var/lib/rails-app-app')
    
    @builder.create_install_dirs
  end
  
  it "should be able to create the buildroot/DEBIAN dir" do
    Dir.expects(:mkdir).with('/a/path/to/rails-app/working/dir/debian/tmp/DEBIAN')
    File.expects(:directory?).with('/a/path/to/rails-app/working/dir/debian/tmp/DEBIAN').returns(false)
    
    @builder.create_DEBIAN_dir
  end
  
  it "should be able to create the DEBIAN/* package metadata files" do
    @builder.expects(:sh).with('dpkg-gencontrol')
    
    @builder.create_control_files
  end
  
  it "should be able to generate the path to the built .deb package" do
    @builder.built_deb_path.should == "/a/path/to/deb_filename"
  end
  
  it "should be able to create the .deb package" do
    @builder.stubs(:built_deb_path).returns('/a/path/to/rails-app-1.0.8-1_all.deb')
    
    @builder.expects(:sh).with('dpkg-deb --build "/a/path/to/rails-app/working/dir/debian/tmp" "/a/path/to/rails-app-1.0.8-1_all.deb"')
    @builder.create_deb
  end
  
  it "should be able to render apache.conf.erb from a hash" do
    mock_struct = mock('OpenStruct')
    mock_struct.expects(:mongrels).returns(['8000'])
    OpenStruct.expects(:new).with(:mongrels => ['8000', '8001', '8002']).returns(mock_struct)
    
    @builder.render_apache_conf("<%= mongrels.inspect %>", {'port' => '8000', 'servers' => 3}).
      should == '["8000"]'
  end
  
  it "should be able to generate an apache config file from mongrel_cluster.yml and apache.conf.erb" do
    YAML.expects(:load_file).with('/a/path/to/rails-app/working/dir/config/mongrel_cluster.yml').returns(:config_hash)
    File.expects(:read).with('/a/path/to/rails-app/working/dir/config/apache.conf.erb').returns('template')
    
    
    @builder.expects(:render_apache_conf).with('template', :config_hash).returns('conf file')
    
    mock_file = mock('File')
    mock_file.expects(:write).with('conf file')
    File.expects(:open).with('/a/path/to/rails-app/working/dir/debian/tmp/etc/apache2/sites-available/rails-app.conf', 'w').yields(mock_file)
    
    @builder.generate_apache_conf
  end
  
  it "should be able to copy the apache conf to the right place" do
    @builder.expects(:generate_apache_conf)
    @builder.expects(:mongrel_cluster_init_script_path).returns('/path/to/mongrel_cluster/gem/resources/mongrel_cluster')
    FileUtils.expects(:cp).with('/path/to/mongrel_cluster/gem/resources/mongrel_cluster', 
                                '/a/path/to/rails-app/working/dir/debian/tmp/etc/init.d/mongrel_cluster')
    @builder.install_conf_files
  end
  
  it "should be able to locate the mongrel_cluster init script in the gem..." do
    stub_spec = stub("Gem::Specification", :full_gem_path => "/path/to/mongrel_cluster/gem")
    stub_index = stub("Gem::SourceIndex")
    stub_index.stubs(:find_name).with('mongrel_cluster', [">0"]).returns([stub_spec])
    Gem.expects(:source_index).returns(stub_index)
    
    @builder.mongrel_cluster_init_script_path.should == "/path/to/mongrel_cluster/gem/resources/mongrel_cluster"
  end
end

describe DpkgTools::Package::Rails::Builder, "#build_package" do
  it "should perform the steps needed to make a .deb and .dsc" do
    builder = DpkgTools::Package::Rails::Builder.new(:data)
    builder.expects(:create_buildroot)
    builder.expects(:create_install_dirs)
    builder.expects(:create_DEBIAN_dir)
    builder.expects(:install_conf_files)
    builder.expects(:create_control_files)
    builder.expects(:create_deb)
    
    builder.build_package
  end
end

describe DpkgTools::Package::Rails::Builder, "#remove_build_products" do
  before(:each) do
    @config = DpkgTools::Package::Config.new('rails-app', '1.0.8')
    @config.stubs(:root_path).returns("a/path/to")
    
    @stub_data = stub("stub DpkgTools::Package::Gem::Data", :name => 'rails-app', :version => '1.0.8', 
                 :full_name => 'rails-app-1.0.8', :config_key => ['rails-app', '1.0.8'], :config => @config)
    
    @builder = DpkgTools::Package::Rails::Builder.new(@stub_data)
  end
  
  it "should only try to remove build products when debian/tmp exists" do
    File.expects(:exists?).with('a/path/to/rails-app-1.0.8/debian/tmp').returns(false)
    FileUtils.expects(:remove_dir).never
    
    @builder.remove_build_products
  end
  
  it "should remove all the build products" do
    File.expects(:exists?).with('a/path/to/rails-app-1.0.8/debian/tmp').returns(true)
    FileUtils.expects(:remove_dir).with('a/path/to/rails-app-1.0.8/debian/tmp')
    
    @builder.remove_build_products
  end
end