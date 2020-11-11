hobble [![Build Status](https://github.com/joshpencheon/hobble/workflows/tests/badge.svg)](https://github.com/joshpencheon/hobble/actions?query=workflow%3Atests) [![Gem Version](https://badge.fury.io/rb/hobble.svg)](http://badge.fury.io/rb/hobble)
======

Ruby debt-based scheduling implementation.

**Aim:** Schedule a collection of grouped items in a way that is perceived to be fair.

Installation
=====

Hobble is available as a gem, so simply run:

```
$ gem install hobble
```

Alternatively, you can add `hobble` to your Gemfile:

```ruby
gem 'hobble'
```

Followed by:

```
$ bundle install
```

Usage
=====

```ruby
# Schedule some peoples' tasks:
@hobble = Hobble.schedule({
  jack: [:task1, :task2],
  john: [:task1, :task2, :task3]
})

# Add some more:
@hobble.schedule({
  jill: [:task3, :task1]
})

# Now run them fairly:
@hobble.run do |user, tasks|
  Task.process(tasks.shift, for: user)
end
```

Here, each user's queue (a `Hobble::Collection`) maintains a counter
of how much time has been devoted to running that user's tasks.

Alternatively, you can specify the items using a block, which
is re-evaluated after each item is run:

```ruby
@hobble = Hobble.schedule { Tasks.pending.group_by(&:user) }

# Once a minute, run all pending tasks:
loop do
  puts 'Running all pending tasks...'
  @hobble.run do |user, tasks|
    Task.process(tasks.shift, for: user)
  end

  puts 'Waiting for more tasks...'
  sleep(60)
end
```

Processing time is made available to the pending collection with the least
accrued time. The sort is not stable, to encourage variation in the case of a tie.

When there are no matching collections, hobble's work is done!

TODO
=====

Nothing outstanding.
