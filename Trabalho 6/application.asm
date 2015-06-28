.code

boot:
; Configuração da porta
; Setar SP = 0x3FF (fim da memória de dados)
; Salta para bubble sort (jmpd #BubbleSort)
	LDL		R0, #Interruption_handler			
	LDINTA 	R0					; Endereco de Interruption_handler
	
	LDL 	R0, #C1h 			; Mask Inicial da PIC
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
	LDL 	R0, #49h
	LDSP 	R0					; SP <= "0349h" | Topo da pilha de Idle

	LDH 	R0, #03h
	LDL 	R0, #FFh		
	LDH 	R1, #FFh
	LDL 	R1, #F9h			
	ST 		R0, R1, R15 		; Timer <= x"3FF" | Inicializa o timer

	ENI 						; Habilita interrupcoes

idle:
	JMPD 	#idle 				; Loop infinito

Interruption_handler:
	; Salvamento de contexto
	POP  	R14 				; R14 <= PC
	PUSHF						; Coloca flags na pilha
	PUSH  	R14					; Coloca PC na pilha

	LDH 	R13, #runningTask
	LDL 	R13, #runningTask 	
	LD 		R13, R13, R15 		; R13 <= runningTask

	LDH 	R14, #tcb_vector
	LDL 	R14, #tcb_vector 	; R14 <= &tcb_vector
	ADD 	R14, R13, R14 		; R14 <= &tcb_vector + runningTask
	LD 		R13, R14, R15 		; R13 <= tcb_vector[runningTask]
	ADDI 	R13, #1h 			; Pula a posicao de status do tcb_array

	POP 	R14 				; R14 <= PC
	ST 		R14, R13, R15 		; tcb_array[1] <= PC
	ADDI 	R13, #1h 			; tcb_pointer++

	POP 	R14
	ST 		R14, R13, R15 		; tcb_array[2] <= Flags
	ADDI 	R13, #1h 			; tcb_pointer++
	
	CPSP 	R14 				; R14 <= flags
	ST 		R14, R13, R15 		; tcb_array[3] <= SP
	ADDI 	R13, #1h 			; tcb_pointer++
	
	ST 		R0, R13, R15 		; tcb_array[4] <= R0
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R1, R13, R15 		; tcb_array[5] <= R1
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R2, R13, R15 		; tcb_array[6] <= R2
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R3, R13, R15 		; tcb_array[7] <= R3
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R4, R13, R15 		; tcb_array[8] <= R4
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R5, R13, R15 		; tcb_array[9] <= R5
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R6, R13, R15 		; tcb_array[10] <= R6
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R7, R13, R15 		; tcb_array[11] <= R7
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R8, R13, R15 		; tcb_array[12] <= R8
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R9, R13, R15 		; tcb_array[13] <= R9
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R10, R13, R15 		; tcb_array[14] <= R10
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R11, R13, R15 		; tcb_array[15] <= R11
	ADDI 	R13, #1h 			; tcb_pointer++
	ST 		R12, R13, R15 		; tcb_array[16] <= R12

	LDH 	R0, #kernel_stack
	LDL 	R0, #kernel_stack 	
	LD 		R0, R0, R15 		; R0 <= kernel_stack
	LDSP 	R0 					; Carrega SP com o topo da stack do kernel

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

	CPSP 	R0 					; Copia valor de SP atual para R0
	LDH 	R1, #kernel_stack
	LDL 	R1, #kernel_stack
	ST 		R0, R1, R15 		; Atualiza valor de kernel_stack

	LDH 	R13, #runningTask
	LDL 	R13, #runningTask
	LD 		R13, R13, R15 		; R13 <= runningTask
	LDH 	R14, #tcb_vector
	LDL 	R14, #tcb_vector 	; R14 <= &tcb_vector
	ADD 	R14, R13, R14 		; R14 <= &tcb_vector + runningTask
	LD 		R13, R14, R15 		; R13 <= &tcb_array correspondente a tarefa que devera ser executada
	
	ADDI	R13, #1h 			; Pula posicao de status do array

	LD 		R1, R13, R15 		; R1 <= tcb_array[1] | R1 <= PC

	ADDI 	R13, #1h
	LD 		R0, R13, R15 		; R0 <= tcb_array[2] | R0 <= Flags

	ADDI 	R13, #1h
	LD 		R2, R13, R15 		; R2 <= tcb_array[3] | R2 <= SP

	LDSP 	R2 					; Restaura SP
	PUSH 	R1 					; Guarda R1(PC) na pilha
	PUSH 	R0 					; Guarda flags na pilha

	ADDI 	R13, #1h 			; tcb_array++
	LD 		R0, R13, R15		; R0 <= tcb_array[4]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R1, R13, R15		; R1 <= tcb_array[5]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R2, R13, R15		; R2 <= tcb_array[6]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R3, R13, R15		; R3 <= tcb_array[7]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R4, R13, R15		; R4 <= tcb_array[8]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R5, R13, R15		; R5 <= tcb_array[9]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R6, R13, R15		; R6 <= tcb_array[10]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R7, R13, R15		; R7 <= tcb_array[11]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R8, R13, R15		; R8 <= tcb_array[12]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R9, R13, R15		; R9 <= tcb_array[13]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R10, R13, R15		; R10 <= tcb_array[14]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R11, R13, R15		; R11 <= tcb_array[15]
	ADDI 	R13, #1h 			; tcb_array++
	LD 		R12, R13, R15		; R12 <= tcb_array[16]

	POPF						; Restaura Flags

	RTI 						; Retorno de contexto
	
; ============== Timer Handler ===========================
timer_handler:
	LDH 	R0, #timer_interrupts
	LDL 	R0, #timer_interrupts
	LD 		R1, R0, R15
	ADDI 	R1, #1h
	ST 		R1, R0, R15 			; timer_interrupts++

	LDH 	R0, #runningTask
	LDL 	R0, #runningTask
	LD 		R1, R0, R15 			; R1 <= runningTask

	LDH 	R2, #tcb_vector
	LDL 	R2, #tcb_vector			; R2 <= &tcb_vector

; Procura uma tarefa que ainda nao foi concluida (status = 1)
 	LDH 	R14, #00h
 	LDL 	R14, #05h 				; Registrador para determinar se o status de todos sao vazios
new_task_loop:
	SUBI 	R14, #1h 				; R14--
	JMPZD 	#no_applications 		; Se R14 == 0, todas as tasks estao com status 0

	ADDI 	R1, #1h 				; Escalona novo programa
	LDH 	R4, #00h
	LDL 	R4, #04h 				; R4 <= 4
	SUB 	R4, R1, R4 				; R4 <= R1(runningTask) - 4
	JMPZD 	#end_runningTask 		; runningTask == 4, runningTask chegou a ultima task
	JMPD 	#skip3 					; else

end_runningTask:
	XOR 	R1, R1, R1 				; Zera R1, para voltar para a primeira task

skip3:
	ADD 	R3, R1, R2 				; R3 <= &tcb_vector + runningTask
	LD 		R3, R3, R15 			; R3 <= tcb_vector[runningTask]
	LD 		R3, R3, R15 			; R3 <= tcb_array[0] | R3 <= status
 	
	OR 		R3, R3, R3 				; Ativa flags para testar status
	JMPZD 	#new_task_loop 			; Se status for zero pula para new_task_loop
	; Se status for 1:
	JMPD 	#new_application 
no_applications:
	XOR 	R1, R1, R1 				; Zera runningTask, task restaurada sera Idle

new_application:
	ST 		R1, R0, R15 		; runningTask recebe a proxima tarefa a ser executada

	LDH 	R0, #03h
	LDL 	R0, #FFh		
	LDH 	R1, #FFh
	LDL 	R1, #F9h			
	ST 		R0, R1, R15 		; Timer <= x"3FF"

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

TaskEnd:
	LDH 	R0, #tcb_vector
	LDL 	R0, #tcb_vector
	LDH 	R1, #runningTask
	LDL 	R1, #runningTask
	LD 		R2, R1, R15  		; R2 <= runningTask

	ADD 	R3, R0, R2 			; R3 <= runningTask + &tcb_vector
	LD 		R3, R3, R15 		; R3 <= tcb_vector[runningTask]

	ST 		R15, R3, R15 		; tcb_array[0] <= 0 | Zera o status da task que foi finalizada

	ST 		R15, R1, R15 		; Muda runningTask para 0 (idle)
	LD 		R3, R0, R15 		; R3 <= tcb_vector[0](tcb_idle)
	ADDI 	R3, #3h 			; &tcb_idle[3]
	LD 		R4, R3, R15 		; R4 <= tcb_array[3](SP)
	LDSP 	R4 					; Carrega SP com SP da Idle task

	JMPD 	#idle 				; Pula para idle
	;RTS


;*****************************
;** Bubble sort application **
;*****************************
BubbleSort: 
    ; Initialization code
    xor r0, r0, r0                  ; r0 <- 0
    
    ldh r1, #arrayBS                ;
    ldl r1, #arrayBS                ; r1 <- &arrayBS
    
    ldh r2, #sizeArrayBS            ;
    ldl r2, #sizeArrayBS            ; r2 <- &sizeArrayBS
    ld r2, r2, r0                   ; r2 <- sizeArrayBS
    
    add r3, r2, r1                  ; r3 points the end of array (right after the last element)
            
    ldl r4, #0                      ;
    ldh r4, #1                      ; r4 <- 1
    
    ; Stack test
    push r1
    push r2
    push r3
    push r4
     
; Main code
main:
    addi r4, #0                     ; Verifies if there was element swaping
    jmpzd #endBubbleSort            ; If r4 = 0 then no element swaping
    
    xor r4, r4, r4                  ; r4 <- 0 before each pass
            
    add r5, r1, r0                  ; r5 points the first arrar element
            
    add r6, r1, r0                  ;
    addi r6, #1                     ; r6 points the second array element
    
; Read two consecutive elements and compares them    
loop:
    ld r7, r5, r0                   ; r7 <- arrayBS[r5]
    ld r8, r6, r0                   ; r8 <- arrayBS[r6]
    sub r2, r8, r7                  ; If r8 > r7, negative flag is set
    jmpnd #swap                     ; (if arrayBS[r5] > arrayBS[r6] jump)
    
; Increments the index registers and verifies is the pass is concluded
continue:
    addi r5, #1                     ; r5++
    addi r6, #1                     ; r6++
            
    sub r2, r6, r3                  ; Verifies if the end of array was reached (r6 = r3)
    jmpzd #main                     ; If r6 = r3 jump
    jmpd #loop                      ; else, the next two elements are compared

; Swaps two array elements (memory)
swap:
    st r7, r6, r0                   ; arrayBS[r6] <- r7
    st r8, r5, r0                   ; arrayBS[r5] <- r8
    ldl r4, #1                      ; Set the element swaping (r4 <- 1)
    jmpd #continue
        
endBubbleSort:
    
    ; Stack test
    pop r4
    pop r3
    pop r2
    pop r1
 	
   	jmpd #TaskEnd
   	;jsrd #TaskEnd                   ; Do not schedule bubble sort anymore

loopBubbleSort:    
    jmpd #idle              ; Suspend the execution


;********************************
;** Insertion sort application **
;********************************
InsertionSort:
    xor r0, r0, r0
    
    ldh r1, #arrayIS
    ldl r1, #arrayIS
    
    ldh r11, #sizeArrayIS
    ldl r11, #sizeArrayIS
    ld r11, r11, r0                     ; r11 <- sizeArrayIS
    
    ldh r3, #0                          ; r3 = i
    ldl r3, #1                          ; i <- 1
    
for: 
    sub r10, r3, r11                    ; i < sizeArrayIS ?
    jmpzd #endInsertionSort
    
    ld r2, r3, r1                   ; eleito <= array[i]
      
    add r4, r3, r0                  ; r4 = j
    subi r4, #1                     ; j <- i-1
        
while:
    addi r4, #0                 ;
    jmpnd #end_while            ; j >= 0 ?
    ld r5, r4, r1               ; r5 <- array[j]
    sub r10, r5, r2             ; eleito < array[j]?
    jmpnd #end_while            ; Jump if (array[j] - eleito) < 0
    jmpzd #end_while            ; Jump if (array[j] - eleito) = 0
            
    add r10, r4, r0             ;
    addi r10, #1                ; r10 = j+1
    st r5, r10, r1              ; array[j+1] = array[j]
    subi r4, #1                 ; j--
    jmpd #while
end_while:   
     
    add r10, r4, r0                 ;
    addi r10, #1                    ; r10 = j+1
    st r2, r10, r1                  ; array[j+1] = eleito
        
    addi r3, #1                         ; i++
    jmpd #for                           ; end for
        
endInsertionSort:    
    jmpd 	#TaskEnd
    ;jsrd #TaskEnd                       ; Do not schedule insertion sort anymore
    
loopInsertionSort:    
    jmpd #idle              ; Suspend the execution


;****************************
;** Quick Sort application **
;****************************

QuickSortApp:
    jsrd #QuickSort

    
    jmpd 	#TaskEnd
    ;jsrd #TaskEnd                       ; Do not schedule quick sort anymore
    
loopEndQuickSort:

    jmpd #idle            				; Suspend the execution
    
QuickSort:
    push r0
    push r1
    push r2
    push r3
    push r4
    
    xor r0, r0, r0
    
    ldh r3, #leftBound              ;
    ldl r3, #leftBound              ;
    ld r3, r3, r0                   ; leftBound = r3
    
    ldh r4, #rightBound             ;
    ldl r4, #rightBound             ; 
    ld r4, r4, r0                   ; rightBound = r4
    
    ; i = r1
    ; j = r2
       
    ; i = leftBound
    add r1, r3, r0
    
    ; j = rightBound
    add r2, r4, r0
        
    ldh r6, #arrayQS                  ;
    ldl r6, #arrayQS                  ; 
    ld r7, r6, r1                   ; arrayQS[i] = r7
    ld r8, r6, r2                   ; arrayQS[j] = r8
    
    ; pivot = r5
    ; pivot = array[i]
    add r5, r7, r0

;        r1   r2    
; while (i < j)    
while1:
    sub r12, r2, r1                 ; If (j - i) <= 0, then (i < j) is false
    jmpzd #end_while1               ; Breaks the while1
    jmpnd #end_while1               ; Breaks the while1
    
    ;           r7        r5     r1      r4
    ; while (array[i] < pivot && i < rightBound)
while2:
    sub r12, r5, r7             ; If (pivot - array[i]) <= 0, then (array[i] < pivot) is false
    jmpnd #end_while2           ; Breaks while2
    jmpzd #end_while2           ; Breaks while2
        
    sub r12, r4, r1             ; If (rightBound - i) <= 0, then (i < rightBound) is false
    jmpnd #end_while2           ; Breaks while2
    jmpzd #end_while2           ; Breaks while2
        
    ; i++
    addi r1, #1
    jmpd #while2        
end_while2:
    
    ;           r8        r5     r2      r3
    ; while (array[j] > pivot && j > leftBound)
while3:
    sub r12, r8, r5             ; If (array[j] - pivot) <= 0, then (array[j] > pivot) is false
    jmpnd #end_while3           ; Breaks while3
    jmpzd #end_while3           ; Breaks while3
        
    sub r12, r2, r3             ; If (j - leftBound) <= 0, then (j > leftBound) is false
    jmpnd #end_while3           ; Breaks while3
    jmpzd #end_while3           ; Breaks while3
        
    ; j--
    subi r2, #1
	jmpd #while3        
end_while3:
    
    ;     r1  r2
    ; if (i < j)
    sub r12, r2, r1                 ; If (j - i) <= 0, then (i < j) is false
    jmpzd #inc                      ; jump if (i == j)
    jmpnd #test1                    ; jump if (i > j)
    ;        r7         r8 
    ; swap (array[i], array[j])
    st r8, r6, r1                   ; array[i] = r8
    st r7, r6, r2                   ; array[j] = r7
    
inc:
    ; i++
    addi r1, #1
    
    ; j--
    subi r2, #1
    
    
;     r2     r3    
; if (j > leftBound)
;       QuickSort(array, leftBound, j);
test1:
    sub r12, r2, r3         ; If (j - leftBound) <= 0, then (j > leftBound) is false
    jmpnd #test2            ; jump if false
    jmpzd #test2            ; jump if false
    
    ; Updates variable leftBound
    ldh r12, #leftBound              ;
    ldl r12, #leftBound              ;
    st r3, r12, r0                   ; leftBound = r3
    
    ; Updates variable rightBound
    ldh r12, #rightBound             ;
    ldl r12, #rightBound             ; 
    st r2, r12, r0                   ; rightBound = j
    jsrd #QuickSort

;     r1      r4
; if (i < rightBound)
;        QuickSort(array,  i, rightBound);
test2:
    sub r12, r4, r1                 ; If (rightBound - i) <= 0, then (i < rightBound) is false
    jmpnd #end_while1               ; jump if false
    jmpzd #end_while1               ; jump if false
    
    ; Updates variable leftBound
    ldh r12, #leftBound              ;
    ldl r12, #leftBound              ;
    st r1, r12, r0                   ; leftBound = r1
    
    ; Updates variable rightBound
    ldh r12, #rightBound             ;
    ldl r12, #rightBound             ; 
    st r4, r12, r0                   ; rightBound = r4
    jsrd #QuickSort
    
end_while1:
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0

    rts

.endcode

; Data area (variables)
.data
	; ========== BUBBLE SORT ================
    arrayBS:        db #20h, #19h, #18h, #17h, #16h, #15h, #14h, #13h, #12h, #11h, #10h, #9, #8, #7, #6, #5, #4, #3, #2, #1
    sizeArrayBS:    db #20    ; 'array' size
    ; === TCB BS ===
    ; tcb_bs_array[0] eh o bit de status do programa
    tcb_bs_array: 	db #1h, #BubbleSort, #0h, #369h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h


    ; ======== INSERTION SORT =============
    arrayIS:        db #20h, #19h, #18h, #17h, #16h, #15h, #14h, #13h, #12h, #11h, #10h, #9, #8, #7, #6, #5, #4, #3, #2, #1
    sizeArrayIS:    db #20    ; 'array' size
    ; === TCB IS ===
    ; tcb_is_array[0] eh o bit de status do programa
    tcb_is_array: 	db #1h, #InsertionSort, #0h, #35Ah, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h


    ; =========== QUICK SORT ============
    arrayQS:    	db #20h, #19h, #18h, #17h, #16h, #15h, #14h, #13h, #12h, #11h, #10h, #9, #8, #7, #6, #5, #4, #3, #2, #1 
    leftBound:  	db #0
    rightBound: 	db #19
    ; === TCB QS ===
    ; tcb_qs_array[0] eh o bit de status do programa
    tcb_qs_array: 	db #1h, #QuickSortApp, #0h, #3EAh, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h


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

    ; ====== KERNEL =======
    kernel_stack: 		db #3FFh
    tcb_idle: 			db #0h, #0h, #0h, #349h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h
    tcb_vector: 		db #tcb_idle, #tcb_bs_array, #tcb_is_array, #tcb_qs_array
    runningTask: 		db #0h


.enddata