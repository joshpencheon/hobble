hobble
======

[![Build Status](https://travis-ci.org/joshpencheon/hobble.svg?branch=master)](https://travis-ci.org/joshpencheon/hobble)

Ruby debt-based scheduling implementation.

**Aim:** Schedule a collection of grouped items in a way that is perceived to be fair.

Installation
=====

Hobble is available as a gem, so simply run:

```
gem install hobble
```

Alternatively, you can add `hobble` to your Gemfile:

```ruby
gem 'hobble'
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
@hobble.run do |user, task|
  Task.process(task, for: user)
end
```

Here, internally, each user's queue (a `Hobble::Collection`) maintains
a counter of how much time has been devoted to running that user's tasks.

Processing time is made available to the pending collection with the least
accrued time. The sort is not stable, to encourage variation in the case of a tie.

When there are no matching collections, hobble's work is done!
