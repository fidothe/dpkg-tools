require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Metadata::Base, "Can generate a debian/* file" do
  it "tries to write a file to the right place" do
    DpkgTools::Package::Metadata::Base.expects(:file_path).with(:metadata).returns('a/path/to/debian/control')
    
    DpkgTools::Package::Metadata::Files.expects(:write).with('a/path/to/debian/control', :file_contents)
    
    DpkgTools::Package::Metadata::Base.write(:metadata, :file_contents)
  end
  
  it "should be able to construct the correct path for a file" do
    stub_config = stub('stub DpkgTools::Package::Config', :debian_path => "a/path/to/debian")
    stub_metadata = stub('stub DpkgTools::Package::Gem', 
                    :config => stub_config)
    
    DpkgTools::Package::Metadata::Base.stubs(:filename).returns('control')
    
    DpkgTools::Package::Metadata::Base.file_path(stub_metadata).should == "a/path/to/debian/control"
  end
  
  it "should be able to build and write the debian/control file" do
    DpkgTools::Package::Metadata::Control.expects(:build).with(:metadata).returns(:file_content)
    DpkgTools::Package::Metadata::Control.expects(:write).with(:metadata, :file_content)
    
    DpkgTools::Package::Metadata::Control.generate(:metadata)
  end
end

describe DpkgTools::Package::Metadata::Control, "Can generate a debian/control file" do
  it "should return the correct filename" do
    DpkgTools::Package::Metadata::Control.filename.should == 'control'
  end
  
  it "should be able to return a list of source paragraph fields" do
    DpkgTools::Package::Metadata::Control.source_field_names.should be_an_instance_of(Array)
  end
  
  it "should be able to return a list of binary paragraph fields" do
    DpkgTools::Package::Metadata::Control.binary_field_names.should be_an_instance_of(Array)
  end
  
  it "should be able to map field_names symbols to the .deb format version" do
    DpkgTools::Package::Metadata::Control.field_names_map.should be_an_instance_of(Hash)
  end
  
  it "should be able to turn a list of deps into a correctly formatted string" do
    deps = [{:name => "a-dependency", :requirements => [">= 0.0.0-1"]}, {:name => "another-dep", :requirements => [">= 0", "<= 1"]}]
    DpkgTools::Package::Metadata::Control.send(:deps_string, deps).should == "a-dependency (>= 0.0.0-1), another-dep (>= 0) (<= 1)"
  end
  
  it "should iterate across the control file field names and insert any lines represented by methods in the metadata object" do
    stub_metadata = stub('package metadata object', :source => 'source-package-name', :package => 'binary-package-name')
    
    DpkgTools::Package::Metadata::Control.build(stub_metadata).should == "Source: source-package-name\n\nPackage: binary-package-name\n"
  end
  
  it "should be able to correctly construct a dependencies line" do
    stub_metadata = stub('package metadata object', :depends => [{:name => "dependency", :requirements => [">= 1.0.0-1"]}])
    
    DpkgTools::Package::Metadata::Control.send(:depends_line, :depends, stub_metadata).should == "Depends: dependency (>= 1.0.0-1)"
  end
  
  it "should be able to correctly construct a Maintainer line" do
    stub_metadata = stub('package metadata object', :maintainer => ["Matt Patterson", "matt@reprocessed.org"])
    DpkgTools::Package::Metadata::Control.maintainer(stub_metadata).should == "Maintainer: Matt Patterson <matt@reprocessed.org>"
  end
  
  it "should be able to handle fields which need special processing by calling the local method and handing off the metadata to that" do
    stub_metadata = stub('package metadata object', :depends => [{:name => "dependency", :requirements => [">= 1.0.0-1"]}])
    
    DpkgTools::Package::Metadata::Control.expects(:depends_line).with(:depends, stub_metadata).returns("Here is a depends line")
    
    DpkgTools::Package::Metadata::Control.build(stub_metadata).should == "\nHere is a depends line\n"
  end
end

describe DpkgTools::Package::Metadata::Copyright, "Can generate a debian/copyright file" do
  it "should return the correct filename" do
    DpkgTools::Package::Metadata::Copyright.filename.should == 'copyright'
  end
  
  it "should grab the license_file from the metadata object" do
    mock_metadata = mock('package metadata object')
    mock_metadata.expects(:license_file).returns("License file")
    
    DpkgTools::Package::Metadata::Copyright.build(mock_metadata).should == "License file"
  end
end

describe DpkgTools::Package::Metadata::Changelog, "Can generate a debian/changelog file" do
  it "should return the correct filename" do
    DpkgTools::Package::Metadata::Changelog.filename.should == 'changelog'
  end
  
  it "should grab the changelog from the metadata object" do
    mock_metadata = mock('package metadata object')
    mock_metadata.expects(:changelog).returns("Changelog file")
    
    DpkgTools::Package::Metadata::Changelog.build(mock_metadata).should == "Changelog file"
  end
end

describe DpkgTools::Package::Metadata::Rules, "Can generate a debian/rules file" do
  it "should return the correct filename" do
    DpkgTools::Package::Metadata::Rules.filename.should == 'rules'
  end
  
  it "should write an executable for debian/rules" do
    DpkgTools::Package::Metadata::Rules.expects(:file_path).with(:metadata).returns('a/path/to/debian/rules')
    
    DpkgTools::Package::Metadata::Files.expects(:write_executable).with("a/path/to/debian/rules", :file_contents)
    
    DpkgTools::Package::Metadata::Rules.write(:metadata, :file_contents)
  end
end

describe DpkgTools::Package::Metadata::Rakefile, "Can generate a the Rakefile for package build" do
  it "should be able to construct the correct path for the rakefile" do
    stub_data = stub('stub DpkgTools::Package::Blah::Data', :rakefile_path => "a/path/to/Rakefile")
    stub_metadata = stub('stub DpkgTools::Package::Blah::Metadata', 
                    :data => stub_data)
    
    DpkgTools::Package::Metadata::Rakefile.file_path(stub_metadata).should == "a/path/to/Rakefile"
  end
  
  it "should grab the rakefile from the metadata object" do
    mock_metadata = mock('package metadata object')
    mock_metadata.expects(:rakefile).returns("rakefile")
    
    DpkgTools::Package::Metadata::Rakefile.build(mock_metadata).should == "rakefile"
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
    DpkgTools::Package::Metadata::Control.expects(:generate).with(:metadata)
    DpkgTools::Package::Metadata::Copyright.expects(:generate).with(:metadata)
    DpkgTools::Package::Metadata::Changelog.expects(:generate).with(:metadata)
    DpkgTools::Package::Metadata::Rules.expects(:generate).with(:metadata)
    DpkgTools::Package::Metadata::Rakefile.expects(:generate).with(:metadata)
    
    DpkgTools::Package::Metadata.write_control_files(:metadata)
  end
end