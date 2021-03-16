#!/usr/bin/env ruby
require_relative "cradle.rb"
include Cradle

main = Cradle.init
while $Look != '.'
	main.getclass
	main.gettype
	main.topdecl
end
