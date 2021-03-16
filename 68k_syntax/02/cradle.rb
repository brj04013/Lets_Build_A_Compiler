#!/usr/bin/env ruby
module Cradle

	# Constant Declarations

	# Variable Declarations
	$Expr = ""
	$Look = ""
	$i = 0

	# Lookahead Character
	# Read New Character From Input Stream
	def getchar
		$Expr = gets.chomp
		$Look = $Expr[$i]
	end

	# Report an Error
	def error(char)
		print "\nerror: " + char
	end

	# Report Error and Halt
	def error_abort(char)
		error(char)
		abort
	end

	# Report What Was expected
	def expected(char)
		error_abort(char + " expected")
	end

	# Match a Specific Input Character
	def match_char(char)
		if $Look == char
			$i += 1
			$Look = $Expr[$i]
		else
			expected("'" + char + "'")
		end
	end

	# Recognize an Alpha Character
	def isalpha(char)
		return char.upcase =~ /[A-Z]/
	end

	# Recognize a Decimal Digit
	def isdigit(char)
		return char =~ /[0-9]/
	end
	
	# Recognize an AddOp
	def isaddop(char)
		return char =~ /[\+\-]/
	end

	# Get an Identifier
	def getname
		if !isalpha($Look)
			expected("Name")
		end
		char = $Look
		$i += 1
		$Look = $Expr[$i]
		return char.upcase
	end

	# Get a Number
	def getnum
		if !isdigit($Look)
			expected("Integer")
		end
		char = $Look
		$i += 1
		$Look = $Expr[$i]
		return char
	end

	# Output a String with Tab
	def emit(char)
		print "\t" + char
	end

	# Output a String with Tab and CRLF
	def emitln(char)
		emit(char)
		puts
	end

	# Init
	def init
		getchar
	end
	
	# Parse and Translate a Math Factor
	def factor
		if $Look == '('
			match_char('(')
			Expression
			match_char(')')
		else
			emitln('MOVE #' + getnum + ',D0')
		end
	end

	# Recognize and Translate a Multiply
	def multiply
		match_char('*')
		factor
		emitln('MULS (SP)+,D0')
	end

	# Recognize and Translate a Divide
	def divide
		match_char('/')
		factor
		emitln('MOVE (SP)+,D1')
		emitln('DIVS D1,D0')
	end

	# Parse and Translate a Math Term
	def term
		factor
		while $Look =~ /[\*\/]/
			emitln('MOVE D0,-(SP)')
			if $Look == '*'
				multiply
			elsif $Look == '/'
				divide
			else
				expected('Mulop')
			end
		end
	end

	# Recognize and Translate an Add
	def add
		match_char('+')
		term
		emitln('add (SP)+,D0')
	end

	# Recognize and Translate a Substract
	def substract
		match_char('-')
		term
		emitln('SUB (SP)+,D0')
		emitln('NEG D0')
	end

	# Parse and Translate an Expression
	def expression
		if isaddop($Look) then
			emitln('CLR D0')
		else
			term
		end
		while isaddop($Look)
			emitln('MOVE D0,-(SP)')
			if $Look == '+'
				add
			elsif $Look == '-'
				substract
			else
				expected('addop')
			end
		end
	end	
end