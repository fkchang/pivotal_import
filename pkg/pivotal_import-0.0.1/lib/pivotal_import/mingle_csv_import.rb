require 'rubygems'
require 'activesupport'

module PivotalImport
  class MingleCsvImport
    @@fields = [
                "Name",
                "Description",
                "Type",
                "Actual Time Worked",
                "Assignee",
                "Category",
                "Completed",
                "Current Estimate",
                "Date Staged",
                "Original Estimate",
                "Pivotal Story",
                "Priority",
                "Remaining Time",
                "Skip cucumber test",
                "Started Status",
                "Iteration Tree",
                "Iteration",
                "Story",
                "Task",
                "Release Tree",
                "Release Tree - Release",
                "Task Tree",
                "Task Tree - Story",
                "Current Iteration Breakdown",
                "Current Iteration Breakdown - Story",
                "Current Iteration Breakdown - Defect",
                "hours worked",
                "Story Points",
                "time remaining",
                "Tags"
               ]
    def header
      @@fields.join("\t")
    end

    def entry_for( pivotal_story)
      p pivotal_story
      values = { }
      values["Name"] = pivotal_story.name
      values["Type"] = "Story"
      values["Pivotal Story"] = pivotal_story.url
      desc = pivotal_story.description ? pivotal_story.description.gsub( /"/, "'") : ""
      values["Description"] = "\"#{desc}\""
      estimate = pivotal_story.estimate > -1 ? pivotal_story.estimate : 1
      values["Current Estimate"] = estimate
      values["Original Estimate"] = estimate
      values["Iteration"] = mingle_iteration_name( pivotal_story.iteration) if pivotal_story.respond_to?( :iteration)
      entries = []
      @@fields.each { |field|
        entry = nil
        entry = values[field] if values[field]
        puts "#{field} = #{entry}"
        entries << entry
      }
      p entries.join( "\t")
      entries.join( "\t")
    end

    def mingle_iteration_name( pivotal_iteration)
      start = pivotal_iteration.start
      month = start.month
      day = (start + 4.days).day
      year = start.year
      "Iteration: #{month}/#{day}/#{year}"
    end

    def generate_csv( stories)

      entries = stories.map { |story|
        entry_for( story)
      }.unshift( header)
      p entries
      entries.join( "\n")

    end


  end                           # MingleCsvImport


end                             # PivotalImport
