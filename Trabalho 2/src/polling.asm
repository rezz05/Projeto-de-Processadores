.code
	LDL 	R0, #F0h			; setup das portas
	LDH 	R0, #FFh			; R0 recebe endereco de port_a			
	LDH 	R1, #05h
	ST 		R1, R0, R15		; port_a <= "0500"
	LDH 	R1, #FFh			; R1 recebe endereco de port_b
	LDL 	R1, #F3h
	LDH 	R0, #FFh
	LDL 	R0, #FFh			
	ST 		R0, R1, R15 	; port_b <= "0000"

start:
	LDH 	R2, #04h				; Mascara para o bit 10
ip_polling:
	LDH 	R1, #FFh
	LDL 	R1, #F2h
	LD 		R3, R1, R15	 	; R1 recebe dados entrando em port_a
	AND 	R3, R2, R3		; Mascaramento para bit 10
	JMPZD	#ip_polling		; Se flag zero, data_av ainda eh 0

	LDH 	R1, #FFh			; Carrega endereco de input de port_b
	LDL 	R1, #F5h
	LD 		R3, R1, R15 	; R3 recebe dados em port_b
	LDH 	R4, #08h			; R4 <= x"0800", para mandar 1 em data_ack
	LDH 	R1, #FFh 			
	LDL 	R1, #F1h			; R1 <= x"FFF1", endereco de output de port_a
	ST 		R4, R1, R15 	; Manda 1 em data_ack
	ST 		R15, R1, R15 	; Manda 0 em data_ack

	ADD 	R2, R3, R15 	; Copia R3(Dado a guardar) para R2
	ADDI 	R6, #8h			
shift_right_loop:			; Shift right para R2 ficar com a parte alta de R3
	SR0 	R2, R2
	SUBI 	R6, #1h
	JMPZD #done_shift
	JMPD 	#shift_right_loop		

done_shift:

	LDH 	R5, #01h 						; mascara para o bit 8
ss_polling_high:
	LDH 	R1, #FFh
	LDL 	R1, #F2h
	LD 		R4, R1, R15	 				; R4 recebe input de port_a
	AND 	R4, R5, R4					; Mascaramento para bit 8
	JMPZD	#ss_polling_high		; Se flag zero, SBY ainda eh 0

	LDH 	R1, #FFh						; Carrega endereco de output de port_a
	LDL 	R1, #F1h
	LDH 	R2, #02h						; Carrega bit 10 com 1, para ALD
	ST 		R2, R1, R15					; Guarda R2 no registrador de output
	ST 		R15, R1, R15				; Manda 0 em ALD

ss_polling_low:
	LDH 	R1, #FFh
	LDL 	R1, #F2h
	LD 		R4, R1, R15	 				; R4 recebe input de port_a
	AND 	R4, R5, R4					; Mascaramento para bit 8
	JMPZD	#ss_polling_low			; Se flag zero, SBY ainda eh 0

	LDH 	R1, #FFh						; Carrega endereco de output de port_a
	LDL 	R1, #F1h
	LDH 	R3, #02h						; Carrega bit 10 com 1, para ALD
	ST 		R3, R1, R15					; Guarda R3 no registrador de output
	ST 		R15, R1, R15				; Manda 0 em ALD

	JMPD 	#start

.endcode
