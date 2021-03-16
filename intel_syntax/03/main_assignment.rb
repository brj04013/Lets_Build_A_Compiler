#!/usr/bin/env ruby
require_relative "cradle.rb"
include Cradle

main = Cradle.init
emitln("#### Begin From Let's Build A Compiler")
main.assignment
emitln("#### End From Let's Build A Compiler")
if $Look =~ /[\r]/
	$i += 1
	$Look = $Expr[$i]
	if $Look =~ /[\n]/
		nil
	end
elsif $Look =~ /[\n]/
	nil
else
	Cradle.expected('Newline')
end
