# grizzled-rails-logger

*Grizzled Rails Logger* is a Ruby gem that provides an add-on for the stock
Rails 3 logger.

The `Grizzled::Rails::Logger` module augments the Rails 3
`ActiveSupport::BufferedLogger` class, providing some additional
capabilities, including:

* Configurable colorized logging (colorized by severity).
* Simple timestamp configuration.
* The ability to include the PID in each message.
* The ability to flatten the log output, removing spurious newlines, so that
  each message occupies only one line.
* An`exception` message that dumps an exception backtrace to the log

# Installation for Rails 3

Add the following to your `Gemfile`, and run `bundle install`:

    gem 'grizzled-rails-logger'

If you want the development version of the gem, use:

    gem 'grizzled-rails-logger', github: 'bmc/grizzled'

This gem is specific to Rails 3, but it should work fine with either
Ruby 1.9 or Ruby 1.8.7.

# Documentation

Complete documentation for this software is available on the
[home page](http://software.clapper.org/grizzled-rails-logger/)
