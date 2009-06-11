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
      values = { }
      values["Name"] = pivotal_story.name
      values["Pivotal Story"] = pivotal_story.url
      values["Description"] = pivotal_story.description
      values["Current Estimate"] = pivotal_story.estimate
      values["Original Estimate"] = pivotal_story.estimate
      values["Iteration"] = mingle_iteration_name( pivotal_story.iteration)
      entries = []
      @@fields.each { |field|
        entry = nil
        entry = values[field] if values[field]
        entries << entry
      }
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
      stories.map { |story| entry_for( story)}.unshift( header).join( "\n")
    end


  end                           # MingleCsvImport


end                             # PivotalImport
