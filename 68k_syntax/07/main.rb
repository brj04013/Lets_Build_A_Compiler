#!/usr/bin/env ruby
require_relative "cradle.rb"
include Cradle

# Main Program
main = Cradle.init
$token = ''
until $value.upcase == 'END'
	Cradle.scan
    if $token == 'x'
		Cradle.emitln('Ident')
    elsif $token == '#'
		Cradle.emitln('Number')
    elsif $token == 'i' || $token == 'l' || $token == 'e'
		Cradle.emitln('Keyword')
    else
		Cradle.emitln('Operator')		
	end
	Cradle.emitln($value)
	if $token =~ /[\n]/
		Cradle.fin
	end	
end
