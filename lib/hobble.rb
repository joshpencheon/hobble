%w{ collection scheduler }.each do |file|
  require File.expand_path('../hobble/' + file,  __FILE__)
end

# Provides a way to schedule items in an
# order that is deemed fair.
#
# schedule = Hobble.schedule({
#   jack: [:task1, :task2],
#   john: [:task1, :task2, :task3]
# })
#
# schedule.run do |name, tasks|
#   Task.process(tasks.shift, for: name)
# end
#
module Hobble
  # Returns a new scheduler for the
  # given grouped items.
  def self.schedule(*groups, &block)
    Hobble::Scheduler.new(*groups, &block)
  end
end
