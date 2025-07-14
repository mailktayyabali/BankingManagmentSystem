.model small
.stack 100h
.data
  
    balance dw 0                 
    account_created db 0       
    logged_in db 0                

    crlf db 0Dh, 0Ah, '$'         

   
    correct_username db 'admin', 0
    correct_password db '1234', 0

   
    msg_welcome db 0Dh, 0Ah, '                ==============================', 0Dh, 0Ah
         db '                          Welcome to ', 0Dh, 0Ah
         db '                    BANKING SYSTEM PROJECT', 0Dh, 0Ah
         db '                ==============================$'

   
    menu db 0Dh, 0Ah
         db '         1. Deposit Amount', 0Dh, 0Ah
         db '         2. Withdraw Amount', 0Dh, 0Ah
         db '         3. Check Balance', 0Dh, 0Ah
         db '         4. Exit Program', 0Dh, 0Ah
         db '        --------------------------', 0Dh, 0Ah
         db '        Your choice: $'

  
    msg_login db 0Dh, 0Ah, 'Login Required', 0Dh, 0Ah, '$'
    msg_username db 0Dh, 0Ah, 'Enter Username: $'
    msg_password db 0Dh, 0Ah, 'Enter Password: $'
    msg_login_fail db 0Dh, 0Ah, 'Invalid username or password!$'
    msg_login_success db 0Dh, 0Ah, 'Login Successful!$'
    msg_deposit       db 0Dh, 0Ah, 'Enter amount to deposit (positive only): $'
    msg_dep_done      db 0Dh, 0Ah, 'Deposit Successful!$'
    msg_withdraw      db 0Dh, 0Ah, 'Enter amount to withdraw (positive only): $'
    msg_wd_success    db 0Dh, 0Ah, 'Withdraw Successful!$'
    msg_wd_fail       db 0Dh, 0Ah, 'Insufficient Balance!$'
    msg_check         db 0Dh, 0Ah, 'Your Current Balance is: $'
    msg_invalid       db 0Dh, 0Ah, 'Invalid choice! Please try again.$'
    msg_invalid_input db 0Dh, 0Ah, 'Invalid input! Enter only positive digits.$'

  
    username db 20, ?, 20 dup('$')    
    password db 20, ?, 20 dup('$')  
    inputBuffer db 5, ?, 5 dup('$')   

.code
main:
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    lea dx, msg_welcome
    int 21h

login_prompt:
    mov ah, 09h
    lea dx, msg_login
    int 21h

    mov ah, 09h
    lea dx, msg_username
    int 21h
    lea dx, username
    mov ah, 0Ah
    int 21h

    mov ah, 09h
    lea dx, msg_password
    int 21h
    lea dx, password
    mov ah, 0Ah
    int 21h

  
    lea si, username+2
    lea di, correct_username
compare_user_loop:
    mov al, [di]
    cmp al, 0
    je check_pass
    mov bl, [si]
    cmp al, bl
    jne login_failed
    inc si
    inc di
    jmp compare_user_loop

check_pass:
    lea si, password+2
    lea di, correct_password
compare_pass_loop:
    mov al, [di]
    cmp al, 0
    je login_success
    mov bl, [si]
    cmp al, bl
    jne login_failed
    inc si
    inc di
    jmp compare_pass_loop

login_failed:
    mov ah, 09h
    lea dx, msg_login_fail
    int 21h
    jmp login_prompt

login_success:
    mov ah, 09h
    lea dx, msg_login_success
    int 21h
    mov logged_in, 1
    jmp start_menu

start_menu:
    mov ah, 09h
    lea dx, crlf
    int 21h

    mov ah, 09h
    lea dx, menu
    int 21h
    jmp read_choice

read_choice:
    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 1
    je deposit
    cmp al, 2
    je withdraw
    cmp al, 3
    je check_balance
    cmp al, 4
    je exit_program
    jmp invalid_choice

invalid_choice:
    mov ah, 09h
    lea dx, msg_invalid
    int 21h
    jmp start_menu


deposit:
    mov ah, 09h
    lea dx, msg_deposit
    int 21h
    lea dx, inputBuffer
    mov ah, 0Ah
    int 21h
    call get_number
    cmp bx, 0
    je start_menu
    cmp ax, 0
    jbe invalid_input
    add balance, ax
    mov ah, 09h
    lea dx, msg_dep_done
    int 21h
    jmp start_menu

withdraw:
    mov ah, 09h
    lea dx, msg_withdraw
    int 21h
    lea dx, inputBuffer
    mov ah, 0Ah
    int 21h
    call get_number
    cmp bx, 0
    je start_menu
    cmp ax, 0
    jbe invalid_input
    mov bx, balance
    cmp bx, ax
    jb not_enough
    sub bx, ax
    mov balance, bx
    mov ah, 09h
    lea dx, msg_wd_success
    int 21h
    jmp start_menu

not_enough:
    mov ah, 09h
    lea dx, msg_wd_fail
    int 21h
    jmp start_menu

check_balance:
    mov ah, 09h
    lea dx, msg_check
    int 21h
    mov ax, balance
    call print_number
    jmp start_menu

exit_program:
    mov ah, 4Ch
    int 21h



get_number proc
    lea si, inputBuffer + 2
    mov cl, inputBuffer + 1
validate_loop:
    mov al, [si]
    cmp al, 0Dh
    je continue_parse
    cmp al, '0'
    jb invalid_input
    cmp al, '9'
    ja invalid_input
    inc si
    loop validate_loop

continue_parse:
    xor ax, ax
    xor bx, bx
    lea si, inputBuffer + 2
    mov cl, inputBuffer + 1
parse_digits:
    mov bl, [si]
    cmp bl, 0Dh
    je done_parse
    sub bl, '0'
    mov bh, 0
    mov cx, 10
    mul cx
    add ax, bx
    inc si
    dec cl
    jmp parse_digits

done_parse:
    mov bx, 1
    ret

invalid_input:
    mov ah, 09h
    lea dx, msg_invalid_input
    int 21h
    xor bx, bx
    ret
get_number endp


print_number proc
    mov bx, 10
    xor cx, cx
next_digit:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne next_digit
print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop
    ret
print_number endp

end main