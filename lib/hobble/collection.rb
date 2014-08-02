module Hobble
  # Stores both individual items, and a balance of
  # how long they are taking to process.
  class Collection
    attr_reader :name, :items, :debt

    def initialize(name, debt = 0)
      @name  = name
      @debt  = debt
      @items = []
    end

    # Add `items' to this collection.
    def add(items)
      @items.concat(items)
    end

    # Wipe items, but doesn't clear
    # the debt accrued already.
    def clear!
      @items.replace([])
    end

    # Execute the given `action' in
    # the account of this collection.
    def clock(&action)
      t = Time.now
      action.call(name, items)
      @debt += (Time.now - t)
    end

    # Worth giving this collection a go?
    def ready?
      items.length > 0
    end

    # Compare by debt. If equal, swap round to
    # reduce freqency of repeated scheduling.
    def <=>(other)
      value = debt <=> other.debt
      value == 0 ? 1 : value
    end
  end
end
