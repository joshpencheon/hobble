module Hobble
  # Stores both individual items, and a balance of
  # how long they are taking to process.
  class Collection
    attr_reader :name, :items, :debt
    attr_accessor :weight

    def initialize(name, debt = 0, weight = 1)
      self.weight = weight

      @name  = name
      @debt  = debt * weight
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
      @debt += weight * time(&action)
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

    private

    def time(&block)
      t = Time.now
      block.call(name, items)
      Time.now - t
    end
  end
end
