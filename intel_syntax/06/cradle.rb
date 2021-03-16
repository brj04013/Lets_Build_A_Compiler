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
		emitln('JE ' + l1)
		block(l)
		if $Look == 'l'
			match_char('l')
			l2 = newlabel
			emitln('JMP ' + l2)
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
		emitln('JE ' + l2)
		block(l2)
		match_char('e')
		emitln('JMP ' + l1)
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
		emitln('JMP ' + l1)
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
		emitln('JE ' + l1)
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
		emitln('MOV ' + name + ', EAX');
		emitln('DEC ' + name);
		expression
		emitln('PUSH EAX')
		postlabel(l1)
		emitln('INC ' + name)
		emitln('POP EAX')
		emitln('CMP ' + name + ', EAX')
		emitln('JG ' + l2)
		emitln('PUSH EAX')
		block(l2)
		match_char('e')
		emitln('JMP ' + l1)
		postlabel(l2)
	end

	# Parse and Translate a DO Statement
	def dodo
		match_char('d')
		l1 = newlabel
		l2 = newlabel
		expression
		emitln('PUSH ECX')
		emitln('MOV ECX, EAX')
		postlabel(l1)
		block(l2)
		emitln('LOOP ' + l1)
		postlabel(l2)
		emitln('POP ECX')
	end

	# Recognize and Translate a BREAK
	def dobreak(l)
		match_char('b')
		if l != ''
			emitln('JMP ' + l)
		else
			abort('No loop to break from')
		end
	end

	# Parse and Translate an Assignment Statement
	def assignment
		name = getname
		match_char('=')
		boolexpression
		emitln('MOV ' + name + ', EAX')
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
				emitln('MOV EAX, -1')
			else
				emitln('XOR EAX, EAX')
			end
		else
			relation
		end
	end

	# Recognize and Translate a Boolean Or
	def boolor
		match_char('|')
		boolterm
		emitln('POP ECX')
		emitln('OR EAX, ECX')
	end

	# Recognize and Translate an Exclusive Or
	def boolxor
		match_char('~')
		boolterm
		emitln('POP ECX')
		emitln('XOR EAX, ECX')
	end

	# Parse and Translate a Boolean Expression
	def boolexpression
		boolterm
		while isorop($Look)
			emitln('PUSH EAX')
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
			emitln('PUSH EAX')
			match_char('&')
			notfactor
			emitln('POP ECX')
			emitln('AND EAX, ECX')
		end
	end

	# Parse and Translate a Boolean Factor with NOT
	def notfactor
		if $Look == '!'
			match_char('!')
			boolfactor
			emitln('NOT EAX')
		else
			boolfactor
		end
	end

	# Recognize and Translate a Relational "Equals"
	def equals
		match_char('=')
		expression
		emitln('POP ECX')
		emitln('CMP ECX, EAX')
		emitln('CMOVE EAX, T')
		emitln('CMOVNE EAX,  F')
	end

	# Recognize and Translate a Relational "Not Equals"
	def notequals
		match_char('#')
		expression
		emitln('POP ECX')
		emitln('CMP ECX, EAX')
		emitln('CMOVNE EAX, T')
		emitln('CMOVE EAX,  F')
	end

	# Recognize and Translate a Relational "Less Than"
	def less
		match_char('<')
		expression
		emitln('POP ECX')
		emitln('CMP ECX, EAX')
		emitln('CMOVL EAX, T')
		emitln('CMOVGE EAX, F')  
	end

	# Recognize and Translate a Relational "Greater Than"
	def greater
		match_char('>')
		expression
		emitln('POP ECX')
		emitln('CMP ECX, EAX')
		emitln('CMOVG EAX, T')
		emitln('CMOVLE EAX, F')
	end

	# Parse and Translate a Relation
	def relation
		expression
		if isrelop($Look)
			emitln('PUSH EAX')
			if $Look == '='
				equals
			elsif $Look == '#'
				notequals
			elsif $Look == '<'
				less
			elsif $Look == '>'
				greater
			end
			emitln('TEST EAX, -1')
		end
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
			emitln('MOV EAX, ' + getnum.to_s)
		end
	end

	# Parse and Translate the First Math Factor
	def signedfactor
		if $Look == '+'
			getchar
			if $Look == '-'
				getchar
				if isdigit($Look)
					emitln('MOV EAX, ' + getnum.to_s)
				else
					factor
					emitln('NEG EAX')
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
		signedfactor
		while $Look =~ /[\*\/]/
			emitln('PUSH EAX')
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
		term
		while isaddop($Look)
			emitln('PUSH EAX')
			if $Look == '+'
				add
			elsif $Look == '-'
				substract
			end
		end
	end	
end
