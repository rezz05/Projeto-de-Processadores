.code
	LDL 	R0, #F0h			; setup das portas
	LDH 	R0, #FFh			; R0 recebe endereco de port_a			
	LDH 	R1, #80h
	ST 		R1, R0, R15			; port_a <= "8000"
	LDH 	R2, #10
	LDSP 	R2

Start:
	ADDI R5, #01h
	JMPD #start

lesk:
	LDH 	R3, #FFh
	LDL 	R3, #F1h
	LDH 	R4, #08h
	LDL 	R4, #00h			; R4 <= x"0800", para mandar 1 em data_ack
	ST 		R4, R3, R15 		; Manda 1 em data_ack
	ST 		R15, R3, R15 		; Manda 0 em data_ack

.endcode