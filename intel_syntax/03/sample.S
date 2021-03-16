.intel_syntax noprefix

.data

        msg:
                .ascii "Result = "
                len_msg = . - msg
        char_neg:
                .ascii "-"
                len_char_neg = . - char_neg
        newline:
                .ascii "\n"
        result:
                .long 0
        positive:
                .long 0
        digits:
                .long 0

.text

        .global _start

_start:

        MOV EAX, 4                                       # print 'Result ='
        MOV EBX, 1
        MOV ECX, offset msg
        MOV EDX, len_msg
        INT 0x80

        #### Begin From Let's Build A Compiler
        MOV EAX, 42
        PUSH EAX
        MOV EAX, 33
        POP ECX
        ADD EAX, ECX
        PUSH EAX
        MOV EAX, 20
        PUSH EAX
        MOV EAX, 90
        POP ECX
        IMUL ECX
        PUSH EAX
        MOV EAX, 6
        MOV ECX, EAX
        POP EAX
        XOR EDX, EDX
        IDIV ECX
        POP ECX
        SUB EAX, ECX
        NEG EAX
        #### End From Let's Build A Compiler

        MOV byte ptr [positive], 1              # initialize positive number yes

        CMP EAX, 0                                       # if greater or equals 0 is positive
        JGE positive_number

        MOV byte ptr [positive], 0              # else is negative
        NEG EAX

positive_number:

        MOV byte ptr [digits], 0                # number of digits

loop:

        PUSH EAX                                         # divide for 10
        MOV EAX, 10
        MOV ECX, EAX
        POP EAX
        XOR EDX, EDX
        IDIV ECX

        PUSH EDX                                         # store the remainder in reverse order

        ADD byte ptr [digits], 1                # number of digits

        CMP EAX, 0                                       # if equals quotient 0
        JE end

JMP loop

end:

        CMP byte ptr [positive], 1              # if is positive number
        JE loop1

        MOV EAX, 4                                       # else print the '-' char
        MOV EBX, 1
        MOV ECX, offset char_neg
        MOV EDX, len_char_neg
        INT 0x80

loop1:

        POP EAX                                          # retrieve the remainders in correct order

        ADD EAX, 0x30                                   # number between 0 and 9
        MOV result, EAX

        MOV EAX, 4                                       # print the digits
        MOV EBX, 1
        MOV ECX, offset result
        MOV EDX, 1
        INT 0x80

        DEC byte ptr [digits]                   # if digits 0 end
        CMP byte ptr [digits], 0
        JE end1

JMP loop1

end1:

        MOV EAX, 4                                       # print new line
        MOV EBX, 1
        MOV ECX, offset newline
        MOV EDX, 1
        INT 0x80

        MOV EAX, 1                                       # exit
        MOV EBX, 0
        INT 0x80
