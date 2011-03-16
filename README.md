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

To create a stand alone executable do the following (after checking out the git repo):

    $ bundle install
    $ bundle install --deployment --without development
    $ rake bberg:create_exe

This creates a folder with a .exe in ../bberg-package/windows/

## Copyright

Copyright (c) 2010 pts

See {file:LICENSE.txt} for details.
