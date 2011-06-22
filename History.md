History
=======

0.4.1
-----

* You no longer need to place builders for classes used in associations before the builders for objects that declare those associations.
* Fixed: you can now create builders for *-to-many associations using only the default attributes.

0.4.0
-----

* Blocks passed to attributes now optionally take a second argument (the builder parent).
* You can now use `?` like `!`, but it will search for an existing record first.
