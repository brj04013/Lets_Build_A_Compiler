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
	
	# Recognize and Translate an IF Construct
	def doif(l)
		match_char('i')
		boolexpression
		l1 = newlabel
		l2 = l1
		emitln('BEQ ' + l1)
		block(l)
		if $Look == 'l'
			match_char('l')
			l2 = newlabel
			emitln('BRA ' + l2)
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
		boolexpression
		emitln('BEQ ' + l2)
		block(l2)
		match_char('e')
		emitln('BRA ' + l1)
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
		emitln('BRA ' + l1)
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
		boolexpression
		emitln('BEQ ' + l1)
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
		emitln('SUBQ #1,D0')
		emitln('LEA ' + name + '(PC),A0')
		emitln('MOVE D0,(A0)')
		expression
		emitln('MOVE D0,-(SP)')
		postlabel(l1)
		emitln('LEA ' + name + '(PC),A0')
		emitln('MOVE (A0),D0')
		emitln('addQ #1,D0')
		emitln('MOVE D0,(A0)')
		emitln('CMP (SP),D0')
		emitln('BGT ' + l2)
		block(l2)
		match_char('e')
		emitln('BRA ' + l1)
		postlabel(l2)
		emitln('addQ #2,SP')
	end

	# Parse and Translate a DO Statement
	def dodo
		match_char('d')
		l1 = newlabel
		l2 = newlabel
		expression
		emitln('SUBQ #1,D0')
		postlabel(l1)
		emitln('MOVE D0,-(SP)')
		block(l2)
		emitln('MOVE (SP)+,D0')
		emitln('DBRA D0,' + l1)
		emitln('SUBQ #2,SP')
		postlabel(l2)
		emitln('addQ #2,SP')
	end

	# Recognize and Translate a BREAK
	def dobreak(l)
		match_char('b')
		if l != ''
			emitln('BRA ' + l)
		else
			abort('No loop to break from')
		end
	end

	# Parse and Translate an Assignment Statement
	def assignment
		name = getname
		match_char('=')
		boolexpression
		emitln('LEA ' + name + '(PC),A0')
		emitln('MOVE D0,(A0)')
	end

	# Recognize and Translate a Statement Block
	def block(l)
		while $Look != 'e' && $Look != 'l' && $Look != 'u'
			fin
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
				assignment
			end
			fin
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

	# Parse and Translate a Boolean Expression
	def boolfactor
		if isboolean($Look)
			if getboolean then
				emitln('MOVE #-1,D0')
			else
				emitln('CLR D0')
			end
		else
			relation
		end
	end

	# Recognize and Translate a Boolean Or
	def boolor
		match_char('|')
		boolterm
		emitln('OR (SP)+,D0')
	end

	# Recognize and Translate an Exclusive Or
	def boolxor
		match_char('~')
		boolterm
		emitln('EOR (SP)+,D0')
	end

	# Parse and Translate a Boolean Expression
	def boolexpression
		boolterm
		while isorop($Look)
			emitln('MOVE D0,-(SP)')
			if $Look == '|'
				boolor
			elsif $Look == '~'
				boolxor
			end
		end
	end	

	# Parse and Translate a Boolean Term
	def boolterm
		notfactor
		while $Look == '&'
			emitln('MOVE D0,-(SP)')
			match_char('&')
			notfactor
			emitln('AND (SP)+,D0')
		end
	end

	# Parse and Translate a Boolean Factor with NOT
	def notfactor
		if $Look == '!'
			match_char('!')
			boolfactor
			emitln('EOR #-1,D0')
		else
			boolfactor
		end
	end

	# Recognize and Translate a Relational "Equals"
	def equals
		match_char('=')
		expression
		emitln('CMP (SP)+,D0')
		emitln('SEQ D0')
	end

	# Recognize and Translate a Relational "Not Equals"
	def notequals
		match_char('#')
		expression
		emitln('CMP (SP)+,D0')
		emitln('SNE D0')
	end

	# Recognize and Translate a Relational "Less Than"
	def less
		match_char('<')
		expression
		emitln('CMP (SP)+,D0')
		emitln('SGE D0')
	end

	# Recognize and Translate a Relational "Greater Than"
	def greater
		match_char('>')
		expression
		emitln('CMP (SP)+,D0')
		emitln('SLE D0')
	end

	# Parse and Translate a Relation
	def relation
		expression
		if isrelop($Look)
			emitln('MOVE D0,-(SP)')
			if $Look == '='
				equals
			elsif $Look == '#'
				notequals
			elsif $Look == '<'
				less
			elsif $Look == '>'
				greater
			end
			emitln('TST D0')
		end
	end

	# Parse and Translate an Identifier
	def ident
		name = getname
		if $Look == '('
			match_char('(')
			match_char(')')
			emitln('BSR ' + name)
		else
			emitln('MOVE ' + name + '(PC),D0')
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
			emitln('MOVE #' + getnum.to_s + ',D0')
		end
	end

	# Parse and Translate the First Math Factor
	def signedfactor
		if $Look == '+'
			getchar
			if $Look == '-'
				getchar
				if isdigit($Look)
					emitln('MOVE #-' + getnum.to_s + ',D0')
				else
					factor
					emitln('NEG D0')
				end
			end
	   	else
	   		factor
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
		emitln('EXS.L D0')
		emitln('DIVS D1,D0')
	end

	# Parse and Translate a Math Term
	def term
		signedfactor
		while $Look =~ /[\*\/]/
			emitln('MOVE D0,-(SP)')
			if $Look == '*'
				multiply
			elsif $Look == '/'
				divide
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
		term
		while isaddop($Look)
			emitln('MOVE D0,-(SP)')
			if $Look == '+'
				add
			elsif $Look == '-'
				substract
			end
		end
	end	
end
