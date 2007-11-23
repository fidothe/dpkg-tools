require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::ControlFiles::Rakefile, "generating the debian/control file" do
  it "should return the correct filename" do
    DpkgTools::Package::ControlFiles::Rakefile.filename.should be_nil
  end
  
  it "should return the correct formatter class" do
    DpkgTools::Package::ControlFiles::Rakefile.formatter_class.
      should == DpkgTools::Package::ControlFiles::RakefileFormatter
  end
end

describe DpkgTools::Package::ControlFiles::Rakefile, "instances" do
  it "should generate the correct path" do
    data = mock('DpkgTools::Package::Data')
    data.expects(:rakefile_location).returns([:base_path, 'Rakefile'])
    config = mock('DpkgTools::Package::Config')
    config.expects(:base_path).returns('/a/path/to')
    
    control_file = DpkgTools::Package::ControlFiles::Rakefile.new(data, config)
    control_file.file_path.should == '/a/path/to/Rakefile'
  end
end

describe DpkgTools::Package::ControlFiles::RakefileFormatter, "Can generate a debian/copyright file" do
  before(:each) do
    @metadata = mock('package metadata object')
    @metadata.expects(:rakefile).returns("Rakefile")
    
    @formatter = DpkgTools::Package::ControlFiles::RakefileFormatter.new(@metadata)
  end
  
  it "should grab the license_file from the metadata object" do
    @formatter.build.should == "Rakefile"
  end
end
