; Copyright (C) 2024 Devin Rockwell

; This file is part of flox.

; flox is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; flox is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with flox.  If not, see <https://www.gnu.org/licenses/>.

format ELF64

include "vm.inc"

extrn printValue
extrn printf
extrn disassembleInstruction

section ".text"
public initVM
initVM:
    push rbp
    mov rbp, rsp

    lea r8, qword [vm+24]
    mov qword [vm+32+STACK_MAX*8], r8

    mov rsp, rbp
    pop rbp
    ret

public freeVM
freeVM:
    push rbp
    mov rbp, rsp

    mov rsp, rbp
    pop rbp
    ret

macro vpush value
{
    mov r8, [vm+32+STACK_MAX*8]
    movq [r8], value
    add qword [vm+32+STACK_MAX*8], 8
}

macro vpop target
{
    sub qword [vm+32+STACK_MAX*8], 8
    mov r8, [vm+32+STACK_MAX*8]
    movq target, [r8]
}

macro READ_BYTE 
{
    mov r8, [vm+8]
    mov byte cl, [r8]
    inc qword [vm+8]
}
macro READ_CONSTANT
{
    READ_BYTE
    mov r8, [vm]
    mov r8, [r8+32]
    movq xmm0, [r8+rcx]
}

macro BINARY_OP instr
{
    vpop xmm1
    vpop xmm0
    instr xmm0, xmm1
    vpush xmm0
}

run:
    push rbp
    mov rbp, rsp

for:
    if DEBUG_TRACE 
        mov rdi, padding
        call printf
        lea r8, [vm+24]
stack_loop:
        mov r9, [vm+32+STACK_MAX*8]
        cmp r8, r9
        jge end_loop
        mov rdi, lb
        push r8
        push r9
        call printf
        pop r9
        pop r8
        movq xmm0, [r8]
        push r8
        push r9
        call printValue
        mov rdi, rbr
        call printf
        pop r9
        pop r8
        add r8, 8
        jmp stack_loop
end_loop:
        mov rdi, nl
        call printf

        mov rdi, [vm]
        mov rsi, [vm+8]
        sub rsi, [rdi+8]
        call disassembleInstruction
    end if

    READ_BYTE
    cmp rcx, 7
    jge endSwitch
    lea rax, [jump_table + rcx*8]
    jmp qword [rax]

op_constant:
    push rdi
    push rsi
    READ_CONSTANT
    vpush xmm0
    pop rsi
    pop rdi
    jmp endSwitch
op_add:
    BINARY_OP addsd
    jmp endSwitch
op_subtract:
    BINARY_OP subsd
    jmp endSwitch
op_multiply:
    BINARY_OP mulsd
    jmp endSwitch
op_divide:
    BINARY_OP divsd
    jmp endSwitch
op_negate:
    vpop xmm0
    mulsd xmm0, [n1]
    vpush xmm0
    jmp endSwitch
op_return:
    vpop xmm0
    call printValue
    mov rdi, nl
    call printf
    mov rax, INTERPERET_OK
    jmp endRun
endSwitch:
    jmp for

endRun:
    mov rsp, rbp
    pop rbp
    ret

public interpret
interpret:
    push rbp
    mov rbp, rsp

    mov qword [vm], rdi
    mov r8, [rdi+8]
    mov qword [vm+8], r8

    call run

    mov rsp, rbp

    pop rbp
    ret

section ".data"
jump_table: dq op_constant, op_add, op_subtract, op_multiply, op_divide, op_negate, op_return

nl: db 10, 0
padding: db "          ", 0
lb: db "[ ", 0
rbr: db " ]", 0
n1:  dq -1.0

section ".bss"
vm: rq 4+STACK_MAX