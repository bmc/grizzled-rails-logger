---
title: Grizzled Rails Logger
layout: withTOC
---

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
* An `exception` message that dumps an exception backtrace to the log

# Installation for Rails 3

Add the following to your `Gemfile`, and run `bundle install`:

{% highlight ruby %}
gem 'grizzled-rails-logger'
{% endhighlight %}

If you want the development version of the gem, use:

{% highlight ruby %}
gem 'grizzled-rails-logger', :git => 'git://github.com/bmc/grizzled-rails-logger.git'
{% endhighlight %}

This gem is specific to Rails 3, but it should work fine with either
Ruby 1.9 or Ruby 1.8.7.

# Configuration

Because *Grizzled Rails Logger* merely adds to the standard Rails logger,
you can continue to all the usual capabilities of the Rails logger (such as,
for instance, tagged logged).

To configure *Grizzled Rails Logger*, add a section like the following to your
`config/application.rb` file, an individual environment file, or an initializer
(e.g., `config/initializers/logging.rb`):

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  # Configuration data goes here
end
{% endhighlight %}

Note that this section stands by itself; it doesn't go inside your
`class Application < Rails::Application` configuration block. For
simplicity and ease of maintenance, I recommend using a separate
initializer file, like `config/initializers/logging.rb`.

If you configure it in `application.rb` or in an initializer file, you don't
need to `require` the module. If you configure it in your
`config/environments/whatever.rb` file, however, you'll also need the
appropriate `require` statement at the top:

{% highlight ruby %}
require 'grizzled/rails/logger'
{% endhighlight %}

The default configuration is equivalent to the following:

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.flatten = true
  cfg.flatten_patterns = [
    /.*/
  ]
  cfg.dont_flatten_patterns = [
  ]
  cfg.format = '[%T] (%S) %P %M'
  cfg.timeformat = '%Y/%m/%d %H:%M:%S'
  cfg.colorize = true
  cfg.colors = {
    :debug => Term::ANSIColor.cyan,
    :warn  => Term::ANSIColor.yellow + Term::ANSIColor.bold,
    :fatal => Term::ANSIColor.red + Term::ANSIColor.bold,
    :error => Term::ANSIColor.red
  }
end
{% endhighlight %}

Each configuration option is described in more detail, below.

## Colorization

By default, *Grizzled Rails Logger* colorizes logging output, using ANSI
terminal escape sequences (as defined by the [term-ansicolor][] gem).

You can disable colorization by setting the `colorize` option to `false`:

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.colorize = false
end
{% endhighlight %}

You can also change the colors associated with each severity. Suppose, for
instance, that you want INFO messages (which normally aren't colorized) to be
white, and you wanted DEBUG messages (which are normally cyan) to be bold blue.
You'd simply reconfigure those values, as shown below:

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.colors[:debug] = Term::ANSIColor.bold + Term::ANSIColor.blue
  cfg.colors[:info] = Term::ANSIColor.white
end
{% endhighlight %}

`Term::ANSIColor` is automatically included for you.

**WARNING:** *Grizzled Rails Logger* does not verify that the values you
store in the color settings are legal ANSI sequences. The following is
perfectly legal, though probably not what you want:

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.colors[:debug] = "red"
end
{% endhighlight %}

With that (erroneous) setting, a debug message that normally looks like this:

    [2012/04/12 14:43:22] (DEBUG) 9816 My debug message

will, instead, look like this:

    red[2012/04/12 14:43:22] (DEBUG) 9816 My debug message

If what you want is this:

<pre style="color:red">
[2012/04/12 14:43:22] (DEBUG) 9816 My debug message
</pre>

use:

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.colors[:debug] = Term::ANSIColor.red
end
{% endhighlight %}

## Exception logging

*Grizzled Rails Logger* adds an `exception()` method, providing an easy way
to dump a rescued exception and its backtrace:

{% highlight ruby %}
begin
  # Some dangerous operation
rescue Exception => ex
  logger.exception("Error while doing dangerous thing", ex)
end
{% endhighlight %}

The method takes three parameters, one of which is optional:

* `message` - a message to be displayed along with the exception. Can be nil,
  but must be supplied.
* `exception` - the exception to be dumped.
* `progname` - program name. Optional; defaults to nil.

The exception is dumped at severity level ERROR.

Regardless of the setting of `flatten` (see below), the exception's backtrace
is always displayed on multiple lines.

## Flattening

The default Rails logger includes lots of newlines in its log messages. For
example:

    [2012/04/12 14:59:48] (INFO) 10102 [659d08c8cbcf3ddf543ca3710cee2771] 

    Started GET "/about" for 127.0.0.1 at 2012-04-12 14:59:48 -0400

*Grizzled Rails Logger* automatically flattens log messages to a single line:

    [2012/04/12 14:59:48] (INFO) 10102 [659d08c8cbcf3ddf543ca3710cee2771] Started GET "/about" for 127.0.0.1 at 2012-04-12 14:59:48 -0400

If you prefer *not* to flatten log messages, disable the `flatten` setting:

{% highlight ruby %}
 Grizzled::Rails::Logger.configure do |cfg|
  cfg.flatten = false
end
{% endhighlight %}

You can also flatten just some of the messages, by specifying a combination of
flattening patterns and "don't flatten" patterns. The default set of flattening
patterns flattens all messages with embedded newlines. However, this strategy
can be problematic, in that it'll also flatten EXPLAIN PLAN output and some
exceptions. To control which messages are flattened, define an array of regular
expressions, matched against each message as if it were already flattened.
(That is, the regexps do _not_ need to take newlines into account.) For
example:

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.flatten_patterns = [
    /.*Started GET /,
    /.*Started POST /
  ]
end
{% endhighlight %}

You can exert even more control by defining "don't flatten" patterns, which
take higher priority than "flatten" patterns. For instance, the following
configuration flattens every message *except* those with the words
"EXPLAIN PLAN" in them.

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.flatten_patterns = [
    /.*/,
  ]
  cfg.dont_flatten_patterns = [
    /\bEXPLAIN\s+PLAN\b/
  ]
end
{% endhighlight %}

### Unflattening Exceptions

Exception backtraces emitted via `logger.exception()` are *never* flattened.

However, since `logger.exception()` is a *Grizzled Rails Logger* extension,
most components don't use it. With the default configuration, exceptions logged
through `logger.error()` *are* flattened, which is rather ugly.

The following patterns will match most exceptions, ensuring that they aren't
flattened in the log output. (They're not part of the default configuration,
however, because not everyone wants this behavior.)

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.dont_flatten_patterns = [
    /\.rb:\w+:in\s+`/,
    /rb:\d+: syntax error/
  ]
end
{% endhighlight %}


## Formatting

Two settings control formatting.

### Message format

The `format` setting controls overall message formatting. Four escape
sequences control how the message is assembled:

* `%T` - Any "%T" sequences in the format are replaced by the current time.
  The format of the time is controlled by `timeformat` (see below).
* `%P` - Any "%P" sequences are replaced with the process ID of the Rails
  instance that's emitting the message.
* `%S` - Any "%S" sequences are replaced with an upper case string
  representation of the message's severity (e.g., "ERROR", "WARN").
* `%M` - Any "%M" sequences are replaced by the message, including any
  tags inserted via tagged logging. (See below.)

Any other characters, including blanks, are emitted verbatim.

It's legal (but probably silly) to include a sequence multiple times. If you
don't want a specific value to be logged, simply omit its escape sequence
from the format.

The default format is: `[%T] (%S) %P %M`.

For example, to change the log format to omit the PID, use:

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.format = '[%T] (%S) %M'
end
{% endhighlight %}

### Time format

The `timeformat` setting controls how the current time (see "%T", above) is
formatted. `timeformat` is a [strftime][] format string.

The default time format is: `%Y/%m/%d %H:%M:%S`. If you only want to log
the time (not the date), you can change it easily, in an intializer block:

{% highlight ruby %}
Grizzled::Rails::Logger.configure do |cfg|
  cfg.timeformat = '%H:%M:%S'
end
{% endhighlight %}

## Additional Fields and Rails Tagged Logging

_Grizzled Rails Logger_ works in tandem with Rails 3.2 [Tagged Logging][], so
you can also mix log tags into your log output. For instance, suppose you want
to capture the user name, session ID, and remote IP address for the request
that's active when a message is logged. _Grizzled Rails Logger_ doesn't support
escapes for those values, but you can use tagged logging to get them into your
log messages. Make sure your environment initialization file contains lines
such as the following:

{% highlight ruby %}
MyApp::Application.configure do
  config.log_tags = [
    :remote_ip,
    proc { |req| req.session[:id] || "no session },
    proc { |req| req.session[:user_name] || "anonymous" }
  ]
end
{% endhighlight %}

_Grizzled Rails Logger_ will format the actual log message, and hand it off
to the underlying Rails logger, which will add the log tags to it.

# Change log

The change log for this software is [here](https://github.com/bmc/grizzled-rails-logger/blob/master/CHANGELOG.md).

# Alternatives

Alternatives to this gem include:

* Paul Dowman's [better_logging][] gem
* [itslog][]

# License

This software is copyright &copy; 2012 Brian M. Clapper. It is released
under a [BSD license][].

[GitHub repo]: https://github.com/bmc/grizzled-rails-logger
[BSD license]: license.html
[better_logging]: https://github.com/pauldowman/better_logging
[itslog]: https://github.com/johnnytommy/itslog
[term-ansicolor]: https://github.com/flori/term-ansicolor
[strftime]: http://strftime.net/
[Tagged Logging]: http://guides.rubyonrails.org/3_2_release_notes.html#tagged-logging
