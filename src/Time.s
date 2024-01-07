		AREA    |.text|, CODE, READONLY
			
ONE_SECOND_VAL			EQU		0x004FFFFF ;; Nombre de tours pour une seconde
TIME_FOR_ONE_CM_VAL   	EQU     0x000BA000 ;; Nombre de tours n?c?ssaires pour parcourir 1cm
TRAVEL_TIME_IN_CYCLE 	EQU		0x20000001 ;; Durée du voyage en nombre de cycle

		ENTRY
		EXPORT TRAVEL_TIME_IN_CYCLE
		
		EXPORT DISTANCE_TO_TIME_IN_CYCLE
		EXPORT WAIT_ASKED_TIME_IN_CYCLE
		EXPORT WAIT_R5_SECONDS
		
		IMPORT TRAVEL_DISTANCE_CM_ADR
		
 ;; wait x second(s), x = r5
WAIT_R5_SECONDS
		LDR r1, =ONE_SECOND_VAL ;; store value for one second
		MUL r5, r5, r1 ;; Multiply asked seconds by value for one second

wait_r5_seconds_loop
		SUBS r5, #1
        BNE wait_r5_seconds_loop
		
		BX	LR

 ;; convert asked distance in cm to a time in number of cycle
DISTANCE_TO_TIME_IN_CYCLE
		LDR r0, =TRAVEL_DISTANCE_CM_ADR
		LDR r1, [r0]

		MOV r2, #TIME_FOR_ONE_CM_VAL
		
		MUL r1, r1, r2 ;; give x second(s), x = r8
		
		LDR r3, =TRAVEL_TIME_IN_CYCLE
		STR r1, [r3]
		
		BX	LR

;; Wait the time asked by the user, which must be stored in TRAVEL_TIME_IN_CYCLE adress
WAIT_ASKED_TIME_IN_CYCLE
		LDR r3, =TRAVEL_TIME_IN_CYCLE
		STR r1, [r3]
		
		ADD r1, r1, #1			;; Add 1 prevent to sub 1 of 0, that give 0xFFFFFFFF

wait_asked_time_in_cycle_loop
		SUBS r1, #1
        BNE wait_asked_time_in_cycle_loop
		
		BX LR
		
		END