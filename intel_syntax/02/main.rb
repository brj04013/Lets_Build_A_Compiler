#!/usr/bin/env ruby
require_relative "cradle.rb"
include Cradle

main = Cradle.init
print(".intel_syntax noprefix")
emitln("")
emitln("")
print(".data")
emitln("")
emitln("")
emitln("msg:")
emitln("\t.ascii " + '"Result = "')
emitln("\tlen_msg = . - msg")
emitln("char_neg:")
emitln("\t.ascii " + '"-"')
emitln("\tlen_char_neg = . - char_neg")                
emitln("newline:")
emitln("\t.ascii "+ '"\n"')
emitln("result:")
emitln("\t.long 0")
emitln("positive:")
emitln("\t.long 0")              
emitln("digits:")
emitln("\t.long 0")
emitln("")
print(".text")
emitln("")
emitln("")
emitln(".global _start")
emitln("")
print("_start:")
emitln("")
emitln("")
emitln("MOV EAX, 4						# print 'Result ='")
emitln("MOV EBX, 1")
emitln("MOV ECX, offset msg")
emitln("MOV EDX, len_msg")
emitln("INT 0x80")
emitln("")
emitln("#### Begin From Let's Build A Compiler")
main.expression        
emitln("#### End From Let's Build A Compiler")
emitln("")
emitln("MOV byte ptr [positive], 1		# initialize positive number yes")
emitln("")
emitln("CMP EAX, 0						# if greater or equals 0 is positive")
emitln("JGE positive_number")
emitln("")
emitln("MOV byte ptr [positive], 0		# else is negative")
emitln("NEG EAX")
emitln("")
print("positive_number:")
emitln("")
emitln("")
emitln("MOV byte ptr [digits], 0		# number of digits")
emitln("")
print("loop:")
emitln("")
emitln("")
emitln("PUSH EAX						# divide for 10")
emitln("MOV EAX, 10")
emitln("MOV ECX, EAX")
emitln("POP EAX")
emitln("XOR EDX, EDX")
emitln("IDIV ECX")
emitln("")
emitln("PUSH EDX						# store the remainder in reverse order")
emitln("")
emitln("ADD byte ptr [digits], 1		# number of digits")
emitln("")
emitln("CMP EAX, 0						# if equals quotient 0")
emitln("JE end")
emitln("") 
print("JMP loop")
emitln("")
emitln("")
print("end:")
emitln("")
emitln("")
emitln("CMP byte ptr [positive], 1		# if is positive number")
emitln("JE loop1")
emitln("")
emitln("MOV EAX, 4						# else print the '-' char")
emitln("MOV EBX, 1")
emitln("MOV ECX, offset char_neg")
emitln("MOV EDX, len_char_neg")
emitln("INT 0x80")
emitln("")
print("loop1:")
emitln("")
emitln("")
emitln("POP EAX							# retrieve the remainders in correct order")
emitln("")
emitln("ADD EAX, 0x30					# number between 0 and 9")
emitln("MOV result, EAX")
emitln("")
emitln("MOV EAX, 4						# print the digits")
emitln("MOV EBX, 1")
emitln("MOV ECX, offset result")
emitln("MOV EDX, 1")
emitln("INT 0x80")
emitln("")
emitln("DEC byte ptr [digits]			# if digits 0 end")
emitln("CMP byte ptr [digits], 0")
emitln("JE end1")
emitln("")
print("JMP loop1")
emitln("")
emitln("")
print("end1:")
emitln("")
emitln("")
emitln("MOV EAX, 4						# print new line")
emitln("MOV EBX, 1")
emitln("MOV ECX, offset newline")
emitln("MOV EDX, 1")
emitln("INT 0x80")
emitln("")
emitln("MOV EAX, 1						# exit")
emitln("MOV EBX, 0")
emitln("INT 0x80")
