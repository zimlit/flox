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

OP_CONSTANT = 0
OP_ADD = 1
OP_SUBTRACT = 2
OP_MULTIPLY = 3
OP_DIVIDE = 4
OP_NEGATE = 5
OP_RETURN = 6

; Chunk memory format (48 bytes)
; dword count
; dword capacity
; pointer code
; pointer lines;
; ValueArray constants (16 bytes)