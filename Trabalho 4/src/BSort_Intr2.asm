.code

boot:
; Configuração da porta
; Setar SP = 0x3FF (fim da memória de dados)
; Salta para bubble sort (jmpd #BubbleSort)
	LDL		R0, #Interruption_handler			
	LDINTA 	R0					; Endereco de Interruption_handler

	LDL 	R0, #C0h
	LDH 	R1, #FFh
	LDL 	R1, #F7h			
	ST 		R0, R1, R15 		; Inicializacao da Mask da PIC

	LDH 	R0, #input_array
	LDL 	R0, #input_array 	
	LDH 	R1, #to_remove
	LDL 	R1, #to_remove
	LDH 	R2, #input_pointer
	LDL 	R2, #input_pointer
	ST 		R0, R1, R15			; Inicializacao do ponteiro de remocao do array do input_peripheral
	ST 		R0, R2, R15 		; Inicializacao do ponteiro do array de input_peripheral

	LDL 	R1, #input_peripheral_handler
	LDH 	R1, #input_peripheral_handler
	LDL 	R2, #speech_synthesizer_handler
	LDH 	R2, #speech_synthesizer_handler
	LDL 	R0, #interruption_array
	LDH 	R0, #interruption_array ; R0 <= &interruption_array
	ADDI 	R0, #6h 				; R0 <= &interruption_array[6]
	ST 		R1, R0, R15 			; interruption_array[6] <= #input_peripheral_handler
	ADDI 	R0, #1h 				; R0 <= &interruption_array[7]
	ST 		R2, R0, R15 			; interruption_array[7] <= #speech_synthesizer_handler

	LDL 	R0, #F0h			; setup das portas
	LDH 	R0, #FFh			; R0 recebe endereco de port_a			
	LDH 	R1, #E0h
	LDL 	R1, #00h
	ST 		R1, R0, R15			; port_a <= "E000"
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
	PUSHF						; Salvamento de contexto

	LDH 	R0, #FFh
	LDL 	R0, #F6h 			
	LD 		R8, R0, R15 		; R8 <= "FFF6" IRQ_ID
	LDH 	R8, #00h

	LDH 	R0, #interruption_array
	LDL 	R0, #interruption_array
	ADD 	R0, R0, R8  	 		; R0 <= &interruption_array[R8] / R8 == IRQ_ID
	LD 		R0, R0, R15 			; R0 <= interruption_array[R8]
	JSR 	R0 						; Pula para endereco da interrupcao indidcada em interruption_array[R8]

interruption_end:
	LDH 	R0, #FFh
	LDL 	R0, #F8h
	ST 		R8, R0, R15 	 	; INT_ACK <= IRQ_ID
	POPF
	POP 	R0
	POP 	R1
	POP 	R2
	POP 	R3
	POP 	R4
	POP 	R5
	POP 	R6
	POP 	R7
	POP 	R8
	RTI 						; Retorno de contexto

input_peripheral_handler:
	LDH 	R0, #FFh
	LDL 	R0, #F5h			; R2 <= "FFF5" port_b input
	LDH 	R5, #FFh
	LDL 	R5, #F1h 			; R0 <= "FFF1" port_a output

	LD 		R1, R0, R15 		; R1 recebe dados em port_b
	LDH 	R2, #08h
	LDL 	R2, #00h			; R2 <= x"0800", para mandar 1 em data_ack
	ST 		R2, R5, R15 		; Manda 1 em data_ack
	ST 		R15, R5, R15 		; Manda 0 em data_ack
	LDH 	R3, #input_pointer
	LDL 	R3, #input_pointer	; R3 <= &input_pointer
	LD 		R4, R3, R15			; R4 <= input_pointer
	ST 		R1, R4, R15			; input_pointer <= R1
	ADDI 	R4, #01h
	ST 		R4, R3, R15			; input_pointer++
	RTS

speech_synthesizer_handler:
	LDH 	R5, #FFh
	LDL 	R5, #F1h			; R5 <= output de port_a

	LDH	 	R0, #to_remove
	LDL 	R0, #to_remove 		; R2 <= &to_remove
	LD 		R1, R0, R15			; R1 <= to_remove
	LDH 	R2, #input_pointer
	LDL 	R2, #input_pointer 	; R2 <= &input_pointer
	LD 		R3, R2, R15			; R3 <= input_pointer
	SUB 	R4, R3, R1			; R4 <= input_pointer - to_remove
	JMPZD 	#empty

	LD 		R4, R1, R15 		; R4 <= *to_remove
	LDH 	R4, #02h			; Carrega bit 10 com 1, para ALD
	ST 		R4, R5, R15 		; output de port_a <= R4
	ST 		R15, R5, R15		; Manda 0 em ALD
	ST 		R15, R1, R15 		; Zera a posicao do array indicada por to_remove
	ADDI 	R1, #01h
	ST 		R1, R0, R15
	RTS

empty:
	LDH 	R0, #02h			; Carrega bit 10 com 1, para ALD
	LDL 	R0, #FFh
	ST 		R0, R5, R15			; Guarda R4 no registrador de output
	ST 		R15, R5, R15		; Manda 0 em ALD
	RTS


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

    array:     			db #20h, #19h, #18h, #17h, #16h, #15h, #14h, #13h, #12h, #11h, #10h, #9h, #8h, #7h, #6h, #5h, #4h, #3h, #2h, #1h
    size:      			db #20    ; 'array' size
    interruption_array: db #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h
    input_size:			db #20
    input_pointer: 		db #0h
    to_remove: 			db #0h
    input_array: 		db #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h


.enddata