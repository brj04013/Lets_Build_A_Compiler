#!/usr/bin/env ruby
require_relative "cradle.rb"
include Cradle

main = Cradle.init
emitln("#### Begin From Let's Build A Compiler")
main.doprogram
emitln("#### End From Let's Build A Compiler")
