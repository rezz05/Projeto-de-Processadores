.code
	LDH 	R0, #03h
	LDL 	R0, #FFh
	LDSP 	R0
	SUBI 	R1, #01h
	PUSHF
	ADD		R2, R2, R2
	POPF
	HALT	
.endcode