# extend the activeresource based one from pivotal-tracker-api
require 'rubygems'
require 'pivotal_tracker_api'
module Pivotal
  class Story
    def current?(today = Date.today)
      if respond_to? :iteration
        !iteration.nil? && iteration.start <= today.to_time && iteration.finish >= today.to_time
      else
        false
      end

    end
  end
end
