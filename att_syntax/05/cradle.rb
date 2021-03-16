#!/usr/bin/env ruby
module Cradle

	# Constant Declarations
	TABLE_SIZE = 26

	# Variable Declarations
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

	# Init
	def init
		inittable
		getchar
		skipwhite
	end
	
	# Recognize and Translate an IF Construct
	def doif(l)
		match_char('i')
		condition
		l1 = newlabel
		l2 = l1
		emitln('je ' + l1)
		block(l)
		if $Look == 'l'
			match_char('l')
			l2 = newlabel
			emitln('jmp ' + l2)
			postlabel(l1)
			block(l)
		end
		match_char('e')
		postlabel(l2)
	end

	# Parse and Translate a WHILE Statement
	def dowhile
		match_char('w')
		l1 = newlabel
		l2 = newlabel
		postlabel(l1)
		condition
		emitln('je ' + l2)
		block(l2)
		match_char('e')
		emitln('jmp ' + l1)
		postlabel(l2)
	end

	# Parse and Translate a LOOP Statement
	def doloop
		match_char('p')
		l1 = newlabel
		l2 = newlabel
		postlabel(l1)
		block(l2)
		match_char('e')
		emitln('jmp ' + l1)
		postlabel(l2)
	end

	# Parse and Translate a REPEAT Statement 
	def dorepeat
		match_char('r')
		l1 = newlabel
		l2 = newlabel
		postlabel(l1)
		block(l2)
		match_char('u')
		condition
		emitln('je ' + l1)
		postlabel(l2)
	end

	# Parse and Translate a FOR Statement
	def dofor
		match_char('f')
		l1 = newlabel
		l2 = newlabel
		name = getname
		match_char('=')
		expression
		emitln('movl %eax, $' + name)
		emitln('decl $' + name)
		expression
		emitln('pushl %eax')
		postlabel(l1)
		emitln('incl $' + name)
		emitln('popl %eax')
		emitln('cmpl %eax, $' + name)
		emitln('jG ' + l2)
		emitln('pushl %eax')
		block(l2)
		match_char('e')
		emitln('jmp ' + l1)
		postlabel(l2)
	end

	# Parse and Translate a DO Statement
	def dodo
		match_char('d')
		l1 = newlabel
		l2 = newlabel
		expression
		emitln('pushl %ecx')
		emitln('movl %eax,%ecx')
		postlabel(l1)
		block(l2)
		emitln('loop $' + l1)
		postlabel(l2)
		emitln('popl %ecx')
	end

	# Recognize and Translate a BREAK
	def dobreak(l)
		match_char('b')
		if l != ''
			emitln('jmp ' + l)
		else
			abort('No loop to break from')
		end
	end

	# Parse and Translate a Boolean Condition
	# This version is a dummy
	def condition
		emitln('<condition>')
	end

	# Parse and Translate an Expression
	# This version is a dummy
	def expression
		emitln('<expr>')
	end

	# Recognize and Translate an "Other"
	def other
		emitln(getname)
	end

	# Recognize and Translate a Statement Block
	def block(l)
		while $Look != 'e' && $Look != 'l' && $Look != 'u'
			if $Look == 'i'
				doif(l)
			elsif $Look == 'w'
				dowhile				
			elsif $Look == 'p'
				doloop				
			elsif $Look == 'r'
				dorepeat				
			elsif $Look == 'f'
				dofor				
			elsif $Look == 'd'
				dodo				
			elsif $Look == 'b'
				dobreak(l)									
			else
				other
			end
			newline
		end
	end

	# Parse and Translate a Program
	def doprogram
		block('')
		if $Look != 'e' 
			expected('End')
		end
		emitln('END')
	end	
end
