; Copyright (C) 2024 Devin Rockwell
; 
; This file is part of flox.
; 
; flox is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
; 
; flox is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with flox.  If not, see <http://www.gnu.org/licenses/>.

format ELF64

include 'memory.inc'

extrn reallocate
extrn printf

    section ".text"
    public initValueArray ; void (ValueArray *array)
initValueArray:
    push rbp
    mov rbp, rsp

    mov dword [rdi], 0 ; count = 0
    mov dword [rdi + 4], 0 ; capacity = 0
    mov qword [rdi + 8], 0 ; code = NULL

    mov rsp, rbp
    pop rbp
    ret

    public writeValueArray ; void (ValueArray *array, uint8_t byte)
writeValueArray:
    push rbp
    mov rbp, rsp

    mov eax, dword [rdi] ; rax = count
    add eax, 1 ; rax++
    cmp dword [rdi + 4], eax
    jge endif ; capacity is sufficient
    mov ecx, dword [rdi + 4] ; rcx = capacity
    push rcx
    push rax
    GROW_CAPACITY ecx
    mov [rdi + 4], ecx
    ;call reallocate
    pop rcx
    push rdi
    push rbx ; alignment
    sub rsp,0x10
    movdqu [rsp],xmm0
    mov rsi, rcx ; rsi = oldCapacity
    mov rdx, [rdi + 4] ; rdx = newCapacity
    mov rdi, [rdi + 8] ; rdi = code
    call reallocate
    movdqu xmm0,[rsp]
    add rsp,0x10
    pop rbx
    pop rdi
    mov qword [rdi + 8], rax ; code = rax
    pop rax

endif:
    mov rax, [rdi + 8] ; rax = code
    xor rdx, rdx
    mov edx, dword [rdi] ; rdx = count
    movq [rdx + rax], xmm0 ; code[count] = sil
    add dword [rdi], 1 ; count++

    mov rsp, rbp
    pop rbp
    ret

    public freeValueArray
freeValueArray:
    push rbp
    mov rbp, rsp

    mov rsi, [rdi + 4] ; rsi = capacity
    mov rdx, 0
    push rdi
    mov rdi, [rdi + 8] ; rdi = code
    call reallocate
    pop rdi

    call initValueArray

    mov rsp, rbp
    pop rbp
    ret

    public printValue
printValue:
    push rbp
    mov rbp, rsp

    mov rdi, printValueFormat
    mov rax, 1
    call printf

    mov rsp, rbp
    pop rbp
    ret

section ".data"
printValueFormat db "%g", 0
