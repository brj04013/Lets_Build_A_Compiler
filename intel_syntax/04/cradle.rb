#!/usr/bin/env ruby
module Cradle

	# Constant Declarations
	TABLE_SIZE = 26

	# Variable Declarations
	$Expr = ""
	$Look = ""
	$i = 0

	# Lookahead Character
	# Read New Character From input Stream
	def getchar
		$Expr = gets
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

	# Match a Specific input Character
	def match_char(char)
		if $Look == char
			$i += 1
			$Look = $Expr[$i]
			skipwhite
		else
			expected("'" + char + "'")
		end
	end

	# Recognize and Skip Over a NewLine
	def newline
		if $Look =~ /[\r]/
			$i += 1
			$Look = $Expr[$i]
			if $Look =~ /[\n]/
				$Expr = ""
				$Look = ""
				$i = 0
				getchar
			end
		elsif $Look =~ /[\n]/
				$Expr = ""
				$Look = ""
				$i = 0
			getchar
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
	
	# Recognize an Alphanumeric
	def isalnum(char)
		return isalpha(char) || isdigit(char)
	end
	
	# Recognize an AddOp
	def isaddop(char)
		return char =~ /[\+\-]/
	end

	# Recognize White Space
	def iswhite(char)
		return char =~ /[ \t]/
	end

	# Skip Over Leading White Space
	def skipwhite
		while iswhite($Look)
			$i += 1
			$Look = $Expr[$i]
		end
	end

	# Get an Identifier
	def getname
		if !isalpha($Look)
			expected("Name")
		end
		char = $Look.upcase
		$i += 1
		$Look = $Expr[$i]
		skipwhite
		return char
	end

	# Get a Number
	def getnum
		if !isdigit($Look)
			expected("Integer")
		end
		char = 0
		while isdigit($Look)
			char = 10 * char + $Look.to_i
			$i += 1
			$Look = $Expr[$i]
		end
		skipwhite
		return char
	end

	# output a String with Tab
	def emit(char)
		print "\t" + char
	end

	# output a String with Tab and CRLF
	def emitln(char)
		emit(char)
		puts
	end

	# initialize the Variable Area
	def inittable
		$table = []
		for i in 0..TABLE_SIZE
			$table[i] = 0
		end
	end

	# Init
	def init
		inittable
		getchar
		skipwhite
	end
	
	# Parse and Translate a Math Factor
	def factor
		if $Look == '('
			match_char('(')
			value = expression
			match_char(')')
		elsif isalpha($Look)
			value = $table[getname.ord - 'A'.ord]
		else
			value = getnum
		end
		return value
	end

	# Parse and Translate a Math Term
	def term
		value = factor
		while $Look =~ /[\*\/]/
			if $Look == '*'
				match_char('*');
				value = value * factor
			elsif $Look == '/'
				match_char('/');
				value = value / factor
			end
		end
		return value
	end

	# Parse and Translate an Expression
	def expression
		if isaddop($Look) then
			value = 0
		else
			value = term
		end
		while isaddop($Look)
			if $Look == '+'
				match_char('+')
				value = value + term
        	elsif $Look == '-'
				match_char('-')
				value = value - term
			end
		end
		return value
	end

	# Parse and Translate an Assignment Statement
	def assignment
		name = getname
		match_char('=')
		$table[name.ord - 'A'.ord] = expression
	end

	#input Routine
	def input
		match_char('?')
		$table[getname.ord - 'A'.ord] = expression
	end

	# output Routine
	def output
		match_char('!')
		emitln($table[getname.ord - 'A'.ord].to_s)
	end	
end
