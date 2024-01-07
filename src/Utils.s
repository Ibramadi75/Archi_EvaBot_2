		AREA    |.text|, CODE, READONLY
			
TRAVEL_DISTANCE_CM_ADR	EQU		0x20000000 ;; Distance à parcourir en cm

		ENTRY
		EXPORT INTERACTIONS_TO_DISTANCE
		EXPORT TRAVEL_DISTANCE_CM_ADR
			
		EXPORT INCR_VAL_STORED_IN_R1_ADR

		IMPORT LEFT_BUMPER_CT_ADR
		IMPORT RIGHT_BUMPER_CT_ADR
			
		IMPORT FIRST_SWITCH_CT_ADR
			
		EXPORT INIT_UTIL_ADRESS

;; a label to use for initializing all program's adress values to 0
INIT_UTIL_ADRESS
		MOV r0, #0
		; Charger l'adresse de TRAVEL_DISTANCE_CM_ADR et y stocker 0
		LDR r1, =TRAVEL_DISTANCE_CM_ADR
		STR r0, [r1]
		
		BX LR

;; convert user interactions to distance and store in in TRAVEL_DISTANCE_CM_ADR
INTERACTIONS_TO_DISTANCE
		LDR r0, =TRAVEL_DISTANCE_CM_ADR
		
		MOV r4, #0
		STR r4, [r0]

		LDR r1, =LEFT_BUMPER_CT_ADR
		LDR r2, [r1]
		MOV r3, #0x05
		
		MUL r4, r2, r3 ;; left bumper clic add 5 seconds

		LDR r1, =RIGHT_BUMPER_CT_ADR
		LDR r2, [r1]
		MOV r3, #0x01

		MUL r5, r2, r3 ;; right bumper clic add 5 seconds
		ADD r4, r4, r5
		
		LDR r1, =FIRST_SWITCH_CT_ADR
		LDR r2, [r1]
		MOV r3, #0x0A

		MUL r5, r2, r3 
		
		ADD r4, r4, r5
		
		STR r4, [r0]
		
		BX LR

;; to use, store an adress in r1 containing an adress you want to increment
;; take the value stored in adress which is stored in r1, increment 1 to it value, put the new value in the adress
INCR_VAL_STORED_IN_R1_ADR
		LDR r2, [r1]
		ADD r2, #0x01
		STR r2, [r1]
		
		BX LR
		
		END