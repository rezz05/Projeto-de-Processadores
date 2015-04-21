.code

boot:
; Configuração da porta
; Setar SP = 0x3FF (fim da memória de dados)
; Salta para bubble sort (jmpd #BubbleSort)
	LDL		R0, #0Fh
	LDINTA 	R0
	LDL 	R0, #F0h			; setup das portas
	LDH 	R0, #FFh			; R0 recebe endereco de port_a			
	LDH 	R1, #81h
	ST 		R1, R0, R15			; port_a <= "8100"
	LDH 	R1, #FFh			; R1 recebe endereco de port_b
	LDL 	R1, #F3h
	LDH 	R0, #FFh
	LDL 	R0, #FFh			
	ST 		R0, R1, R15 		; port_b <= "1111"
	LDH 	R0, #03h
	LDSP 	R0					; SP <= "03FF"
	ENI
	JMPD 	#bubble_sort


Interruption_handler:
; Salvar contexto
; Ler dado do input_peripheral
; Escrever dado no speech_synthesizer
; Recuperar contexto
; Retornar ao bubbleSort (rti)
	PUSH	R8
	PUSH	R7
	PUSH	R6
	PUSH	R5
	PUSH	R4
	PUSH	R3
	PUSH	R2
	PUSH	R1
	PUSH	R0

	LDH 	R0, #FFh
	LDL 	R0, #F1h 			; R0 <= "FFF1" port_a output
	LDH 	R1, #FFh
	LDL 	R1, #F2h 			; R1 <= "FFF2" port_a input
	LDH 	R2, #FFh
	LDL 	R2, #F5h			; R2 <= "FFF5" port_b input
	LDH 	R7, #01h 			; mascara para o bit 8
	LDL 	R7, #00h
	XOR 	R15, R15, R15

	LD 		R4, R2, R15 		; R4 recebe dados em port_b
	LDH 	R5, #08h
	LDL 	R5, #00h			; R5 <= x"0800", para mandar 1 em data_ack
	ST 		R5, R0, R15 		; Manda 1 em data_ack
	ST 		R15, R0, R15 		; Manda 0 em data_ack

	ADD 	R5, R4, R15 		; Copia R4(Dado a guardar) para R5
	XOR 	R6, R6, R6
	ADDI 	R6, #08h			
shift_right_loop:				; Shift right para R5 ficar com a parte alta de R4
	SR0 	R5, R5
	SUBI 	R6, #01h
	JMPZD 	#ss_polling_high
	JMPD 	#shift_right_loop

ss_polling_high:
	LD 		R8, R1, R15	 		; R8 recebe input de port_a
	AND 	R8, R8, R7			; Mascaramento para bit 8
	JMPZD	#ss_polling_high	; Se flag zero, SBY ainda eh 0

	LDH 	R5, #02h			; Carrega bit 10 com 1, para ALD
	ST 		R5, R0, R15			; Guarda R5 no registrador de output
	ST 		R15, R0, R15		; Manda 0 em ALD

ss_polling_low:
	LD 		R5, R1, R15	 		; R5 recebe input de port_a
	AND 	R5, R5, R7			; Mascaramento para bit 8
	JMPZD	#ss_polling_low		; Se flag zero, SBY ainda eh 0

	LDH 	R4, #02h			; Carrega bit 10 com 1, para ALD
	ST 		R4, R0, R15			; Guarda R4 no registrador de output
	ST 		R15, R0, R15		; Manda 0 em ALD

	POP 	R0
	POP 	R1
	POP 	R2
	POP 	R3
	POP 	R4
	POP 	R5
	POP 	R6
	POP 	R7
	POP 	R8
	RTI

; ================ END INTERRUPTION ============================

bubble_sort:

    ; INITIALIZATION CODE
    XOR R0, R0, R0          ; R0 <- 0
    
    LDH R1, #ARRAY          ;
    LDL R1, #ARRAY          ; R1 <- &ARRAY
    
    LDH R2, #SIZE           ;
    LDL R2, #SIZE           ; R2 <- &SIZE
    LD 	R2, R2, R0           ; R2 <- SIZE
    
    ADD R3, R2, R1          ; R3 POINTS THE END OF ARRAY (RIGHT AFTER THE LAST ELEMENT)
    
    LDL R4, #0              ;
    LDH R4, #1              ; R4 <- 1
   
   
; MAIN CODE
SCAN:
    ADDI R4, #0             ; VERIFIES IF THERE WAS ELEMENT SWAPING
    JMPZD #END              ; IF R4 = 0 THEN NO ELEMENT SWAPING
    
    XOR R4, R4, R4          ; R4 <- 0 BEFORE EACH PASS
    
    ADD R5, R1, R0          ; R5 POINTS THE FIRST ARRAR ELEMENT
    
    ADD R6, R1, R0          ;
    ADDI R6, #1             ; R6 POINTS THE SECOND ARRAY ELEMENT
    
; READ TWO CONSECUTIVE ELEMENTS AND COMPARES THEM    
LOOP:
    LD R7, R5, R0           ; R7 <- ARRAY[R5]
    LD R8, R6, R0           ; R8 <- ARRAY[R6]
    SUB R2, R8, R7          ; IF R8 > R7, NEGATIVE FLAG IS SET
    JMPND #SWAP             ; (IF ARRAY[R5] > ARRAY[R6] JUMP)
    
; INCREMENTS THE INDEX REGISTERS AND VERIFIES IS THE PASS IS CONCLUDED
CONTINUE:
    ADDI R5, #1             ; R5++
    ADDI R6, #1             ; R6++
    
    SUB R2, R6, R3          ; VERIFIES IF THE END OF ARRAY WAS REACHED (R6 = R3)
    JMPZD #SCAN             ; IF R6 = R3 JUMP
    JMPD #LOOP              ; ELSE, THE NEXT TWO ELEMENTS ARE COMPARED


; SWAPS TWO ARRAY ELEMENTS (MEMORY)
SWAP:
    ST R7, R6, R0           ; ARRAY[R6] <- R7
    ST R8, R5, R0           ; ARRAY[R5] <- R8
    LDL R4, #1              ; SET THE ELEMENT SWAPING (R4 <- 1)
    JMPD #CONTINUE
    
    
end:    
    HALT                    ; Suspend the execution

.endcode

; Data area (variables)
.data

    array:     db #20h, #19h, #18h, #17h, #16h, #15h, #14h, #13h, #12h, #11h, #10h, #9h, #8h, #7h, #6h, #5h, #4h, #3h, #2h, #1h
    size:      db #20    ; 'array' size  

.enddata