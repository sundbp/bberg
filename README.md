# bberg

* [Homepage](http://rubygems.org/gems/bberg)

## Description

A library to use the Bloomberg Java API from jruby

## Features

  TODO: add feature list

## Examples

  TODO: add examples

  For now look at the specs for a couple of examples

## Requirements

  * The Bloomberg Java API jar
  
## Install

To run the drb server from gem:

    $ gem install bberg
    $ bberg_drb_server

To create a stand alone executable do the following (after checking out repo):

    $ bundle install
    $ bundle install --deployment --without development
    $ rake bberg:create_exe
  
## Copyright

Copyright (c) 2010 pts

See {file:LICENSE.txt} for details.
