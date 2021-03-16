#!/usr/bin/env ruby
module Cradle

	# Constant declarations
	TABLE_SIZE = 26

	# Variable declarations
	$Expr = ""
	$Look = ""
	$i = 0
	$LCount = 0

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

	# Recognize a Boolean Literal
	def isboolean(char)
		return char =~ /[TF]/;
	end

	# Recognize a Boolean Orop
	def isorop(char)
		return char =~ /[|~]/
	end

	# Recognize a Relop
	def isrelop(char)
		return char =~ /[=#<>]/
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

	# Get a Boolean Literal
	def getboolean
		if !isboolean($Look)
			expected('Boolean Literal')
		end
		char = $Look.upcase
		$i += 1
		$Look = $Expr[$i]
		skipwhite
		return (char == 'T')
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

	# initialize the Variable Area
	def inittable
		$table = []
		for i in 0..TABLE_SIZE
			$table[i] = 0
		end
	end
	
	# Generate a Unique Label
	def newlabel
		s = $LCount
		label = 'L' + s.to_s
		$LCount += 1
		return label
	end

	# Post a Label To Output
	def postlabel(l);
		emitln(l + ':')
	end

	# Skip a CRLF
	def fin
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

	# Init
	def init
		inittable
		getchar
		skipwhite
	end
	
	# Parse and Translate a Program
	def prog
		match_char('p')
		name = getname
		prolog
		doblock(name)
		match_char('.')
		epilog(name)
	end

	# Write the Prolog
	def prolog
		emitln('PROLOG')
	end

	# Write the Epilog
	def epilog(name)
		emitln('EPILOG')
		emitln('END ' + name)
	end	

	# Parse and Translate a Pascal Block
	def doblock(name)
		declarations
		postlabel(name)
		statements
	end

	# Parse and Translate the Declaration Part
	def declarations
		while $Look == 'l' || $Look == 'c' || $Look == 't' || $Look == 'v' || $Look == 'p' || $Look == 'f'
			if $Look == 'l'
				labels
			elsif $Look == 'c'
				constants
			elsif $Look == 't'
				types
			elsif $Look == 'v'
				variables
			elsif $Look == 'p'
				doprocedure
			elsif $Look == 'f'
				dofunction
			end
		end
	end

	# Process Label Statement
	def labels
		match_char('l')
	end

	# Process Const Statement
	def constants
		match_char('c')
	end

	# Process Type Statement
	def types
		match_char('t')
	end

	# Process Var Statement
	def variables
		match_char('v')
	end

	# Process Procedure Definition
	def doprocedure
		match_char('p')
	end

	# Process Function Definition
	def dofunction
		match_char('f')
	end

	# Parse and Translate the Statement Part
	def statements
		match_char('b')
		while $Look != 'e'
			$i += 1
			$Look = $Expr[$i]
		end
		match_char('e')
	end	

	# Get a Storage Class Specifier
	def getclass
		if $Look == 'a' || $Look == 'x' || $Look == 's'
			$class = $Look
			$i += 1
			$Look = $Expr[$i]
		else
			$class = 'a'
		end
	end

	# Get a Type Specifier
	def gettype
		$typ = ' '
		if $Look == 'u'
			$sign = 'u'
			$typ = 'i'
			$i += 1
			$Look = $Expr[$i]
		else
			$sign = 's'
		end
		if $Look == 'i' || $Look == 'l' || $Look == 'c'
			$typ = $Look
			$i += 1
			$Look = $Expr[$i]
		end
	end

	# Process a Top-Level Declaration
	def topdecl
		name = getname
		if $Look == '('
			dofunc(name)
		else
			dodata(name)
		end
	end

	# Process a Function Definition
	def dofunc(char)
		match_char('(')
		match_char(')')
		match_char('{')
		match_char('}')
		if $typ == ' '
			$typ = 'i'
		end
		emitln($class + $sign + $typ + ' function ' + char)
	end

	# Process a Data Declaration
	def dodata(char)
		if $typ == ' '
			expected('Type declaration')
		end
		emitln($class + $sign + $typ + ' data ' + char)
		while $Look == ','
			match_char(',')
			char = getname
			emitln($class + $sign + $typ + ' data ' + char)
		end
		match_char(';')
	end		
end
