#!/usr/bin/env ruby
require_relative "cradle.rb"
include Cradle

emitln("#### Begin From Let's Build A Compiler")
main = Cradle.init
while $Look != '.'
	if $Look == '?'
		main.input
	elsif $Look == '!'
		main.output
	else
		main.assignment
	end
	Cradle.newline
end
emitln("#### End From Let's Build A Compiler")
