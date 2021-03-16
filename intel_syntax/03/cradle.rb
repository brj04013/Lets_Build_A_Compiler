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

	# Match a Specific Input Character
	def match_char(char)
		if $Look == char
			$i += 1
			$Look = $Expr[$i]
			skipwhite
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

	# Get an identifier
	def getname
		if !isalpha($Look)
			expected("Name")
		end
		char = ""
		while isalnum($Look)
			char += $Look.upcase
			$i += 1
			$Look = $Expr[$i]
		end
		skipwhite
		return char
	end

	# Get a Number
	def getnum
		if !isdigit($Look)
			expected("Integer")
		end
		char = ""
		while isdigit($Look)
			char += $Look
			$i += 1
			$Look = $Expr[$i]
		end
		skipwhite
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
		skipwhite
	end
	
	# Parse and Translate an Identifier
	def ident
		name = getname
		if $Look == '('
			match_char('(')
			match_char(')')
			emitln('CALL ' + name)
		else
			emitln('MOV EAX, ' + name)
		end
	end

	# Parse and Translate a Math Factor
	def factor
		if $Look == '('
			match_char('(')
			expression
			match_char(')')
		elsif isalpha($Look)
			ident			
		else
			emitln('MOV EAX, ' + getnum)
		end
	end

	# Recognize and Translate a Multiply
	def multiply
		match_char('*')
		factor
		emitln('POP ECX')
		emitln('IMUL ECX')
	end

	# Recognize and Translate a Divide
	def divide
		match_char('/')
		factor
		emitln('MOV ECX, EAX')
		emitln('POP EAX')
		emitln('XOR EDX, EDX')
		emitln('IDIV ECX')
	end

	# Parse and Translate a Math Term
	def term
		factor
		while $Look =~ /[\*\/]/
			emitln('PUSH EAX')
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
		emitln('POP ECX')
		emitln('ADD EAX, ECX')
	end

	# Recognize and Translate a Substract
	def substract
		match_char('-')
		term
		emitln('POP ECX')
		emitln('SUB EAX, ECX')
		emitln('NEG EAX')
	end

	# Parse and Translate an Expression
	def expression
		if isaddop($Look) then
			emitln('XOR EAX, EAX')
		else
			term
		end
		while isaddop($Look)
			emitln('PUSH EAX')
			if $Look == '+'
				add
			elsif $Look == '-'
				substract
			else
				expected('addop')
			end
		end
	end

	# Parse and Translate an Assignment Statement
	def assignment
		name = getname
		match_char('=')
		expression
		emitln('MOV ' + name + ', EAX')
	end	
end
