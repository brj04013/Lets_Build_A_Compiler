#!/usr/bin/env ruby
module Cradle

	# Constant Declarations
	TABLE_SIZE = 26
	KWLIST = ['IF', 'ELSE', 'ENDIF', 'END']
	KWCODE = 'xilee'

	# Variable Declarations
	$Expr = ""
	$Look = ""
	$i = 0
	$LCount = 0
	$token = ""
	$value = ""

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

	# Recognize Any Operator
	def isop(char)
		return char =~ /[\+\-\*\/\<\>\:\=]/
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
		char = ''
		while isalnum($Look)
			char += $Look.upcase
			$i += 1
			$Look = $Expr[$i]
		end		
		skipwhite
		$token = KWCODE[lookup(KWLIST, char, 4)]
		$value = char
	end

	# Get a Number
	def getnum
		if !isdigit($Look)
			expected("Integer")
		end
		char = ''
		while isdigit($Look)
			char += $Look
			$i += 1
			$Look = $Expr[$i]
		end
		skipwhite
		$token = '#'
		$value = char
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
	
	# Get an Operator
	def getop
		if !isop($Look)
			expected('Operator')
		end
		char = ''
		while isop($Look)
			char += $Look
			$i += 1
			$Look = $Expr[$i]		  
		end
		skipwhite
		if char.length == 1
			$token = char
		else
			$token = '?'
		end
		$value = char
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

	# Lexical Scanner
	def scan
		while $Look =~ /[\n]/
			fin
		end
		if isalpha($Look)
			getname
		elsif isdigit($Look)
			getnum
		elsif isop($Look)
			getop			
		else
			$value = $Look
			$token = '?'		
			$i += 1
			$Look = $Expr[$i]			
		end
		skipwhite
	end

	# Skip Over a Comma
	def skipcomma
		skipwhite
		if $Look == ','
			$i += 1
			$Look = $Expr[$i]
			skipwhite
		end
	end

	# Table LookUp
	def lookup(a, s, n)
		found = false
		i = n
		while (i > 0) && found == false
			if s == a[i-1]
				found = true
			else
				i -= 1
			end
		end
		return i
	end

	# Init
	def init
		inittable
		getchar
		skipwhite
	end
end
