module Hobble
  # Responsible for scheduling a set of collections
  # in a way that is perceived to be fair.
  class Scheduler
    attr_reader :collections

    def initialize(groups = {})
      @collections = []
      schedule(groups)
    end

    # Schedule the given groups, creating
    # or adding to new collections as needed.
    def schedule(groups)
      groups.each do |name, items|
        collection_for(name).add(items)
      end
    end

    # Clears pending jobs from the scheduler,
    # but doesn't wipe accrued debt.
    def clear!
      collections.each(&:clear!)
    end

    # Executes `action' for each job in a sensible
    # order, and finishes when done.
    def run(&action)
      loop { break unless run_once(&action) }
    end

    private

    # Execute `action' for the next ready
    # collection, if there is one.
    def run_once(&action)
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
