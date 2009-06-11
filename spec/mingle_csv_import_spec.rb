require File.dirname(__FILE__) + '/spec_helper.rb'
require 'ostruct'

describe PivotalImport::MingleCsvImport do

  before :each do
    @mci = PivotalImport::MingleCsvImport.new
  end

  it "find this spec in spec directory" do
    @mci.header.should == "Name\tDescription\tType\tActual Time Worked\tAssignee\tCategory\tCompleted\tCurrent Estimate\tDate Staged\tOriginal Estimate\tPivotal Story\tPriority\tRemaining Time\tSkip cucumber test\tStarted Status\tIteration Tree\tIteration\tStory\tTask\tRelease Tree\tRelease Tree - Release\tTask Tree\tTask Tree - Story\tCurrent Iteration Breakdown\tCurrent Iteration Breakdown - Story\tCurrent Iteration Breakdown - Defect\thours worked\tStory Points\ttime remaining\tTags"

  end

  it "should generate entry for something" do
    pivotal_story = OpenStruct.new(
                                   "name"=>"Email final formatting tweaks",
                                   "current_state"=>"started",
                                   "iteration" => OpenStruct.new( :number => 2,
                                                                  :finish => Time.parse( "6/15/2009"),
                                                                  :start => Time.parse( "6/08/2009")),
                                   :url => "http://google.com",
                                   :story_type => "feature",
                                   :description => "My Description",
                                   :estimate => 8
                                   )
    @mci.entry_for( pivotal_story).should ==  "Email final formatting tweaks\tMy Description\t\t\t\t\t\t8\t\t8\thttp://google.com\t\t\t\t\t\tIteration: 6/12/2009\t\t\t\t\t\t\t\t\t\t\t\t\t"
  end

  it "should generate iteration" do
    @mci.mingle_iteration_name( OpenStruct.new( :number => 2,
                                                :finish => Time.parse( "6/15/2009"),
                                                :start => Time.parse( "6/08/2009"))).should == "Iteration: 6/12/2009"
  end

  it "should create stories" do
    stories = [
               OpenStruct.new(
                              "name"=>"Story 1",
                              "current_state"=>"started",
                              "iteration" => OpenStruct.new( :number => 2,
                                                             :finish => Time.parse( "6/15/2009"),
                                                             :start => Time.parse( "6/08/2009")),
                              :url => "http://google.com",
                              :story_type => "feature",
                              :description => "This is story 1",
                              :estimate => 8
                              ),
               OpenStruct.new(
                              "name"=>"Story 1",
                              "current_state"=>"started",
                              "iteration" => OpenStruct.new( :number => 2,
                                                             :finish => Time.parse( "6/15/2009"),
                                                             :start => Time.parse( "6/08/2009")),
                              :url => "http://google.com",
                              :story_type => "feature",
                              :description => "This is story 1",
                              :estimate => 8
                              )
              ]
    @mci.generate_csv( stories).should == [ @mci.header, @mci.entry_for( stories[0]), @mci.entry_for( stories[1])].join( "\n")

  end

end
