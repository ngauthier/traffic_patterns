#!/usr/bin/ruby
require 'rubygems'
require 'lib/traffic_patterns'

@tp = TrafficPatterns.new
@tp.parse_file('production.log.1')
@tp.to_dot

