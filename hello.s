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


params_sys5:    .space  8   ; misto pro ulozeni adresy pocatku
                            ; retezce pro vypis pomoci syscall 5
                            ; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text

                ; ZDE NAHRADTE KOD VASIM RESENIM
main:
                daddi   r4, r0, login
                daddi   r26, r0, cipher
                

    loop:
                ;++++++++++++++++++++++++++++++++++++++
                lb      r15, 0(r4)
                ;sb      r15, 0(r26)     ;help
                ;osetreni cisla + odecet hodnoty 'a' od prvniho znaku
                daddi   r25, r0, limits     ;klic do r25
                lb      r25, 0(r25)         ;znak a
                

                slt     r16, r15, r25
                bnez    r16, _end_loop

                sub     r15, r15, r25

                ;pricteni prvniho znaku klice
                daddi   r25, r0, key    ;klic do r25
                lb      r25, 0(r25)     ;prvni znak klice
                daddi   r25, r25, 1
                add     r15, r25, r15

                jal     limits_check    ;osetreni mezi a-z
                
                sb      r15, 0(r26)     ;ulozeni znaku
                daddi   r26, r26, 1     ;posun na dalsi znak loginu
                daddi   r4, r4, 1       ;posun na dalsi znak loginu
                

                ;--------------------------------------
                lb      r15, 0(r4)
                ;sb      r15, 0(r26)     ;help
                ;osetreni cisla + odecet hodnoty 'a' od prvniho znaku
                daddi   r25, r0, limits     ;klic do r25
                lb      r25, 0(r25)         ;znak a
                
                slt     r16, r15, r25
                bnez    r16, _end_loop

                add     r15, r15, r25

                ;pricteni prvniho znaku klice
                daddi   r25, r0, key    ;klic do r25
                lb      r25, 1(r25)     ;druhy znak klice
                daddi   r25, r25, 1
                sub     r15, r15, r25

                jal     limits_check    ;osetreni mezi a-z
                
                sb      r15, 0(r26)     ;ulozeni znaku
                daddi   r26, r26, 1     ;posun na dalsi znak loginu
                daddi   r4, r4, 1       ;posun na dalsi znak loginu

                b loop
        _end_loop:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; nesahat

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
                daddi   r25, r0, limits     ;klic do r25
                lb      r25, 0(r25)         ;a znak klice
                slt     r16, r15, r25
                beqz    r16, _end_if_a

        _if_below_a:
                sub     r15, r25, r15       ;znak - a
                daddi   r25, r0, limits     
                lb      r25, 1(r25)         
                sub     r15, r25, r15       ;z-(znak - a)
                daddi     r15, r15, 1
        _end_if_a:

                ;oseteni preteceni shora 
                daddi   r25, r0, limits     
                lb      r25, 1(r25)         
                slt     r16, r15, r25
                bnez    r16, _end_if_z

        _if_above_z:
                sub     r15, r15, r25
                daddi   r25, r0, limits     ;klic do r25
                lb      r25, 0(r25)         ;a znak klice
                add     r15, r25, r15
                daddi     r15, r15, -1
        _end_if_z:

                jr      r31                 ; return
