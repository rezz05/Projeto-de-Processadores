.code

boot:	
	LDL		R0, #interruption_handler			
	LDINTA 	R0					; Endereco de Interruption_handler
	
	LDL 	R0, #01h 			; Mask Inicial da PIC
	LDH 	R1, #FFh
	LDL 	R1, #F7h			
	ST 		R0, R1, R15 		; Inicializacao da Mask da PIC

	LDH 	R0, #03h
	LDL 	R0, #BFh
	LDSP 	R0					; SP <= "03BFh" | Topo da pilha de Idle

	LDH 	R0, #03h
	LDL 	R0, #FFh		
	LDH 	R1, #FFh
	LDL 	R1, #F9h			
	ST 		R0, R1, R15 		; Timer <= x"3FF" | Inicializa o timer

	ENI 						; Habilita interrupcoes

idle:
	JMPD 	#idle 				; Loop infinito

interruption_handler:
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
;	ST 		R14, R13, R15 		; tcb_array[1] <= PC
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

	; Retorno do contexto
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



; ========= Producer 1 ============
producer1:
	; ======= Start of Critical Section ========
	LDH 	R0, #size
	LDL 	R0, #size
	LD 		R0, R0, R15 		; R0 <= size
	LDH 	R1, #count
	LDL 	R1, #count 			; R1 <= &count
	LD 		R2, R1, R15 		; R2 <= count
	SUB 	R0, R0, R2 			; R0 <= count - size
	JMPZD 	#producer1_loop 	; Se fila esta cheia pula para producer1_loop
	; else
	LDH 	R0, #buffer
	LDL 	R0, #buffer 		; R0 <= &buffer
	LDH 	R3, #begin
	LDL 	R3, #begin
	LD 		R4, R3, R15 		; R4 <= begin
	ADD 	R0, R4, R0 			; R0 <= &buffer + begin
	LDH 	R5, #00h
	LDL 	R5, #01h 			; R5 <= 1
	ST 		R5, R0, R15 		; buffer[begin] <= 1

	ADDI 	R2, #01h
	ST 		R2, R1, R15 		; count++
	ADDI 	R4, #01h
	ST 		R4, R3, R15 		; begin++
	; ======= End of Critical Section ========

	LDH 	R0, #01h
	LDL 	R0, #00h 			; R0 <= 256

producer1_loop:
	SUBI 	R0, #01h 			; R0--
	JMPZD 	#producer1
	JMPD 	#producer1_loop

; ======== Consumer ============
consumer:
	; ======= Start of Critical Section ========
	LDH 	R1, #count
	LDL 	R1, #count 			; R1 <= &count
	LD 		R2, R1, R15 		; R2 <= count
	OR 		R2, R2, R2 			; Ativa flags
	JMPZD 	#consumer_loop 		; Se fila esta vazia pula para consumer_loop
	; else
	LDH 	R0, #buffer
	LDL 	R0, #buffer 		; R0 <= &buffer
	LDH 	R3, #end
	LDL 	R3, #end
	LD 		R4, R3, R15 		; R4 <= end
	ADD 	R0, R4, R0 			; R0 <= &buffer + end
	LDH 	R5, #FFh
	LDL 	R5, #FFh 			; R5 <= -1
	ST 		R5, R0, R15 		; buffer[end] <= -1

	SUBI 	R2, #01h
	ST 		R2, R1, R15 		; count--
	ADDI 	R4, #01h
	ST 		R4, R3, R15 		; end++
	; ======= End of Critical Section ========

	LDH 	R0, #01h
	LDL 	R0, #00h 			; R0 <= 256

consumer_loop:
	SUBI 	R0, #01h 			; R0--
	JMPZD 	#consumer
	JMPD 	#consumer_loop

; ========= Producer 2 ===========
producer2:
	; ======= Start of Critical Section ========
	LDH 	R0, #size
	LDL 	R0, #size
	LD 		R0, R0, R15 		; R0 <= size
	LDH 	R1, #count
	LDL 	R1, #count 			; R1 <= &count
	LD 		R2, R1, R15 		; R2 <= count
	SUB 	R0, R0, R2 			; R0 <= count - size
	JMPZD 	#producer2_loop 	; Se fila esta cheia pula para producer2_loop
	; else
	LDH 	R0, #buffer
	LDL 	R0, #buffer 		; R0 <= &buffer
	LDH 	R3, #begin
	LDL 	R3, #begin
	LD 		R4, R3, R15 		; R4 <= begin
	ADD 	R0, R4, R0 			; R0 <= &buffer + begin
	LDH 	R5, #00h
	LDL 	R5, #02h 			; R5 <= 1
	ST 		R5, R0, R15 		; buffer[begin] <= 1

	ADDI 	R2, #01h
	ST 		R2, R1, R15 		; count++
	ADDI 	R4, #01h
	ST 		R4, R3, R15 		; begin++
	; ======= End of Critical Section ========

	LDH 	R0, #01h
	LDL 	R0, #00h 			; R0 <= 256

producer2_loop:
	SUBI 	R0, #01h 			; R0--
	JMPZD 	#producer2
	JMPD 	#producer2_loop


.endcode

.data

	; TCBs das tasks
	producer1_tcb: 	db #1h, #producer1, #0h, #3EFh, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h
	consumer_tcb: 	db #1h, #consumer, 	#0h, #3DFh, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h
	producer2_tcb: 	db #1h, #producer2, #0h, #3CFh, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h

	; Circular queue
	buffer: 	db #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h
	size: 		db #10 		; Tamanho maxima da fila
	begin: 		db #0h 		; Index para inserir dados na fila
	end: 		db #0h 		; Index para remover dados da fila
	count: 		db #0h 		; O numero de elementos atuais na fila

    ; Array de enderecos de interruption handler
    interruption_array: db #timer_handler, #0h, #0h, #0h, #0h, #0h, #0h, #0h

    ; Conta o numero de interrupcoes do timer
    timer_interrupts: 	db #0h

    ; ====== KERNEL =======
    kernel_stack: 		db #3FFh
    tcb_idle: 			db #0h, #0h, #0h, #3BFh, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h, #0h
    tcb_vector: 		db #tcb_idle, #producer1_tcb, #consumer_tcb, #producer2_tcb
    runningTask: 		db #0h

.enddata

