module Hobble
  # Responsible for scheduling a set of collections
  # in a way that is perceived to be fair.
  class Scheduler
    attr_reader :collections

    def initialize(groups = nil, &populator)
      if groups && populator
        raise(ArgumentError, 'specify block or groups, not both!')
      end

      @collections = []
      @populator   = populator
      schedule(groups || {})
    end

    # Schedule the given groups, creating
    # or adding to new collections as needed.
    def schedule(groups)
      groups.each do |name, items|
        collection_for(name).add(items)
      end
    end

    # Allow different collections to accrue
    # debt at different rates.
    def weight!(weightings)
      weightings.each do |name, weight|
        collection_for(name).weight = weight
      end
    end

    # Clears pending jobs from the scheduler,
    # but doesn't wipe accrued debt.
    def clear!
      collections.each(&:clear!)
    end

    # Executes `action' for each job in a sensible
    # order, and finishes when done. An optional
    # argument can be used to limit the number of runs.
    def run(maximum_runs = 0, &action)
      times_run = 0
      loop do
        times_run +=1 if ran = run_once(&action)
        enough_runs = (maximum_runs > 0) && (times_run >= maximum_runs)
        break if enough_runs || !ran
      end
    end

    private

    # Execute `action' for the next ready
    # collection, if there is one.
    def run_once(&action)
      if @populator
        clear!
        schedule(@populator.call)
      end

      collection = next_ready
      collection.clock(&action) if collection
      collection
    end

    # Returns the least-indebted collection
    # that has queued items, or nil.
    def next_ready
      collections.sort.detect(&:ready?)
    end

    # :nodoc:
    def collection_for(name)
      collection = collections.detect { |coll| coll.name == name }

      if collection.nil?
        start_debt = collections.map(&:debt).min || 0
        collection = Hobble::Collection.new(name, start_debt)
        @collections.unshift(collection)
      end

      collection
    end
  end
end
