# bberg

* [Rubygems](http://rubygems.org/gems/bberg)
* [Github](http://github.com/sundbp/bberg/)
* [Issue tracker](http://github.com/sundbp/bberg/issues)

## Description

A library to use the Bloomberg Java API from jruby

## Features

So far the following requests can be made:

* HistoricalDataRequest
* ReferenceDataRequest

We'll be working on adding all the requests supported by the Java API, including "subscriptions".

Feel free to pitch in :)

## Examples

  TODO: add examples. For now look at the specs for a couple of examples

## Requirements

* The Bloomberg Java API jar
  
## Install

    $ gem install bberg

The gem comes with a drb server to make it simpler to use the API from several processes on
the same machine (multiple machines not allowed by the Java API copyright, same applies here):

    $ bberg_drb_server

To create a stand alone executable do the following from a CMD prompt after checking out the 
git repo (for example it does't work from within cygwin):

    $ gem install rawr
    $ bundle install
    $ bundle install --deployment --without development
    $ rake bberg:create_exe

This creates a folder with a .exe in ../bberg-package/windows/

NOTE: you need rawr installed (outside of bundler) for this to work. We can't use
rawr inside of bundler since we then get a copy of rawr among the vendor gems.

## Copyright

Copyright (c) 2010 pts

See {file:LICENSE.txt} for details.
