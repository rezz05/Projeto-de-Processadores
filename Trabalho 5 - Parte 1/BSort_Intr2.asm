.code

boot:
; Configuração da porta
; Setar SP = 0x3FF (fim da memória de dados)
; Salta para bubble sort (jmpd #BubbleSort)
	LDL		R0, #Interruption_handler			
	LDINTA 	R0					; Endereco de Interruption_handler

	LDL 	R0, #01h 			; Mask Inicial da PIC
	LDH 	R1, #FFh
	LDL 	R1, #F7h			
	ST 		R0, R1, R15 		; Inicializacao da Mask da PIC

	LDH 	R0, #queue
	LDL 	R0, #queue 	
	LDH 	R1, #to_remove
	LDL 	R1, #to_remove
	LDH 	R2, #to_store
	LDL 	R2, #to_store
	ST 		R0, R1, R15			; Inicializacao do ponteiro de remocao do array do input_peripheral
	ST 		R0, R2, R15 		; Inicializacao do ponteiro do array de input_peripheral

	LDH 	R1, #queue_end
	LDL	 	R1, #queue_end 	 	; R1 <= &queue_end
	LDH 	R2, #queue_max_size
	LDL 	R2, #queue_max_size ; R1 <= &queue_max_size
	LD 		R2, R2, R15 		; R2 <= queue_max_size
	ADD 	R0, R0, R2 			; R0 <= &queue + queue_max_size
	SUBI 	R0, #1h
	ST 		R0, R1, R15 		; queue_end <= R0

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

	LDH 	R0, #04h
	LDL 	R0, #00h		
	LDH 	R1, #FFh
	LDL 	R1, #F9h			
	ST 		R0, R1, R15 		; Timer <= x"100"

	ENI
	JMPD 	#bubble_sort


Interruption_handler:
; Salvar contexto
; Ler dado do input_peripheral
; Escrever dado no speech_synthesizer
; Recuperar contexto
; Retornar ao bubbleSort (rti)
	LDH 	R13, #tcb_pointer
	LDL 	R13, #tcb_pointer
	LD 		R13, R13, R15 		; R13 <= tcb_pointer

	CPSP 	R14
	ST 		R14, R13, R15 		; tcb_array[0] <= SP

	PUSHF
	ADDI 	R13, #1h 			; tcb_pointer++
	CPSP 	R14 				; R14 <= SP
	ADDI 	R14, #1h
	LD 		R14, R14, R15 		; R14 <= Flags
	ST 		R14, R13, R15 		; tcb_array[1] <= Flags

	ADDI 	R13, #1h 			; tcb_pointer++
	CPSP 	R14 				; R14 <= SP
	ADDI 	R14, #2h
	LD 		R14, R14, R15 		; R14 <= PC
	ST 		R14, R13, R15 		; tcb_array[2] <= PC

	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R0, R13, R15 		; tcb_array[3] <= R0
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R1, R13, R15 		; tcb_array[4] <= R1
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R2, R13, R15 		; tcb_array[5] <= R2
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R3, R13, R15 		; tcb_array[6] <= R3
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R4, R13, R15 		; tcb_array[7] <= R4
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R5, R13, R15 		; tcb_array[8] <= R5
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R6, R13, R15 		; tcb_array[9] <= R6
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R7, R13, R15 		; tcb_array[10] <= R7
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R8, R13, R15 		; tcb_array[11] <= R8
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R9, R13, R15 		; tcb_array[12] <= R9
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R10, R13, R15 		; tcb_array[13] <= R10
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R11, R13, R15 		; tcb_array[14] <= R11
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R12, R13, R15 		; tcb_array[15] <= R12

	LDH 	R14, #tcb_pointer
	LDL 	R14, #tcb_pointer
	ST 		R13, R14, R15 		; tcb_pointer <= R13

	LDH 	R0, #FFh
	LDL 	R0, #F6h 			
	LD 		R8, R0, R15 		; R8 <= "FFF6" IRQ_ID
	LDH 	R8, #00h

	LDH 	R0, #interruption_array
	LDL 	R0, #interruption_array
	ADD 	R0, R0, R8  	 		; R0 <= &interruption_array[R8] / R8 == IRQ_ID
	LD 		R0, R0, R15 			; R0 <= interruption_array[R8]
	PUSH 	R8
	JSR 	R0 						; Pula para endereco da interrupcao indidcada em interruption_array[R8]

interruption_end:
	LDH 	R0, #FFh
	LDL 	R0, #F8h
	POP 	R8
	ST 		R8, R0, R15 	 	; INT_ACK <= IRQ_ID

	LDH 	R13, #tcb_pointer
	LDL 	R13, #tcb_pointer
	LD 		R14, R13, R15 		; R14 <= tcb_pointer

	LD 		R12, R14, R15 		; R12 <= tcb_array[15]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R11, R14, R15 		; R11 <= tcb_array[14]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R10, R14, R15 		; R10 <= tcb_array[13]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R9, R14, R15 		; R9 <= tcb_array[12]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R8, R14, R15 		; R8 <= tcb_array[11]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R7, R14, R15 		; R7 <= tcb_array[10]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R6, R14, R15 		; R6 <= tcb_array[9]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R5, R14, R15 		; R5 <= tcb_array[8]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R4, R14, R15 		; R4 <= tcb_array[7]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R3, R14, R15 		; R3 <= tcb_array[6]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R2, R14, R15 		; R2 <= tcb_array[5]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R1, R14, R15 		; R1 <= tcb_array[4]
	SUBI 	R14, #1h 			; tcb_pointer--
	LD 		R0, R14, R15 		; R0 <= tcb_array[3]
	SUBI 	R14, #1h 			; tcb_pointer--

	LD 		R13, R14, R15 		; R13 <= PC | tcb_array[2]
	SUBI 	R14, #1h 			; tcb_pointer--
	PUSH 	R14 				; Guarda tcb_pointer na pilha
	CPSP 	R14
	ADDI 	R14, #3h
	ST 		R13, R14, R15		; Coloca PC no topo da pilha

	POP 	R14
	LD 		R13, R14, R15 		; R13 <= flags | tcb_array[1]
	SUBI 	R14, #1h
	PUSH 	R14 				; Guard tcb_pointer na pilha
	CPSP 	R14
	ADDI 	R14, #2h
	ST 		R13, R14, R15 		; Guarda Flags na pilha

	POP 	R14
	LD 		R13, R14, R15 		; R13 <= SP | tcb_array[0]
	PUSH 	R13
	LDH 	R13, #tcb_pointer
	LDL 	R13, #tcb_pointer
	ST 		R14, R13, R15 		; tcb_pointer <= R14

	POP 	R13 				; R13 <= SP
	POPF 						; Restaura flags
	LDSP 	R13 				; Restaura SP

	RTI 						; Retorno de contexto
	
; ============== Timer Handler ===========================
timer_handler:
	LDH 	R0, #timer_interrupts
	LDL 	R0, #timer_interrupts
	LD 		R1, R0, R15
	ADDI 	R1, #1h
	ST 		R1, R0, R15 			; timer_interrupts++

	LDH 	R0, #04h
	LDL 	R0, #00h		
	LDH 	R1, #FFh
	LDL 	R1, #F9h			
	ST 		R0, R1, R15 		; Timer <= x"100"
	RTS


; ============= INPUT PERIPHERAL HANDLER =====================
input_peripheral_handler:
	LDH 	R0, #FFh
	LDL 	R0, #F5h			; R2 <= "FFF5" port_b input
	LDH 	R5, #FFh
	LDL 	R5, #F1h 			; R0 <= "FFF1" port_a output

	LDH 	R1, #queue_size
	LDL	 	R1, #queue_size
	LD 		R1, R1, R15	 			; R1 <= queue_size
	LDH 	R2, #queue_max_size
	LDL	 	R2, #queue_max_size
	LD 		R2, R2, R15
	SUB 	R1, R2, R1 	 			; R0 <= queue_size - queue_max_size
	JMPZD 	#full

	LD 		R1, R0, R15 		; R1 recebe dados em port_b
	LDH 	R2, #08h
	LDL 	R2, #00h			; R2 <= x"0800", para mandar 1 em data_ack
	ST 		R2, R5, R15 		; Manda 1 em data_ack
	ST 		R15, R5, R15 		; Manda 0 em data_ack
	LDH 	R3, #to_store
	LDL 	R3, #to_store		; R3 <= &to_store
	LD 		R4, R3, R15			; R4 <= to_store
	ST 		R1, R4, R15			; to_store <= R1

	LDH 	R0, #queue_size
	LDL	 	R0, #queue_size
	LD 		R1, R0, R15	
	ADDI 	R1, #1h 			; R1++
	ST 		R1, R0, R15 		; queue_size++
	JMPD 	#skip1

full:
	LDH 	R1, #FFh
	LDL 	R1, #F7h 			; R1 <= &MASK
	LD 		R2, R1, R15 		; R2 <= MASK
	LDH 	R2, #00h 			; Fix da parte alta
	LDH 	R0, #00h
	LDL 	R0, #BFh 			; Mascara para zerar bit 6
	AND 	R0, R2, R0 			; R0 <= MASK AND "BF"
	ST 		R0, R1, R15 		; MASK <= R1 | Zera o irq do Input Peripheral
	RTS

skip1:
	LDH 	R0, #queue_end
	LDL 	R0, #queue_end
	LD 		R0, R0, R15
	SUB 	R0, R0, R4	 		; R0 <= queue_end - to_store
	JMPZD 	#to_store_queue_end ; se queue_end == to_store

	ADDI 	R4, #01h 			; to_store++
	JMPD 	#end_input_hnd

; Bloco que faz to_store voltar para o inicio da fila quando chega ao fim
to_store_queue_end:
	LDH 	R4, #queue
	LDL 	R4, #queue 			; R4 <= &queue

; Fim do input_peripheral_handler
end_input_hnd:
	ST 		R4, R3, R15 	 	; to_store <= R4

	LDH 	R0, #00h
	LDL 	R0, #80h
	LDH 	R1, #FFh
	LDL 	R1, #F7h 			; R1 <= &MASK
	LD 		R2, R1, R15 		; R2 <= MASK
	LDH 	R2, #00h 			; Fix para a parte alta da Mask
	OR 		R0, R0, R2 			; R0 <= MASK OR "0080"h			
	ST 		R0, R1, R15 		; Ativa irq do Speech Synthesizer

	RTS


; ============= SPEECH SYNTHESIZER HANDLER =====================
speech_synthesizer_handler:
	LDH 	R5, #FFh
	LDL 	R5, #F1h			; R5 <= output de port_a

	LDH	 	R1, #queue_size
	LDL	 	R1, #queue_size
	LD 		R2, R1, R15 		; R2 <= queue_size
	SUB 	R0, R2, R15
	JMPZD 	#empty

	LDH 	R3, #to_remove
	LDL 	R3, #to_remove
	LD 		R0, R3, R15 		; R0 <= to_remove
	LD 	 	R6, R0, R15 		; R6 <= *to_remove

	LDH 	R7, #wr_low_high
	LDL 	R7, #wr_low_high
	LD 		R8, R7, R15 		; R7 <= wr_low_high
	OR 		R8, R8, R8 			; Ativa flags
	JMPZD 	#write_low

write_high:
	ADDI 	R8, #1h
	ST 		R8, R7, R15  		; wr_low_high++ ("0000")
	ADDI 	R9, #8h
sr_loop:
	SR0 	R6, R6
	SUBI 	R9, #1h
	JMPZD 	#skip2
	JMPD 	#sr_loop
skip2:
	LDH 	R6, #02h			; Carrega bit 10 com 1, para ALD
	ST 		R6, R5, R15			; Guarda R6 no registrador de output
	ST 		R15, R5, R15		; Manda 0 em ALD
	RTS

	
write_low:
	SUBI 	R8, #1h
	ST 		R8, R7, R15  		; wr_low_high-- ("FFFF")

	ST 		R15, R0, R15 		; Zera a posicao do array indicada em to_remove

	SUBI 	R2, #1h
	ST 		R2, R1, R15 		; queue_size--

	LDH 	R2, #queue_end
	LDL 	R2, #queue_end
	LD 		R2, R2, R15
	SUB 	R2, R2, R0	 			; R2 <= queue_end - to_remove
	JMPZD 	#to_remove_queue_end 	; se queue_end == to_remove

	ADDI 	R0, #01h 			;
	ST 		R0, R3, R15 		; to_remove++
	JMPD 	#output

; Bloco que faz to_remove voltar para o inicio da fila quando chega ao fim
to_remove_queue_end:
	LDH 	R4, #queue
	LDL 	R4, #queue 			; R4 <= &queue
	ST 		R4, R3, R15 		; to_remove <= &queue
	JMPD 	#output

; Desativa IRQ do Synthesizer quando a fila estiver vazia
empty:
	LDH 	R1, #FFh
	LDL 	R1, #F7h 			; R1 <= &MASK
	LD 		R2, R1, R15 		; R2 <= MASK
	LDH 	R2, #00h 			; Fix para a parte alta
	LDH 	R3, #00h
	LDL 	R3, #7Fh
	AND 	R2, R3, R2 			; R2 <= MASK AND "7F"
	ST 		R2, R1, R15 		; Desativa irq do Synthesizer
	JMPD 	#end_speech_hnd
	RTS

; Realiza o output dos dados do array
output:
	LDH 	R6, #02h			; Carrega bit 10 com 1, para ALD
	ST 		R6, R5, R15			; Guarda R6 no registrador de output
	ST 		R15, R5, R15		; Manda 0 em ALD

; Finaliza a interruption e faz o mascaramento desejado
end_speech_hnd:
	LDH 	R0, #00h
	LDL 	R0, #40h
	LDH 	R1, #FFh
	LDL 	R1, #F7h 			; R1 <= &MASK
	LD 		R2, R1, R15 		; R2 <= MASK
	LDH 	R2, #00h 			; Fix para a parte alta da Mask
	OR 		R0, R0, R2 			; R0 <= MASK OR "0080"h			
	ST 		R0, R1, R15 		; Ativa irq do Input_Peripheral

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
   
   	; Stack test 
   	PUSH R1
   	PUSH R2
   	PUSH R3
   	PUSH R4
   
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
	; Stack test
	POP R4
	POP R3
	POP R2
	POP R1

    HALT                    ; Suspend the execution

.endcode

; Data area (variables)
.data
	; Array do bubble sort
    array:     			db #20h, #19h, #18h, #17h, #16h, #15h, #14h, #13h, #12h, #11h, #10h, #9h, #8h, #7h, #6h, #5h, #4h, #3h, #2h, #1h
    size:      			db #20    ; 'array' size

    ; Array de enderecos de interruption handler
    interruption_array: db #timer_handler, #0h, #0h, #0h, #0h, #0h, #input_peripheral_handler, #speech_synthesizer_handler

    ; Fila para armazenar dados que vem de input
    queue_size:			db #0h 	; Tamanho da fila no momento
    queue_max_size: 	db #10 ; Tamanho maximo da fila
    to_store: 			db #0h 	; Ponteiro para posicao a ser armazenado um dado
    to_remove: 			db #0h 	; Ponteiro para a posicao que deve ser removido um dado
    queue_end: 			db #0h  ; Ponteiro que sempre aponta para o ultimo endereco da fila
    queue: 				db #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h
    wr_low_high:		db #FFFFh ; Quando FF escreve parte alta, quando 0 escreve a parte baixa

    timer_interrupts: 	db #0h 	; Conta o numero de interrupcoes do timer

    ; TASK CONTROL BLOCK
    tcb_array: 			db #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h
    tcb_pointer: 		db #tcb_array


.enddata