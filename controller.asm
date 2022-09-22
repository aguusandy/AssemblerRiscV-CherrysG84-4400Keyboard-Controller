
.# Controlador Cherry G84-4400

#  Matriz del teclado
# "Esc,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,PrtSc,Pause"
# "^,1,2,3,4,5,6,7,8,9,0,?,',Del,Home"
# "Tab,q,w,e,r,t,z,u,i,o,p,u,+,Enter,Pg Up"
# "Caps,a,s,d,f,g,h,j,k,l,O¨,A¨,',Pg On,"
# "ShifL,<,y,x,c,v,b,n,m,;,.,-,ShiftR,Up,End"
# "Fn,Ctrl,Alt,Space,Alt Gr,Insert,Delete,Left,Down,Right, , , , , "
.data
msgB1: .asciz "Boton1"
msgB2: .asciz "Boton2"
msgAmbos: .asciz "Boton 1 y 2"
F1: .asciz "\nF1"
F2: .asciz "\nF2"
F3: .asciz "\nF3"
F4: .asciz "\nF4"
F5: .asciz "\nF5"
F6: .asciz "\nF6"
F7: .asciz "\nF7"
F8: .asciz "\nF8"
F9: .asciz "\nF9"
F10: .asciz "\nF10"
F11: .asciz "\nF11"
F12: .asciz "\nF12"
Esc: .asciz "\nEscape"
PrtSc: .asciz "\nPrint Screen"
Tab: .asciz "\nTab"
Pause: .asciz "\nPause"
Del: .asciz "\nDelete"
Home: .asciz "\nHome"
Enter: .asciz "\nEnter"
PgUp: .asciz "\nPg Up"
O2: .asciz "\nO¨"
A2: .asciz "\nA¨"
U2: .asciz "\nU¨"
PgDn: .asciz "\nPg Dn"
ShiftL: .asciz "\nShifL"
ShiftR: .asciz "\nShiftR"
Up: .asciz "\nUp"
End: .asciz "\nEnd"
Fn: .asciz "\nFn"
Ctrl: .asciz "\nCtrl"
Alt: .asciz "\nAlt"
Space: .asciz "\nSpace"
AltGr: .asciz "\nAlt Gr"
Insert: .asciz "\nInsert"
Delete: .asciz "\nDelete"
Left: .asciz "\nLeft"
Down: .asciz "\nDown"
Right: .asciz "\nRight"

.text
# cargamos las posiciones de memoria del puerto
	lui t0, 0x10000		# puerto 0x10000
	lw t1, 0(t0)		# almaceno en t1 el dato del puerto 0x10000
	lui t0, 0x10001		# puerto 0x10001	
	lw t2, 0(t0)		# almaceno en t2 el dato del puerto 0x10001
	lui t0, 0x10002		# puerto 0x10002	
	lw t3, 0(t0)		# almaceno en t3 el dato del puerto 0x10002
	lui t0, 0x10003		# puerto 0x10003	
	lw t4, 0(t0)		# almaceno en t4 el dato del puerto 0x10003

main:
	j mouse	
#---------------------------- MOUSE ---------------------------------------------------------------
mouse:
# copio los bits 6 y 7 de la posicion de memoria 0x10001
	andi a0,t2,0x000000c0	# guardo el valor en hexa de los bits activados
	bne zero,a0,botMouse		#  si algun boton esta activado
	beq zero,a0,posMouse		#  si ningun boton esta activado
	
#------------------- Botones del mouse ------------------------------------------------------------
botMouse:
	addi s0,zero,0x40		# s0 = 0x40
	beq s0,a0,actBot1	# si el boton de la derecha esta activado
	addi s0,s0,0x40		# s0 = 0x80
	beq s0,a0,actBot2	# si el boton de la izq esta activado
	addi s0,s0,0x40		# s0 = 0xc0
	beq s0,a0,actBot3	# si ambos botones estan activado
	
actBot1:
	la a0, msgB1	# cargo el mensaje 
	j mostrar
actBot2:
	la a0, msgB2	# cargo el mensaje 
	j mostrar
actBot3:
	la a0, msgAmbos # cargo el mensaje 
	j mostrar

#------------------- Posicion del mouse ------------------------------------------------------------
posMouse:
	# en t3 se almacena la posicion del mouse con respecto al eje X
	# en t4 se almacena la posicion del mouse con respecto al eje Y
	add a0,zero,t3	#muestra en pantalla la posicion del mouse en el eje X ?
	addi a7,zero,1
	ecall
	add a0,zero,t4	#muestra en pantalla la posicion del mouse en el eje Y ?
	addi a7,zero,1
	ecall
	j teclado
	
#---------------------------- TECLADO ---------------------------------------------------------------

teclado:
# busco primero la fila de la tecla activada
	andi a1,t2,0x0000003f	# copio los primeros 6 bits de la posicion 0x10001 para obtener la fila	
	bne zero,a1,buscoFila		# si no se apretó ninguna tecla va al main
	#beq zero,a1,irAOtroLado
buscoFila:
	andi a2,t1,0x0000000f	# copio los primeros 4 bits del puerto 0x10000 para saber la columna	
	add s2,zero,zero	# bits: 0000, me va a servir para saber la columna
	addi s1,zero,0x1	# bits: 000001
	beq s1,a1,fila1		# si el bit 0 esta activado corresponde a la fila 1 
	addi s1,zero,0x2	# bits: 000010
	beq s1,a1,fila2		# si el bit 1 esta activado corresponde a la fila 2
	addi s1,zero,0x4	# bits: 000100
	beq s1,a1,fila3		# si el bit 2 esta activado corresponde a la fila 3
	addi s1,zero,0x8	# bits: 001000
	beq s1,a1,fila4		# si el bit 3 esta activado corresponde a la fila 4
	addi s1,zero,0x10	# bits: 010000
	beq s1,a1,fila5		# si el bit 4 esta activado corresponde a la fila 5
	addi s1,zero,0x20	# bits: 100000
	beq s1,a1,fila6		# si el bit 5 esta activado corresponde a la fila 6

# busco la columna que corresponda, ya que cada fila va a tener distintas cantidades de columna
fila1:	# fila 1 tiene 15 columnas
	beq s2,a2,impEsc # fila 1, columna 1
	addi s2,s2,0x1	# bit 0001
	beq s2,a2,impF1 # fila 1, columna 2
	addi s2,s2,0x1	# bit 0010
	beq s2,a2,impF2 # fila 1, columna 3
	addi s2,s2,0x1	# bit 0011
	beq s2,a2,impF3 # fila 1, columna 4
	addi s2,s2,0x1	# bit 0100
	beq s2,a2,impF4 # fila 1, columna 5
	addi s2,s2,0x1	# bit 0101
	beq s2,a2,impF5 # fila 1, columna 6
	addi s2,s2,0x1	# bit 0110
	beq s2,a2,impF6 # fila 1, columna 7
	addi s2,s2,0x1	# bit 0111
	beq s2,a2,impF7 # fila 1, columna 8
	addi s2,s2,0x1	# bit 1000
	beq s2,a2,impF8 # fila 1, columna 9
	addi s2,s2,0x1	# bit 1001
	beq s2,a2,impF9 # fila 1, columna 10
	addi s2,s2,0x1	# bit 1010
	beq s2,a2,impF10 # fila 1, columna 11
	addi s2,s2,0x1	# bit 1011
	beq s2,a2,impF11 # fila 1, columna 12
	addi s2,s2,0x1	# bit 1100
	beq s2,a2,impF12 # fila 1, columna 13
	addi s2,s2,0x1	# bit 1101
	beq s2,a2,impPrtSc # fila 1, columna 14
	addi s2,s2,0x1	# bit 1110
	beq s2,a2,impPause # fila 1, columna 15
	
fila2:	# fila 2 tiene 15 columnas
	beq s2,a2,impCFlex # fila 2, columna 1
	addi s2,s2,0x1	# bit 0001
	beq s2,a2,imp1 # fila 2, columna 2
	addi s2,s2,0x1	# bit 0010
	beq s2,a2,imp2 # fila 2, columna 3
	addi s2,s2,0x1	# bit 0011
	beq s2,a2,imp3 # fila 2, columna 4
	addi s2,s2,0x1	# bit 0100
	beq s2,a2,imp4 # fila 2, columna 5
	addi s2,s2,0x1	# bit 0101
	beq s2,a2,imp5 # fila 2, columna 6
	addi s2,s2,0x1	# bit 0110
	beq s2,a2,imp6 # fila 2, columna 7
	addi s2,s2,0x1	# bit 0111
	beq s2,a2,imp7 # fila 2, columna 8
	addi s2,s2,0x1	# bit 1000
	beq s2,a2,imp8 # fila 2, columna 9
	addi s2,s2,0x1	# bit 1001
	beq s2,a2,imp9 # fila 2, columna 10
	addi s2,s2,0x1	# bit 1010
	beq s2,a2,imp0 # fila 2, columna 11
	addi s2,s2,0x1	# bit 1011
	beq s2,a2,impSPreg # fila 2, columna 12
	addi s2,s2,0x1	# bit 1100
	beq s2,a2,impAcento # fila 2, columna 13
	addi s2,s2,0x1	# bit 1101
	beq s2,a2,impBorrar # fila 2, columna 14
	addi s2,s2,0x1	# bit 1110
	beq s2,a2,impHome # fila 2, columna 15
	
fila3:	# fila 3 tiene 15 columnas
	beq s2,a2,impTab # fila 3, columna 1
	addi s2,s2,0x1	# bit 0001
	beq s2,a2,impQ # fila 3, columna 2
	addi s2,s2,0x1	# bit 0010
	beq s2,a2,impW # fila 3, columna 3
	addi s2,s2,0x1	# bit 0011
	beq s2,a2,impE # fila 3, columna 4
	addi s2,s2,0x1	# bit 0100
	beq s2,a2,impR # fila 3, columna 5
	addi s2,s2,0x1	# bit 0101
	beq s2,a2,impT # fila 3, columna 6
	addi s2,s2,0x1	# bit 0110
	beq s2,a2,impZ # fila 3, columna 7
	addi s2,s2,0x1	# bit 0111
	beq s2,a2,impU # fila 3, columna 8
	addi s2,s2,0x1	# bit 1000
	beq s2,a2,impI # fila 3, columna 9
	addi s2,s2,0x1	# bit 1001
	beq s2,a2,impO # fila 3, columna 10
	addi s2,s2,0x1	# bit 1010
	beq s2,a2,impP # fila 3, columna 11
	addi s2,s2,0x1	# bit 1011
	beq s2,a2,impU # fila 3, columna 12
	addi s2,s2,0x1	# bit 1100
	beq s2,a2,impAsterico # fila 3, columna 13
	addi s2,s2,0x1	# bit 1101
	beq s2,a2,impEnter # fila 3, columna 14
	addi s2,s2,0x1	# bit 1110
	beq s2,a2,impPgUp # fila 3, columna 15

fila4:	# fila 4 tiene 14 columnas
	beq s2,a2,ledCaps # fila 4, columna 1 -> Enciendo o Apago el Led de Caps
	addi s2,s2,0x1	# bit 0001
	beq s2,a2,impA # fila 4, columna 2
	addi s2,s2,0x1	# bit 0010
	beq s2,a2,impS # fila 4, columna 3
	addi s2,s2,0x1	# bit 0011
	beq s2,a2,impD # fila 4, columna 4
	addi s2,s2,0x1	# bit 0100
	beq s2,a2,impF # fila 4, columna 5
	addi s2,s2,0x1	# bit 0101
	beq s2,a2,impG # fila 4, columna 6
	addi s2,s2,0x1	# bit 0110
	beq s2,a2,impH # fila 4, columna 7
	addi s2,s2,0x1	# bit 0111
	beq s2,a2,impJ # fila 4, columna 8
	addi s2,s2,0x1	# bit 1000
	beq s2,a2,impK # fila 4, columna 9
	addi s2,s2,0x1	# bit 1001
	beq s2,a2,impL # fila 4, columna 10
	addi s2,s2,0x1	# bit 1010
	beq s2,a2,impO2 # fila 4, columna 11
	addi s2,s2,0x1	# bit 1011
	beq s2,a2,impA2 # fila 4, columna 12
	addi s2,s2,0x1	# bit 1100
	beq s2,a2,impComilla # fila 4, columna 13
	addi s2,s2,0x1	# bit 1101
	beq s2,a2,impPgDn # fila 4, columna 14
	
fila5:	# fila 5 tiene 15 columnas
	beq s2,a2,impShiftL # fila 5, columna 1
	addi s2,s2,0x1	# bit 0001
	beq s2,a2,impMenor # fila 5, columna 2
	addi s2,s2,0x1	# bit 0010
	beq s2,a2,impY # fila 5, columna 3
	addi s2,s2,0x1	# bit 0011
	beq s2,a2,impX # fila 5, columna 4
	addi s2,s2,0x1	# bit 0100
	beq s2,a2,impC # fila 5, columna 5
	addi s2,s2,0x1	# bit 0101
	beq s2,a2,impV # fila 5, columna 6
	addi s2,s2,0x1	# bit 0110
	beq s2,a2,impB # fila 5, columna 7
	addi s2,s2,0x1	# bit 0111
	beq s2,a2,impN # fila 5, columna 8
	addi s2,s2,0x1	# bit 1000
	beq s2,a2,impM # fila 5, columna 9
	addi s2,s2,0x1	# bit 1001
	beq s2,a2,impComa # fila 5, columna 10
	addi s2,s2,0x1	# bit 1010
	beq s2,a2,impPunto # fila 5, columna 11
	addi s2,s2,0x1	# bit 1011
	beq s2,a2,impGuion # fila 5, columna 12
	addi s2,s2,0x1	# bit 1100
	beq s2,a2,impShiftR # fila 5, columna 13
	addi s2,s2,0x1	# bit 1101
	beq s2,a2,impUp # fila 5, columna 14
	addi s2,s2,0x1	# bit 1110
	beq s2,a2,impEnd # fila 5, columna 15
	
fila6:	# fila 6 tiene 10 columnas
	beq s2,a2,impFn # fila 1, columna 1
	addi s2,s2,0x1	# bit 0001
	beq s2,a2,impCtrl # fila 1, columna 2
	addi s2,s2,0x1	# bit 0010
	beq s2,a2,impAlt # fila 1, columna 3
	addi s2,s2,0x1	# bit 0011
	beq s2,a2,impEspacio # fila 1, columna 4
	addi s2,s2,0x1	# bit 0100
	beq s2,a2,impAltGr # fila 1, columna 5
	addi s2,s2,0x1	# bit 0101
	beq s2,a2,impInsert # fila 1, columna 6
	addi s2,s2,0x1	# bit 0110
	beq s2,a2,impDel # fila 1, columna 7
	addi s2,s2,0x1	# bit 0111
	beq s2,a2,impLeft # fila 1, columna 8
	addi s2,s2,0x1	# bit 1000
	beq s2,a2,impDown # fila 1, columna 9
	addi s2,s2,0x1	# bit 1001
	beq s2,a2,impRight # fila 1, columna 10

impEsc:	la a0,Esc
		j mostrar
impF1:	la a0,F1
		j mostrar
impF2:	la a0,F2
		j mostrar
impF3:	la a0,F3
		j mostrar
impF4:	la a0,F4
		j mostrar
impF5:	la a0,F5
		j mostrar
impF6:	la a0,F6
		j mostrar
impF7:	la a0,F7
		j mostrar
impF8:	la a0,F8
		j mostrar
impF9:	la a0,F9
		j mostrar
impF10:	la a0,F10
		j mostrar
impF11:	la a0,F11
		j mostrar
impF12:	la a0,F12
		j mostrar
impPrtSc:	la a0,PrtSc
			j mostrar
impPause:	la a0,Pause
			j mostrar
impCFlex:	li a0,'^'
			j mostrar
imp1:	li a0,'1'
		j mostrar
imp2:	li a0,'2'
		j mostrar
imp3:	li a0,'3'
		j mostrar
imp4:	li a0,'4'
		j mostrar
imp5:	li a0,'5'
		j mostrar
imp6:	li a0,'6'
		j mostrar
imp7:	li a0,'7'
		j mostrar
imp8:	li a0,'8'
		j mostrar
imp9:	li a0,'9'
		j mostrar
imp0:	li a0,'0'
		j mostrar
impSPreg:	li a0,'?'
			j mostrar
impAcento:	li a0,'´'
			j mostrar
impBorrar:	la a0,Delete
			j mostrar
impHome:	la a0,Home
			j mostrar
impTab:		la a0,Tab
			j mostrar
impQ :	li a0,'Q'
		j mostrar
impW:	li a0,'W'
		j mostrar
impE:	li a0,'E'
		j mostrar
impR:	li a0,'R'
		j mostrar
impT:	li a0,'T'
		j mostrar
impZ:	li a0,'Z'
		j mostrar
impU:	li a0,'U'
		j mostrar
impI:	li a0,'T'
		j mostrar
impO:	li a0,'O'
		j mostrar
impP:	li a0,'P'
		j mostrar
impU2:	la a0,U2
		j mostrar
impAsterico:	li a0,'*'
				j mostrar
impEnter:	la a0,Enter
			j mostrar
impPgUp:	la a0,PgUp
			j mostrar
impA:	li a0,'A'
		j mostrar
impS:	li a0,'S'
		j mostrar
impD:	li a0,'D'
		j mostrar
impF:	li a0,'F'
		j mostrar
impG:	li a0,'G'	
		j mostrar
impH:	li a0,'H'
		j mostrar
impJ:	li a0,'J'
		j mostrar
impK:	li a0,'K'
		j mostrar
impL:	li a0,'L'
		j mostrar
impO2:	la a0,O2
		j mostrar
impA2:	la a0,A2
		j mostrar
impComilla:	li a0,'"'
			j mostrar
impPgDn:	la a0,PgDn
			j mostrar
impShiftL:	la a0,ShiftL
			j mostrar
impMenor:	li a0,'<'
			j mostrar
impY:	li a0,'Y'
		j mostrar
impX:	li a0,'X'
		j mostrar
impC:	li a0,'C'
		j mostrar
impV:	li a0,'V'
		j mostrar
impB:	li a0,'B'
		j mostrar
impN:	li a0,'N'
		j mostrar
impM:	li a0,'M'
		j mostrar
impComa:	li a0,','
			j mostrar
impPunto:	li a0,'.'
			j mostrar
impGuion:	li a0,'-'
			j mostrar
impShiftR:	la a0,ShiftR
			j mostrar
impUp:	la a0,Up
		j mostrar
impEnd:	la a0,End
		j mostrar
impFn:	la a0,Fn
		j mostrar
impCtrl:	la a0,Ctrl
			j mostrar
impAlt:		la a0,Alt
			j mostrar
impEspacio:		li a0,' '
				j mostrar
impAltGr:	la a0,AltGr
			j mostrar
impInsert:	la a0,Insert
			j mostrar
impDel:	la a0,Delete
		j mostrar
impLeft:	la a0,Left
			j mostrar
impDown:	la a0,Down
			j mostrar
impRight:	la a0,Right
			j mostrar

#---------------------------- LEDS ---------------------------------------------------------------	
# Caps			->  ledCaps
# Fn + F11		->	ledPad
# Fn + F12		->  ledNums
# Fn + Borrar 	->	ledScroll
# 0x10000 bits de 4 a 7 corresponden a los leds
	andi a3,t0, 0x000000F0
#los bits de los led estan guardados en el registro a0
#encender o apagar Num -> bit 7
ledNum:
	addi s3,a0,0x00000080 # 0x00000080 tiene solo el bit 7 en 1 solo
	beq s3,zero,encNum  #si es igual a zero, esta el bit apagado, entonces se enciende
#encender o apagar Caps -> bit 6
ledCaps:
	addi s2,a0,0x00000040 # 0x00000040 tiene solo el bit 6 en 1
	beq s2,zero,encCaps #si es igual a zero, esta el bit apagado, entonces se enciende
ledScroll:
	addi s2,a0,0x00000020 # 0x00000020 tiene solo el bit 5 en 1
	beq s2,zero,encScroll #si es igual a zero, esta el bit apagado, entonces se enciende
#encender o apagar Pad -> bit 4
ledPad:
	addi s2,a0,0x00000010	# 0x00000080 tiene solo el bit 4 en 1 solo
	beq s2,zero,encPad #si es igual a zero, esta el bit apagado, entonces se enciende
		
encNum:
	addi s4,t0,0x00000080
	sw t0,0(s4) #guarda el valor leido del puerto con el bit del led encendido
encCaps:
	addi s4,t0,0x00000040
	sw t0,0(s4)
encScroll:
	addi s4,t0,0x00000020
	sw t0,0(s4) #guarda el valor leido del puerto con el bit del led encendido
encPad:
	addi s4,t0,0x00000010
	sw t0,0(s4)
		
mostrar:
	addi a7,zero,4	#mostrar la tecla o boton pulsada
	ecall
	j main	
