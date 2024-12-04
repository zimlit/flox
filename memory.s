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

include "memory.inc"

extrn free
extrn realloc
extrn exit

section ".text"

    public reallocate ; void *(void *pointer, size_t oldSize, size_t newSize)
reallocate:
    push rbp
    mov rbp, rsp

    cmp rdx, 0
    jne endif ; newSize != 0
    call plt free
    jmp return
endif:
    mov rdx, rsi
    call plt realloc
    cmp rax, 0
    jne return
    ; OOM exit
    mov rdi, 1
    call plt exit
return:
    mov rsp, rbp
    pop rbp
    ret
