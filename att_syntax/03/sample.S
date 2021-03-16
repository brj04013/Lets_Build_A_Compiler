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

        movl $4, %eax                                    # print 'Result ='
        movl $1, %ebx
        movl $msg, %ecx
        movl $len_msg, %edx
        int $0x80

        #### Begin From Let's Build A Compiler
        movl $42,%eax
        pushl %eax
        movl $33,%eax
        popl %ecx
        addl %ecx,%eax
        pushl %eax
        movl $20,%eax
        pushl %eax
        movl $90,%eax
        popl %ecx
        imull %ecx
        pushl %eax
        movl $6,%eax
        movl %eax,%ecx
        popl %eax
        xorl %edx,%edx
        idivl %ecx
        popl %ecx
        subl %ecx,%eax
        negl %eax
        #### End From Let's Build A Compiler

        movl $1, positive                                # initialize positive number yes

        cmpl $0, %eax                                    # if greater or equals 0 is positive
        jge positive_number

        movl $0, positive                                # else is negative
        negl %eax

positive_number:

        movl $0, digits                                  # number of digits

loop:

        pushl %eax                                       # divide for 10
        movl $10,%eax
        movl %eax,%ecx
        popl %eax
        xorl %edx,%edx
        idivl %ecx

        pushl %edx                                       # store the remainder in reverse order

        addl $1, digits                                  # number of digits

        cmpl $0, %eax                                    # if equals quotient 0
        je end

jmp loop

end:

        cmpl $1, positive                                # if is positive number
        je loop1

        movl $4, %eax                                    # else print the '-' char
        movl $1, %ebx
        movl $char_neg, %ecx
        movl $len_char_neg, %edx
        int $0x80

loop1:

        popl %eax                                        # retrieve the remainders in correct order

        addl $0x30, %eax                                 # number between 0 and 9
        movl %eax, result

        movl $4, %eax                                    # print the digits
        movl $1, %ebx
        movl $result, %ecx
        movl $1, %edx
        int $0x80

        decl digits                                      # if digits 0 end
        cmpl $0, digits
        je end1

jmp loop1

end1:

        movl $4, %eax                                    # print new line
        movl $1, %ebx
        movl $newline, %ecx
        movl $1, %edx
        int $0x80

        movl $1, %eax                                    # exit
        movl $0, %ebx
        int $0x80
