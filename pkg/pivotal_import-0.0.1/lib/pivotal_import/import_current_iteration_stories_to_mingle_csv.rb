module PivotalImport

  class ImportCurrentIterationStoriesToMingleCsv
    # does a legitmate dotfile exist?
    def self.have_dotfile?
      if File.exist?( dotfile)
        @dotfile_contents = YAML.load( File.read( dotfile))
        return false unless @dotfile_contents
        @dotfile_contents["api_token"] != nil && @dotfile_contents["project_id"] != nil
      else
        false
      end
    end

    # the location of the dotfile ~/.pivotal_importer
    def self.dotfile
      dotfile = ENV["HOME"] + "/.pivotal_importer"
    end

    # saves the dotfile if the information is different
    def self.save_dotfile( api_token, project_id)
      dotfile_yaml = YAML.dump( { "api_token" => api_token, "project_id" => project_id})
      if  (have_dotfile? && File.read( dotfile) != dotfile_yaml) || !have_dotfile?
        puts "Saving dotfile #{dotfile} for future convenience"
        File.open( dotfile, "w") { |f| f.puts dotfile_yaml}
      end
    end

    # gets api_token and project_id in a loop until the user agrees
    def self.get_pivotal_values
      api_token, project_id = nil, nil
      loop do
        existing_token = api_token ? "#({api_token})" : ""
        print "Please input Pivotal Tracker api_token#{existing_token}: "; $stdout.flush
        api_token = gets.chomp
        existing_project_id = project_id ? "(#{project_id})" : ""
        print "Please input Pivotal Tracker project id#{existing_project_id}: "; $stdout.flush
        project_id = gets.chomp
        print "\napi_token = #{api_token} project id = #{project_id}.\nIs this correct(y/n)?"; $stdout.flush
        if gets =~/^\s*[Yy]\s*$/
          break
        end
      end
      [api_token, project_id]

    end

    # gets info from either asking the user, or a saved dotfile
    def self.import( argv)
      api_token, project_id = nil, nil
      if argv.size == 0
        if have_dotfile?
          api_token = @dotfile_contents["api_token"]
          project_id = @dotfile_contents["project_id"]
        else
          # get dotfile info? or just usage
          api_token, project_id = get_pivotal_values

        end
        # should we support ARGV stuff? mebbe later
      end
      if !api_token.blank? && !project_id.blank?
        Pivotal.token = api_token
        @project = Pivotal::Project.find project_id
        if @project
          save_dotfile( api_token, project_id)
          stories = @project.stories.find_all { |story| story.current?}
          mci = PivotalImport::MingleCsvImport.new
          puts mci.generate_csv( stories)
        end
      end
    end

  end
end
