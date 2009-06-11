require File.dirname(__FILE__) + '/spec_helper.rb'
include PivotalImport
describe ImportCurrentIterationStoriesToMingleCsv do

  context "dotfiles" do
    before :each do
      @orig_stdout = $stdout
      $stdout = File.open( "/dev/null", "w")
      @tmp_dotfile = "/tmp/tmp_dotfile"
      ImportCurrentIterationStoriesToMingleCsv.stub!( :dotfile).and_return( @tmp_dotfile)
    end

    after :each do
      $stdout = @orig_stdout
    end


    it "should know when there is no dotfile" do

      File.unlink( @tmp_dotfile) if File.exist? @tmp_dotfile
      ImportCurrentIterationStoriesToMingleCsv.have_dotfile?.should == false
    end

    it "should know when the dotfile is empty" do

      File.open( @tmp_dotfile, "w") { |f| #nothing, just want empty file
      }
      ImportCurrentIterationStoriesToMingleCsv.have_dotfile?.should == false
    end
    it "should know when the dotfile is has empty contents for values" do

      File.open( @tmp_dotfile, "w") { |f| f.puts( YAML.dump( { }))}
      ImportCurrentIterationStoriesToMingleCsv.have_dotfile?.should == false
    end

    it "should know when the dotfile is good content for values" do

      File.open( @tmp_dotfile, "w") { |f| f.puts( YAML.dump( { "api_token" => "XXXXYYY23sfa", "project_id" => 23134}))}
      ImportCurrentIterationStoriesToMingleCsv.have_dotfile?.should == true
    end

    it "should write dotfile if it doesn't exist" do
      File.unlink( @tmp_dotfile) if File.exist? @tmp_dotfile
      ImportCurrentIterationStoriesToMingleCsv.save_dotfile( "api_token", "project_id")
      File.read( @tmp_dotfile).should == YAML.dump( { "api_token" => "api_token", "project_id" => "project_id"})
    end

    it "should write dotfile if the values are different" do
      File.open( @tmp_dotfile, "w") { |f| f.puts YAML.dump( { "api_token" => "old_value", "project_id" => "old_package_name"})}
      ImportCurrentIterationStoriesToMingleCsv.save_dotfile( "api_token", "project_id")
      File.read( @tmp_dotfile).should == YAML.dump( { "api_token" => "api_token", "project_id" => "project_id"})
    end

    it "should write dotfile if the values are different" do
      File.open( @tmp_dotfile, "w") { |f| f.puts YAML.dump( { "api_token" => "api_token", "project_id" => "project_id"})}
      File.should_not_receive( "open").with( @tmp_dotfile, "w")
      ImportCurrentIterationStoriesToMingleCsv.save_dotfile( "api_token", "project_id")

    end


  end
  context " get pivotal values " do
    before :each do
      @orig_stdout = $stdout
      $stdout = File.open( "/dev/null", "w")
    end
    after :each do
      $stdout = @orig_stdout
    end

    it "should get pivotal values from user" do
      ImportCurrentIterationStoriesToMingleCsv.should_receive( "gets").and_return( "api_token\n", "project_id\n", "y\n")
      ImportCurrentIterationStoriesToMingleCsv.get_pivotal_values.should == ["api_token", "project_id"]

    end
    it "should get pivotal values from user, asking a second time if they don't like it" do
      ImportCurrentIterationStoriesToMingleCsv.should_receive( "gets").and_return( "bad_token\n", "bad_id\n", "n\n", "api_token\n", "project_id\n", "y\n")
      ImportCurrentIterationStoriesToMingleCsv.get_pivotal_values.should == ["api_token", "project_id"]

    end

  end

  it "should not do import when project can't be found " do
    ImportCurrentIterationStoriesToMingleCsv.stub!( :have_dotfile?).and_return( false)
    ImportCurrentIterationStoriesToMingleCsv.should_receive( :get_pivotal_values).and_return( [nil, nil])
    Pivotal::Project.stub!( :find).and_return( nil)
    ImportCurrentIterationStoriesToMingleCsv.should_not_receive( :save_dotfile)
    PivotalImport::MingleCsvImport.should_not_receive( :new)
    ImportCurrentIterationStoriesToMingleCsv.import( [])
  end

  # ok, this is one long, suck ass, brittle white box spec
  it "should not do import when project can't be found " do
    ImportCurrentIterationStoriesToMingleCsv.stub!( :have_dotfile?).and_return( false)
    ImportCurrentIterationStoriesToMingleCsv.should_receive( :get_pivotal_values).and_return( ["api_token", "project_id"])
    mock_project = mock( "Mock Project")
    mock_story = mock( "Mock story")
    mock_story.should_receive( :current?).and_return( true)
    mock_project.should_receive( :stories).and_return( [mock_story])
    Pivotal::Project.should_receive( :find).with( "project_id").and_return( mock_project)
    ImportCurrentIterationStoriesToMingleCsv.should_receive( :save_dotfile)
    mock_mci = mock( "MingleCsvImport")
    mock_mci.should_receive( :generate_csv).with( [mock_story])
    PivotalImport::MingleCsvImport.should_receive( :new).and_return( mock_mci)
    ImportCurrentIterationStoriesToMingleCsv.import( [])
  end


end
