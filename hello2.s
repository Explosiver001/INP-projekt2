; Autor reseni: Michal Novak xnovak3g

; xnovak3g-r15-r16-r25-r26-r0-r4

; Projekt 2 - INP 2022
; Vernamova sifra na architekture MIPS64

; DATA SEGMENT
                .data
login:          .asciiz "xnovak3g"  ; sem doplnte vas login
cipher:         .space  17  ; misto pro zapis sifrovaneho loginu
key:            .asciiz "no" ; sifrovaci klic
limits:         .ascii "az" ; meze 


params_sys5:    .space  8   	; misto pro ulozeni adresy pocatku
						; retezce pro vypis pomoci syscall 5
						; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text

main:
            ;uprava hodnot sifrovaciho klice
            daddi   r25, r0, key    	;klic do r25
			lb      r16, 0(r25)     	;prvni znak klice
            daddi   r26, r0, limits     ;limits do r26
            lb      r26, 0(r26)         ;'a' do r26
			daddi   r16, r16, 1	
            sub     r16, r16, r26
            sb      r16, 0(r25) 
            
			lb      r16, 1(r25)     	;druhy znak klice
			daddi   r16, r16, 1	
            sub     r16, r16, r26
            sb      r16, 1(r25)

			daddi   r4, r0, login   ;r4 obsahuje odkaz na login 
			daddi   r26, r0, cipher ;r26 obsahuje odkaz na cipher

            

	;cykleni pres znaky loginu
	_loop: 		
            ;++++++++++++++++++++++++++++++++++++++
            lb      r15, 0(r4)          ;login[x%2==0]

            ;osetreni cisla  
            daddi   r25, r0, limits     ;limits do r25
            lb      r25, 0(r25)         ;a znak pro porovnani
            slt     r16, r15, r25	    ;porovnani login[x%2==0] < 'a'
            bnez    r16, _end_loop 		;login[x%2==0] je cislo

			;pricteni prvniho znaku klice
			
            daddi   r25, r0, key    	;klic do r25
			lb      r25, 0(r25)     	;prvni znak klice
			add     r15, r25, r15   	;r15 = login[x%2==0] + klic[0]

			jal     limits_check    	;osetreni mezi a-z
			
			sb      r15, 0(r26)     	;ulozeni znaku do cipher
			daddi   r26, r26, 1     	;posun na dalsi znak loginu
			daddi   r4, r4, 1       	;posun na dalsi znak loginu
			

			;--------------------------------------
			lb      r15, 0(r4)			;login[x%2==1]

			;osetreni cisla
			daddi   r25, r0, limits     ;limits do r25
			lb      r25, 0(r25)         ;a znak pro porovnani
			slt     r16, r15, r25       ;porovnani login[x%2==1] < 'a'
			bnez    r16, _end_loop		;login[x%2==1] je cislo

			;odecteni druheho znaku klice

			daddi   r25, r0, key    	;klic do r25
			lb      r25, 1(r25)     	;prvni znak klice
			sub     r15, r15, r25		;r15 = login[x%2==1] - klic[1]

			jal     limits_check    	;osetreni mezi a-z
			
			sb      r15, 0(r26)     	;ulozeni znaku do cipher
			daddi   r26, r26, 1     	;posun na dalsi znak loginu
			daddi   r4, r4, 1       	;posun na dalsi znak loginu

			b _loop						;skok na _loop
    _end_loop:


			daddi   r4, r0, cipher   ; vozrovy vypis: adresa login: do r4
			jal     print_string    ; vypis pomoci print_string - viz nize


			syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
			sw      r4, params_sys5(r0)
			daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
			syscall 5   ; systemova procedura - vypis retezce na terminal
			jr      r31 ; return - r31 je urcen na return address




limits_check: ; kontroluje se znak v r15
			;oseteni vyteceni zespoda 
			daddi   r25, r0, limits     ;limits do r25
			lb      r25, 0(r25)         ;a znak pro porovnani
			slt     r16, r15, r25
			beqz    r16, _end_if_a		;znak > 'a'

	_if_below_a:
			sub     r15, r25, r15       ;r15 = znak - 'a'
			daddi   r25, r0, limits     ;limits do r25
			lb      r25, 1(r25)         ;z znak pro porovnani
			sub     r15, r25, r15       ;r15 = 'z' - (znak - 'a')
			daddi   r15, r15, 1			;r15 = 'z' - (znak - 'a') + 1
	_end_if_a:

			;oseteni preteceni shora 
			daddi   r25, r0, limits     ;limits do r25
			lb      r25, 1(r25)         ;z znak pro porovnani
			slt     r16, r25, r15
			beqz    r16, _end_if_z		;znak < 'z'

	_if_above_z:
			sub     r15, r15, r25
			daddi   r25, r0, limits     ;limits do r25
			lb      r25, 0(r25)         ;a znak pro porovnani
			add     r15, r25, r15		;r15 = znak - 'z' + 'a'
			daddi   r15, r15, -1		;r15 = znak - 'z' + 'a' + 1
	_end_if_z:

			jr      r31                 ; return
