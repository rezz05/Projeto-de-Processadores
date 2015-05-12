.code
	LDH 	R0, #FFh
	LDL 	R0, #F7h
	ADDI 	R2, #1h
	ST		R2, R0, R15
	HALT

.endcode