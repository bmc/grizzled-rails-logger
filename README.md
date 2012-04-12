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
* An `exception` message that dumps an exception backtrace to the log

## Installation for Rails 3

Add the following to your `Gemfile`, and run `bundle install`:

    gem 'grizzled-rails-logger'

If you want the development version of the gem, use:

    gem 'grizzled-rails-logger', :git => 'git://github.com/bmc/grizzled-rails-logger.git'

## Configuration

Becaue *Grizzled Rails Logger* merely adds to the standard Rails logger,
you can continue to all the usual capabilities of the Rails logger (such as,
for instance, tagged logged).

To Configure *Grizzled Rails Logger*, add a section like the following to your
`config/application.rb` file or your individual environment file:

    Grizzled::Rails::Logger.configure do |cfg|
      # Configuration data goes here
    end

The default configuration is equivalent to the following:

    Grizzled::Rails::Logger.configure do |cfg|
      cfg.flatten = true
      cfg.format = '%[T] (%S) %P %M'
      cfg.timeformat = '%Y/%m/%d %H:%M:%S'
      cfg.colorize = true
      cfg.colors = {
        :debug => Term::ANSIColor.cyan,
        :warn  => Term::ANSIColor.yellow + Term::ANSIColor.bold,
        :fatal => Term::ANSIColor.red + Term::ANSIColor.bold,
        :error => Term::ANSIColor.red
      }
    end

Each configuration option is described in more detail, below.

### Colorization

By default, *Grizzled Rails Logger* colorizes logging output, using ANSI
terminal escape sequences (as defined by the [term-ansicolor][] gem).

You can disable colorization by setting the `colorize` option to `false`:

    Grizzled::Rails::Logger.configure do |cfg|
      cfg.colorize = false
    end

You can also change the colors associated with each severity. Suppose, for
instance, that you want INFO messages (which normally aren't colorized) to be
white, and you wanted DEBUG messages (which are normally cyan) to be bold blue.
You'd simply reconfigure those values, as shown below:

    Grizzled::Rails::Logger.configure do |cfg|
      cfg.colors[:debug] = Term::ANSIColor.bold + Term::ANSIColor.blue
      cfg.colors[:info] = Term::ANSIColor.white
    end

`Term::ANSIColor` is automatically included for you.

**WARNING** *Grizzled Rails Logger* does not verify that the values you
store in the color settings are legal ANSI sequences. The following is
perfectly legal, though probably not what you want:

    Grizzled::Rails::Logger.configure do |cfg|
      cfg.colors[:debug] = "red"
    end

With that setting, a debug message that normally looks like this:

    [2012/04/12 14:43:22] (DEBUG) 9816 My debug message

will, instead, look like this:

    red[2012/04/12 14:43:22] (DEBUG) 9816 My debug message

### Exception logging

*Grizzled Rails Logger* adds an `exception()` method, providing an easy way
to dump a rescued exception and its backtrace:

    begin
      # Some dangerous operation
    rescue Exception => ex
      logger.exception("Error while doing dangerous thing", ex)
    end

The method takes three parameters, one of which is optional:

* `message` - a message to be displayed along with the exception. Can be nil,
  but must be supplied.
* `exception` - the exception to be dumped.
* `progname` - program name. Optional; defaults to nil.

The exception is dumped at severity level ERROR.

Regardless of the setting of `flatten` (see below), the exception's backtrace
is always displayed on multiple lines.

### Flattening

The default Rails logger includes lots of newlines in its log messages. For
example:

    [2012/04/12 14:59:48] (INFO) 10102 [659d08c8cbcf3ddf543ca3710cee2771] 

    Started GET "/about" for 127.0.0.1 at 2012-04-12 14:59:48 -0400

*Grizzled Rails Logger* automatically flattens log messages to a single line:

    [2012/04/12 14:59:48] (INFO) 10102 [659d08c8cbcf3ddf543ca3710cee2771] Started GET "/about" for 127.0.0.1 at 2012-04-12 14:59:48 -0400

If you prefer *not* to flatten log messages, disable the `flatten` setting:

    Grizzled::Rails::Logger.configure do |cfg|
      cfg.flatten = false
    end

**NOTE:** Exception backtraces are *never* flattened.

### Formatting

Two settings control formatting.

#### `format`

The `format` setting controls overall message formatting. Four escape
sequences control how the message is assembled:

* `%T` - Any "%T" sequences in the format are replaced by the current time.
  The format of the time is controlled by `timeformat` (see below).
* `%P` - Any "%P" sequences are replaced with the process ID of the Rails
  instance that's emitting the message.
* `%S` - Any "%S" sequences are replaced with an upper case string
  representation of the message's severity (e.g., "ERROR", "WARN").
* `%M` - Any "%M" sequences are replaced by the message, including any
  tags inserted via tagged logging.

Any other characters, including blanks, are emitted verbatim.

It's legal (but probably silly) to include a sequence multiple times. If you
don't want a specific value to be logged, simply omit its escape sequence
from the format.

The default format is: `[%T] (%S) %P %M`.

For example, to change the log format to omit the PID, use:

    Grizzled::Rails::Logger.configure do |cfg|
      cfg.format = '[%T] (%S) %M'
    end


#### `timeformat`

The `timeformat` setting controls how the current time (see "%T", above) is
formatted. `timeformat` is a [strftime][] format string.

The default time format is: `%Y/%m/%d %H:%M:%S`

## Alternatives

Alternatives to this gem include:

* Paul Dowman's [better_logging][] gem
* [itslog][]

[better_logging]: https://github.com/pauldowman/better_logging
[itslog]: https://github.com/johnnytommy/itslog
[term-ansicolor]: https://github.com/flori/term-ansicolor
[strftime]: http://strftime.net/