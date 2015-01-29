#!/usr/bin/env ruby

require "clone_mysql"
require "gli"

include GLI::App

program_desc 'Utility to manage MySQL clones'

command :clone do |c|
  c.flag [:d,:dataset]
  c.action do |options,args|
    p options
    p args
  end
end

