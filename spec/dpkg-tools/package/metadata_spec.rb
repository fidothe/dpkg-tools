require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Metadata::Base, "Can generate a debian/* file" do
  it "tries to write a file to the right place" do
    DpkgTools::Package::Metadata::Base.expects(:file_path).with(:stub_gem).returns('a/path/to/debian/control')
    
    DpkgTools::Package::Metadata::Files.expects(:write).with('a/path/to/debian/control', :file_contents)
    
    DpkgTools::Package::Metadata::Base.write(:stub_gem, :file_contents)
  end
  
  it "should be able to construct the correct path for a file" do
    stub_gem = stub('stub DpkgTools::Package::Gem', 
                    :name => 'stub_gem', :version => '1.1.0', 
                    :config_key => ['stub_gem', '1.1.0'])
    stub_config = stub('stub DpkgTools::Package::Config', :debian_path => "a/path/to/debian")
    DpkgTools::Package.expects(:config).with(['stub_gem', '1.1.0']).returns(stub_config)
    
    DpkgTools::Package::Metadata::Base.stubs(:filename).returns('control')
    
    DpkgTools::Package::Metadata::Base.file_path(stub_gem).should == "a/path/to/debian/control"
  end
end

describe DpkgTools::Package::Metadata::Control, "Can generate a debian/control file" do
  it "should return the correct filename" do
    DpkgTools::Package::Metadata::Control.filename.should == 'control'
  end
  
  # it "should create sensible contents for the debian/control file" do
  #   # Again, this is hard to test since I'm just sticking the hacked up version in...
  #   #DpkgTools::Package::Metadata::Control.build(stub_gem).should ==
  #   pending("Need to refactor and expand this some more")
  # end
  
  it "should be able to return a list of source paragraph fields" do
    DpkgTools::Package::Metadata::Control.source_field_names.should be_an_instance_of(Array)
  end
  
  it "should be able to return a list of binary paragraph fields" do
    DpkgTools::Package::Metadata::Control.binary_field_names.should be_an_instance_of(Array)
  end
  
  it "should be able to build and write the debian/control file" do
    DpkgTools::Package::Metadata::Control.expects(:build).with(:gem).returns(:file_content)
    DpkgTools::Package::Metadata::Control.expects(:write).with(:gem, :file_content)
    
    DpkgTools::Package::Metadata::Control.generate(:gem)
  end
end

describe DpkgTools::Package::Metadata::Copyright, "Can generate a debian/copyright file" do
  it "should return the correct filename" do
    DpkgTools::Package::Metadata::Copyright.filename.should == 'copyright'
  end
  
  # it "should create sensible contents for the debian/copyright file" do
  #   # Again, this is hard to test since I'm just sticking the hacked up version in...
  #   #DpkgTools::Package::Metadata::Control.build(stub_gem).should ==
  #   pending("Need to refactor and expand this some more")
  # end
end

describe DpkgTools::Package::Metadata::Changelog, "Can generate a debian/changelog file" do
  it "should return the correct filename" do
    DpkgTools::Package::Metadata::Changelog.filename.should == 'changelog'
  end
  
  # it "should create sensible contents for the debian/changelog file" do
  #   # Again, this is hard to test since I'm just sticking the hacked up version in...
  #   #DpkgTools::Package::Metadata::Control.build(stub_gem).should ==
  #   pending("Need to refactor and expand this some more")
  # end
end

describe DpkgTools::Package::Metadata::Rules, "Can generate a debian/rules file" do
  it "should return the correct filename" do
    DpkgTools::Package::Metadata::Rules.filename.should == 'rules'
  end
  
  it "should write an executable for debian/rules" do
    DpkgTools::Package::Metadata::Rules.expects(:file_path).with(:stub_gem).returns('a/path/to/debian/rules')
    
    DpkgTools::Package::Metadata::Files.expects(:write_executable).with("a/path/to/debian/rules", :file_contents)
    
    DpkgTools::Package::Metadata::Rules.write(:stub_gem, :file_contents)
  end
  
  # it "should create sensible contents for the debian/rules file" do
  #   # Again, this is hard to test since I'm just sticking the hacked up version in...
  #   #DpkgTools::Package::Metadata::Control.build(stub_gem).should ==
  #   pending("Need to refactor and expand this some more")
  # end
end

describe DpkgTools::Package::Metadata::Rakefile, "Can generate a the Rakefile for package build" do
  it "should return the correct filename" do
    DpkgTools::Package::Metadata::Rakefile.filename.should == 'Rakefile'
  end
  
  
end

describe DpkgTools::Package::Metadata::Files do
  it "should be able to make the debian dir" do
    Dir.expects(:mkdir).with('a_path/debian')
    File.stubs(:exists?).with('a_path/debian').returns(false)
    
    DpkgTools::Package::Metadata::Files.check_debian_dir("a_path/debian")
  end
  
  it "should be able to write a file in the debian dir" do
    DpkgTools::Package::Metadata::Files.expects(:check_debian_dir).with("a_path/debian")
    mock_file = mock('Mock file')
    mock_file.expects(:write).with('file contents')
    File.expects(:open).with('a_path/debian/filename', 'w').yields(mock_file)
    
    DpkgTools::Package::Metadata::Files.write("a_path/debian/filename", 'file contents')
  end
  
  it "should be able to write an executable file in the debian dir" do
    DpkgTools::Package::Metadata::Files.expects(:write).with("a_path/debian/rules", 'file contents')
    File.expects(:chmod).with(0755, "a_path/debian/rules")
    DpkgTools::Package::Metadata::Files.write_executable("a_path/debian/rules", 'file contents')
  end
end

describe DpkgTools::Package::Metadata, ".write_control_files" do
  it "should be able to construct and write all the control files" do
    DpkgTools::Package::Metadata::Control.expects(:generate).with(:gem)
    DpkgTools::Package::Metadata::Copyright.expects(:generate).with(:gem)
    DpkgTools::Package::Metadata::Changelog.expects(:generate).with(:gem)
    DpkgTools::Package::Metadata::Rules.expects(:generate).with(:gem)
    DpkgTools::Package::Metadata::Rakefile.expects(:generate).with(:gem)
    
    DpkgTools::Package::Metadata.write_control_files(:gem)
  end
end