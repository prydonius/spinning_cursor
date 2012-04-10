# Spinning Cursor

Spinning Cursor is a flexible DSL that allows you to easily produce a
customizable waiting/loading message for your Ruby command line program.

Beautifully keep your users informed with what your program is doing when a
more complex solution, such as a progress bar, doesn't fit your needs.

Inspired by Chris Wanstrath's
[Choice](http://https://github.com/defunkt/choice), Spinning Cursor provides
you with a _sexy_ DSL for easy use of the library.

## Installation

As easy as RubyGems:

```
$ gem install spinning_cursor --pre
```

## Usage

_It's so simple it hurts!_

### Example

```ruby
require 'spinning_cursor' # you'll definitely need this bit

SpinningCursor.start do
  banner "An amazing task is happening"
  type :spinner
  action do
    # Zzz
    sleep 10
  end
  message "Huh?! I'm awake!"
end

# [OUPUT]
# The cursor can't be shown but it would look like this:
#   An amazing task is happening \ <= that's the 'cursor', it animates!
#
# Huh?! I'm awake!
# => {:started=>2012-04-10 17:01:07 +0100,
#     :finished=>2012-04-10 17:01:17 +0100, :elapsed=>10.000513}
```

It's as easy as that!

### Options

* `banner` - This displays before the cursor. Defaults to "Loading".
* `type` - The type of spinner (currently only `:dots` and `:spinner`).
  Defaults to `:spinner`.
* `action` - The stuff you want to do whilst the spinner is spinning.
* `message` - The message you want to show the user once the task is finished.
  Defaults to "Done".

### But the action block would get too messy!

Fear not, lost soul. There are two ways to prevent messy code as a result of
the block.

1. Call a method e.g. `action my_awesome_method`
2. Start and stop the cursor manually

The first option is the simplest, but the second isn't so bad either.
It's pretty simple, just do:

```ruby
SpinningCursor.start do
  banner "Loading"
  type :dots
  message "Done"
end

# Complex code that takes a long time
sleep 20

SpinningCursor.stop
```

**Notice** the absence of the `action` option. The start method will only keep
the cursor running if an `action` block isn't passed into it.

### I want to be able to change the finish message conditionally!

Do you? Well that's easy too (I'm starting to see a pattern here...)!

Use the `set_message` method to change the message during the execution:

```ruby
SpinningCursor.start do
  banner "Calculating your favour colour, please wait"
  type :dots
  action do
    sleep 20
    if you_are_romantic
      SpinningCursor.set_message "Your favourite colour is pink."
    elsif you_are_peaceful
      SpinningCursor.set_message "Your favourite colour is blue."
    else
      SpinningCursor.set_message "Can't figure it out =[!"
    end
  end
end
```

You get the message. (see what I did there?)

### I need to change the banner message during the task

Yay! All you need is the new version of the gem (v1.0.1) and you can change
the banner message in the same way you would the finish message, using
`set_banner`:

```ruby
SpinningCursor.start do
  banner "Stealing your food"
  action do
    sleep 10
    SpinningCursor.set_banner "Now eating your food"
    sleep 10
  end
  message "Thanks for the free food!"
end
```

### Timing the execution

Spinning Cursor will return a hash with the execution times. If an action
block is passed, it will be returned in the `SpinningCursor.start` method.
Otherwise, it will be returned once you call `SpinningCursor.stop`. You can
also get it with `SpinningCursor.get_exec_time`.

The hash contains the following, self-explanatory keys:

* `:started`
* `:finished`
* `:elapsed`

## Contributing to Spinning Cursor

### What to contribute

#### Suggestions

There isn't much this library should do, but a good suggestion is always
welcome. Make sure to use the issue track on GitHub to make suggestions -- and
fork & pull request if you want to implement it yourself, of course.

#### More Cursors!

Spinning Cursor could always use some cooler animated cursors, you can add a
cursor easily by creating a new method in the Cursor class that runs your
custom cursor.

#### Code optimisations

I'm pretty new to Ruby and this is my first attempt at a DSL. If you could
have a look at the source and offer any optimisations I would be greatly
indebted to you. It's a learning experience for me!

### How to contribute

* Check out the latest master to make sure the feature hasn't been implemented
  or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it
  and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want
  to have your own version, or is otherwise necessary, that is fine, but
  please isolate to its own commit so I can cherry-pick around it.

