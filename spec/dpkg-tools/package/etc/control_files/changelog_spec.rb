require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Etc::ControlFiles::Changelog, "#changelog" do
  before(:each) do
    config = DpkgTools::Package::Config.new('rails-app', '1.0.8')
    stub_data = stub('DpkgTools::Package::Etc::Data', :full_name => 'rails-app-1.0.8', :debian_revision => '1')
    @metadata = DpkgTools::Package::Etc::ControlFiles::Changelog.new(stub_data, config)
  end
  
  it "should be able to generate a changelog" do
    changelog_fixture = {'date' => "2008-04-16T12:00:00+00:00", 
                         'version' => "1.0.1",
                         'changes' => ['Change details']}
    
    @metadata.changelog.should == "rails-app (1.0.1-1) cp-gutsy; urgency=low\n"\
    "  * Change details\n"\
    " -- Matt Patterson <matt@reprocessed.org>  Wed, 16 Apr 2008 12:00:00 -0000\n"
  end
end
