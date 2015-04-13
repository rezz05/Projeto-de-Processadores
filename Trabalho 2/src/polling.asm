.code
	LDL 	R0, #F0h			; setup das portas
	LDH 	R0, #FFh			; R0 recebe endereco de port_a			
	LDH 	R1, #05h
	ST 		R1, R0, R15			; port_a <= "0500"
	LDH 	R1, #FFh			; R1 recebe endereco de port_b
	LDL 	R1, #F3h
	LDH 	R0, #FFh
	LDL 	R0, #FFh			
	ST 		R0, R1, R15 		; port_b <= "1111"

	LDL 	R0, #F1h 			; R0 <= "FFF1" port_a output
	LDL 	R1, #F2h 			; R1 <= "FFF2" port_a input
	LDH 	R2, #FFh
	LDL 	R2, #F4h			; R2 <= "FFF4" port_b output
	LDH 	R3, #FFh
	LDL 	R3, #F5h			; R3 <= "FFF5" port_b input

start:
	LDH 	R4, #04h			; Mascara para o bit 10
	LDL 	R4, #00h
ip_polling:
	LD 		R5, R1, R15	 		; R5 recebe dados entrando em port_a
	AND 	R5, R4, R5			; Mascaramento para bit 10
	JMPZD	#ip_polling			; Se flag zero, data_av ainda eh 0

	LD 		R4, R3, R15 		; R4 recebe dados em port_b
	LDH 	R5, #08h
	LDL 	R5, #00h			; R5 <= x"0800", para mandar 1 em data_ack
	ST 		R5, R0, R15 		; Manda 1 em data_ack
	ST 		R15, R0, R15 		; Manda 0 em data_ack

	ADD 	R5, R4, R15 		; Copia R4(Dado a guardar) para R5
	ADDI 	R6, #08h			
shift_right_loop:				; Shift right para R5 ficar com a parte alta de R4
	SR0 	R5, R5
	SUBI 	R6, #01h
	JMPZD 	#done_shift
	JMPD 	#shift_right_loop		

done_shift:

	LDH 	R7, #01h 			; mascara para o bit 8
ss_polling_high:
	LD 		R6, R1, R15	 		; R6 recebe input de port_a
	AND 	R6, R6, R7			; Mascaramento para bit 8
	JMPZD	#ss_polling_high	; Se flag zero, SBY ainda eh 0

	LDH 	R5, #02h			; Carrega bit 10 com 1, para ALD
	ST 		R5, R0, R15			; Guarda R5 no registrador de output
	ST 		R15, R0, R15		; Manda 0 em ALD

ss_polling_low:
	LD 		R5, R1, R15	 		; R5 recebe input de port_a
	AND 	R5, R5, R7			; Mascaramento para bit 8
	JMPZD	#ss_polling_low		; Se flag zero, SBY ainda eh 0

	LDH 	R4, #02h			; Carrega bit 10 com 1, para ALD
	ST 		R4, R0, R15			; Guarda R3 no registrador de output
	ST 		R15, R0, R15		; Manda 0 em ALD

	JMPD 	#start

.endcode
