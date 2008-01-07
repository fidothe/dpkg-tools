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
      returns({'name' => 'rails-app', 'version' => '1.0.8', 'server_name' => 'rails-app.org'}, 'mongrel_cluster' => {'port' => '8000', 'servers' => 3})
    DpkgTools::Package::Rails::Data.expects(:load_package_data).with('/a/path/to/rails-app/working/dir', 'database.yml').
      returns({'development' => {'database' => 'db_name'}})
    @data = DpkgTools::Package::Rails::Data.new('/a/path/to/rails-app/working/dir')
    
    @builder = DpkgTools::Package::Rails::Builder.new(@data)
  end
  
  it "should provide the correct options for DpkgTools::Package::Config " do
    @builder.config_options.should == {:base_path => "/a/path/to/rails-app/working/dir"}
  end
  
  it "should be able to create the needed install dirs" do
    @builder.expects(:create_dir_if_needed).with('/a/path/to/rails-app/working/dir/debian/tmp/etc/init.d')
    @builder.expects(:create_dir_if_needed).with('/a/path/to/rails-app/working/dir/debian/tmp/etc/apache2/sites-available')
    @builder.expects(:create_dir_if_needed).with('/a/path/to/rails-app/working/dir/debian/tmp/etc/logrotate.d')
    @builder.expects(:create_dir_if_needed).with('/a/path/to/rails-app/working/dir/debian/tmp/var/lib/rails-app')
    @builder.expects(:create_dir_if_needed).with('/a/path/to/rails-app/working/dir/debian/tmp/var/log/rails-app/apache2')
    
    @builder.create_install_dirs
  end
  
  it "should be able to generate a config file from @data, an erb template and a destination path" do
    File.expects(:read).with('template_path').returns('template')
    
    @builder.expects(:render_template).with('template').returns('conf file')
    
    mock_file = mock('File')
    mock_file.expects(:write).with('conf file')
    File.expects(:open).with('target_path', 'w').yields(mock_file)
    
    @builder.generate_conf_file('template_path', 'target_path')
  end
  
  it "should generate all the needed config files" do
    @builder.expects(:generate_conf_file).with('/a/path/to/rails-app/working/dir/config/apache.conf.erb',
                                               '/a/path/to/rails-app/working/dir/debian/tmp/etc/apache2/sites-available/rails-app')
                                               
    @builder.expects(:generate_conf_file).with('/a/path/to/rails-app/working/dir/config/logrotate.conf.erb',
                                               '/a/path/to/rails-app/working/dir/debian/tmp/etc/logrotate.d/rails-app')
                                               
    @builder.expects(:generate_conf_file).with('/a/path/to/rails-app/working/dir/config/mongrel_cluster_init.erb',
                                               '/a/path/to/rails-app/working/dir/debian/tmp/etc/init.d/rails-app')
                                           
    @builder.generate_conf_files
  end
  
  it "should be able to read the public ssh keys in deployers_ssh_keys" do
    @data.stubs(:deployers_ssh_keys_dir).returns('/path/to/keys')
    Dir.stubs(:entries).with('/path/to/keys').returns(['key1', 'key2'])
    File.stubs(:file?).returns(true)
    File.expects(:read).with('/path/to/keys/key1').returns('key1')
    File.expects(:read).with('/path/to/keys/key2').returns('key2')
    
    @builder.read_deployers_ssh_keys.should == ['key1', 'key2']
  end
  
  it "should be able to read the public ssh keys in deployers_ssh_keys, ignoring any directories there" do
    @data.stubs(:deployers_ssh_keys_dir).returns('/path/to/keys')
    Dir.stubs(:entries).with('/path/to/keys').returns(['is_a_dir', 'key1', 'key2'])
    File.stubs(:file?).returns(true)
    File.expects(:file?).with('/path/to/keys/is_a_dir').returns(false)
    File.expects(:read).with('/path/to/keys/key1').returns('key1')
    File.expects(:read).with('/path/to/keys/key2').returns('key2')
    
    @builder.read_deployers_ssh_keys.should == ['key1', 'key2']
  end
  
  it "should be able to write out an authorized_keys file from a list of keys" do
    mock_file = mock('File')
    mock_file.expects(:write).with("key1\nkey2")
    File.expects(:open).with('/a/path/to/rails-app/working/dir/debian/tmp/var/lib/rails-app/.ssh/authorized_keys', 'w').
      yields(mock_file)
    @builder.expects(:sh).with('chmod 600 "/a/path/to/rails-app/working/dir/debian/tmp/var/lib/rails-app/.ssh/authorized_keys"')
    
    @builder.write_authorized_keys(['key1', 'key2'])
  end
  
  it "should be able to generate the authorized_keys file from the public keys in deployers_ssh_keys" do
    @builder.expects(:create_dir_if_needed).with('/a/path/to/rails-app/working/dir/debian/tmp/var/lib/rails-app/.ssh')
    @builder.expects(:sh).with('chmod 700 "/a/path/to/rails-app/working/dir/debian/tmp/var/lib/rails-app/.ssh"')
    
    @builder.expects(:read_deployers_ssh_keys).returns(['key1', 'key2'])
    @builder.expects(:write_authorized_keys).with(['key1', 'key2'])
    
    @builder.generate_authorized_keys
  end
  
  it "should be able to perform all the needed steps to put install the package's files " do
    @builder.expects(:generate_conf_files)
    @builder.expects(:sh).with('chown -R root:root "/a/path/to/rails-app/working/dir/debian/tmp"')
    @builder.expects(:sh).with('chmod 755 "/a/path/to/rails-app/working/dir/debian/tmp/etc/init.d/rails-app"')
    
    @builder.expects(:generate_authorized_keys)
    
    @builder.install_package_files
  end
end