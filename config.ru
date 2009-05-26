#!/usr/bin/env rackup -s thin
require 'rubygems'
require 'sinatra/async'
require 'collabhub'
require 'eventmachine'

EventMachine.epoll = true
EventMachine.set_max_timers 100_000
run CollabHub
