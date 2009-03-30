#!/usr/bin/env rackup -s thin
require 'rubygems'
require 'sinatra/async'
require 'collabhub'

run CollabHub.new
