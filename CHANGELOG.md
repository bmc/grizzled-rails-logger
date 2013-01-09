# Change Log

Version 0.1.6 (07 Jan, 2013)

- Addressed [Issue #12][]: Extra newlines in unflattened exceptions logged
  through the `exception()` method.
- Minor documentation change contributed my Pirogov Evgenij.

[Issue #12]: https://github.com/bmc/grizzled-rails-logger/issues/5

---

Version 0.1.5 (16 June, 2012)

- Changed to work with Rails 3.2.6, while retaining backward compatibility
  with prior versions. Addresses [Issue #5][].
- Added a `dont_flatten_patterns` configuration item. See the
  [documentation](http://software.clapper.org/grizzled-rails-logger/) for
  details.

[Issue #5]: https://github.com/bmc/grizzled-rails-logger/issues/5

---

Version 0.1.4 (9 May, 2012)

Before attempting to use (and `gsub` against) the passed-in message, the
logging extension now explicitly converts it to a string. This bug fix is an
attempt to address [Issue #2][issue2] (which I have been unable to reproduce
yet.)

[issue2]: https://github.com/bmc/grizzled-rails-logger/issues/2

---

Version 0.1.3 (5 May, 2012)

Now works with Ruby 1.8.7, as well as Ruby 1.9. Addresses [Issue 1][issue1].
(Still requires Rails 3, however.)

[issue1]: https://github.com/bmc/grizzled-rails-logger/issues/1

---

Version 0.1.2 (21 April, 2012)

Backtrace dump now includes message that's in the exception.

---

Version 0.1.1 (19 April, 2012)

Added `flatten_patterns` to the configuration options.

---

Version 0.1.0 (12 April, 2012)

* Initial version.
