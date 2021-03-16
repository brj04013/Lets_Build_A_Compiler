#!/usr/bin/env ruby
module Kiss

	# Constant Declarations

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

	# Recognize a Mulop
	def ismulop(char)
		return char =~ /[\*\/]/
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
		skipwhite
	end

	# Get an Identifier
	def getname
		while $Look =~ /[\n]/
			fin
		end		
		if !isalpha($Look)
			expected("Name")
		end
		char = $Look.upcase
		$i += 1
		$Look = $Expr[$i]
		skipwhite
		return char
	end

	# Get an Number
	def getnum
		if !isdigit($Look)
			expected("Integer")
		end
		char = $Look
		$i += 1
		$Look = $Expr[$i]
		skipwhite
		return char
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

	# Output a String with Tab
	def emit(char)
		print "\t" + char
	end

	# Output a String with Tab and CRLF
	def emitln(char)
		emit(char)
		puts
	end

	# Parse and Translate an Identifier
	def ident
		name = getname
		if $Look == '('
			match_char('(')
			match_char(')')
			emitln('call ' + name)
		else
			emitln('movl $' + name + ', %eax')
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
			emitln('movl $' + getnum + ', %eax')
		end
	end

	# Parse and Translate the First Math Factor
	def signedfactor
		char = $Look
		if isaddop($Look)
 			$i += 1
			$Look = $Expr[$i]
			skipwhite
		end
		factor
		if char == '-'
			emitln('negl %eax')
		end
	end

	# Recognize and Translate a Multiply
	def multiply
		match_char('*')
		factor
		emitln('popl %ecx')
		emitln('imull %ecx')
	end

	# Recognize and Translate a Divide
	def divide
		match_char('/')
		factor
		emitln('movl %eax,%ecx')
		emitln('popl %eax')
		emitln('xorl %edx,%edx')  
		emitln('idivl %ecx')
	end

	# Completion of Term Processing  (called by Term and FirstTerm)
	def term1
		while ismulop($Look)
			emitln('pushl %eax')
			if $Look == '*'
				multiply
			elsif $Look == '/'
				divide
			end
		end
	end	
                             
	# procedure Term
	def term
		factor
		term1
	end

	# Parse and Translate a Math Term with Possible Leading Sign
	def firstterm
		signedfactor
		term1
	end

	# Recognize and Translate an Add
	def add
		match_char('+')
		term
		emitln('popl %ecx')
		emitln('addl %ecx,%eax')
	end

	# Recognize and Translate a Substract
	def substract
		match_char('-')
		term
		emitln('popl %ecx')
		emitln('subl %ecx,%eax')
		emitln('negl %eax')
	end

	# Parse and Translate an Expression
	def expression
		firstterm
		while isaddop($Look)
			emitln('pushl %eax')
			if $Look == '+'
				add
			elsif $Look == '-'
				substract
			end
		end
	end	

	# Parse and Translate a Boolean Condition
	# This version is a dummy
	def condition
		emitln('Condition')
	end

	# Recognize and Translate an IF Construct
	def doif
		match_char('i')
		condition
		l1 = newlabel
		l2 = l1
		emitln('je ' + l1)
		block
		if $Look == 'l'
			match_char('l')
			l2 = newlabel
			emitln('jmp ' + l2)
			postlabel(l1)
			block
		end
		match_char('e')
		postlabel(l2)
	end

	# Parse and Translate an Assignment Statement
	def assignment
		name = getname
		match_char('=')
		expression
		emitln('movl %eax, $' + name)
	end

	# Recognize and Translate a Statement Block
	def block
		while $Look != 'e' && $Look != 'l'
			if $Look == 'i'
				doif
			elsif $Look =~ /[\n]/
				while $Look =~ /[\n]/
					fin
				end
			else
				assignment
			end
		end
	end

	# Parse and Translate a Program
	def doprogram
		block
		if $Look != 'e'
			expected('END')
		end
		emitln('END')
	end

	# Initialize
	def init
		$Expr = ""
		$Look = ""
		$i = 0		
		$LCount = 0
		getchar
	end
end
