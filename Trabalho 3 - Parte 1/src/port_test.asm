.code
; Loads portConfig of both ports to a register, checks if it's set as all input 
; (FFFFh), changes its configuration to FF00h (15:8 input, 7:0 output)

; Sets R0 as FF00h, which'll be used both as an offset and the configuration
; bits
LDH   R0,#FFh   ; r0 <= FF00h

; It's important to keep the lower part of the address in a different register
LDL   R1,#F0h   ; r1 <= 00F0h

; 
LDH   R3,#AAh   ; r2 <= AA00h
LDL   R3,#FFh   ; r2 <= AAFFh



; Writes to portConfig(a/b)
portLoop:
LD    R2,R0,R1 ; r2 <= portConfig(a/b)
NOT   R2,R2    ; r2 <= !r2
JMPZD #01h      ; \ if (r2 != 0), halts
HALT           ; / (meaning that portConfig wasn't correctly set)
ST    R0,R0,R1 ; portConfig(a/b) <= FF00h

; Writes out to port(a/b)
ADDI  R1,#01h   ; r1 <= r1 + 1 (=00F1h/00F4h)
ST    R3,R0,R1 ; portOut(a/b) <= AAFFh

; Reads from port(a/b)
ADDI  R1,#01h   ; r1 <= r1 + 1 (=00F2h/00F5h)
LD    R4,R0,R1 ; r4 <= portIn(a/b)

NOT   R4,R4    ; r4 <= !r4
JMPZD #done    ; port b is receiving FFFFh, thus, exit configuration loop

ADDI  R1,#01h   ; r1 <= r1 + 1 (=00F3h/00F6h)

JMPD  #portLoop

; Reads portOut(a) to R2
done:
SUBI  R1,#06h   ; r1 <= r1 - 5 (=00F1h)
LD    R2,R0,R1 ; r2 <= portOut(a)
LDH   R3,#FFh   ; r3 <= FF00h     \
LDL   R3,#E9h   ; r3 <= FFE9h      > bit masking
AND   R2,R2,R3 ; r2 <= r2 AND r3 /
ST    R2,R0,R1 ; portOut(a) <= r2

HALT
.endcode
