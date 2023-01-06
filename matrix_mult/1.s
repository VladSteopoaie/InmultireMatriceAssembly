.data
lungimeDrum: .space 4
nodSursa: .space 4
nodDestinatie: .space 4
nrNoduri: .space 4
auxiliar: .space 4
cerinta: .space 4
legaturi: .space 400
size: .long 4
m1: .space 40000
m2: .space 40000
mres: .space 40000
dimensiune: .space 4

formatCitire: .asciz "%d"
formatAfisare: .asciz "%d "
newline: .asciz "\n"

.text

.global main

#print_newline()
#afiseaza un \n in consola
print_newline:
	push $newline
	call printf	
	addl $4, %esp
	ret

#access_element(i, j, n) 
#-> returneaza in eax valoarea la care poate fi 
#accesat elementul prin matrix(%eax)
access_element: 
	#formula de accesare matrix + j * size + i * nrNoduri * size (size = 4)
	push %ebp
	movl %esp, %ebp
	push %ebx
	
	movl 8(%ebp), %eax #i
	movl 12(%ebp), %ecx #j
	movl 16(%ebp), %ebx #n
	
	mull %ebx
	mull size
	xchgl %eax, %ecx
	mull size
	addl %ecx, %eax

	pop %ebx
	pop %ebp
	ret

#afisare_matrice(m, n)
#afiseaza in consola matricea m
afisare_matrice:
	push %ebp
	movl %esp, %ebp
	push %ebx

	movl 8(%ebp), %ebx #m
	movl 12(%ebp), %ecx #n

	push %edi #i
	push %esi #j

	movl $0, %edi
	afisare_while1:
		cmp %edi, %ecx
		je exit_afisare_while1
		movl $0, %esi
		afisare_while2:
			cmp %esi, %ecx
			je exit_afisare_while2
			push %ecx #salvam n
			push %ecx
			push %esi
			push %edi
			call access_element #accesam elementul pentru afisat
			addl $12, %esp
			movl (%ebx, %eax, 1), %ecx
			
			push %ecx
			push $formatAfisare
			call printf #afisam elementul
			addl $8, %esp
			pop %ecx
			incl %esi
			jmp afisare_while2
		exit_afisare_while2:
		push %ecx
		call print_newline
		pop %ecx
		
		incl %edi
		jmp afisare_while1
	exit_afisare_while1:

	pop %esi
	pop %edi
	pop %ebx
	pop %ebp
	ret

#cp_matrix(m1, m2, n)
#copiaza matricea m1 in m2
cp_matrix:
	push %ebp
	movl %esp, %ebp
	push %ebx
	push %edi
	push %esi

	movl 8(%ebp), %esi #m1
	movl 12(%ebp), %edi #m2
	movl 16(%ebp), %ebx #n

	movl $0, %eax #eax = i
	cp_matrix_while1:
		cmp %eax, %ebx
		je exit_cp_matrix_while1
		movl $0, %edx #edx = j
		cp_matrix_while2:
			cmp %edx, %ebx
			je exit_cp_matrix_while2
			push %eax
			push %edx #salvam indicii
			break1:
			push %ebx
			push %edx
			push %eax
			call access_element
			addl $12, %esp
			break2:
			movl (%esi, %eax, 1), %ecx
			movl %ecx, (%edi, %eax, 1)
			
			pop %edx
			pop %eax

			incl %edx
			jmp cp_matrix_while2
		exit_cp_matrix_while2:
		incl %eax
		jmp cp_matrix_while1
	exit_cp_matrix_while1:

	pop %esi
	pop %edi
	pop %ebx
	pop %ebp
	ret

#matrix_mult(m1, m2, mres, n)
#inmulteste matricea m1 cu matricea m2 si pastreaza
#rezultatul in mres
matrix_mult:
	push %ebp
	movl %esp, %ebp
	push %ebx
	push %esi
	push %edi

	movl 8(%ebp), %esi #m1
	movl 12(%ebp), %edi #m2
	movl 16(%ebp), %ebx #mres
	movb 20(%ebp), %cl #sub 100 deci incape intr-un byte

	movb $0, %al #al = i
	matrix_mult_while1:
		cmp %al, %cl
		je exit_matrix_mult_while1
		movb $0, %ah #ah = j
		matrix_mult_while2:
			cmp %ah, %cl
			je exit_matrix_mult_while2
			movl $0, %edx #in edx vom pastra suma produselor
			movb $0, %ch #ch = k
			matrix_mult_while3:
				cmp %ch, %cl
				je exit_matrix_mult_while3
				
				push %edx
				push %ebx
				push %ecx
				push %eax #salvam variabilele


				#accesam m1[i][k] si m2[k][j]
				movl $0, %edx
				movb %cl, %dl
				push %edx
				movb %ch, %dl
				push %edx
				movb %al, %dl
				push %edx
				call access_element
				addl $12, %esp
				
				movl %eax, %ebx
				
				pop %eax
				pop %ecx #restauram indicii
				push %ecx
				push %eax #ii salvam din nou			
				
				movl $0, %edx
				movb %cl, %dl
				push %edx
				movb %ah, %dl
				push %edx
				movb %ch, %dl
				push %edx
				call access_element
				addl $12, %esp

				movl (%edi, %eax, 1), %eax
				movl (%esi, %ebx, 1), %ebx
				mull %ebx
				movl %eax, auxiliar

				pop %eax
				pop %ecx
				pop %ebx
				pop %edx
				addl auxiliar, %edx

				incb %ch
				jmp matrix_mult_while3
			exit_matrix_mult_while3:

			push %eax
			push %edx
			push %ecx #salvam valorile
			movl $0, %edx
			movb %cl, %dl
			push %edx
			movb %ah, %dl
			push %edx
			movb %al, %dl
			push %edx
			call access_element
			addl $12, %esp


			pop %ecx
			pop %edx
			movl %edx, (%ebx, %eax, 1)
			pop %eax

			incb %ah
			jmp matrix_mult_while2
		exit_matrix_mult_while2:
		incb %al
		jmp matrix_mult_while1
	exit_matrix_mult_while1:

	pop %edi
	pop %esi
	pop %ebx
	pop %ebp
	ret

main:

#citire cerinta
push $cerinta
push $formatCitire
call scanf
addl $8, %esp

#citire numar noduri
push $nrNoduri
push $formatCitire
call scanf
addl $8, %esp

#citire legaturi - vector
movl $0, %ebx
cLegaturi_while:
	cmp %ebx, nrNoduri
	je exit_cLegaturi_while
	lea legaturi(, %ebx, 4), %eax
	push %eax
	push $formatCitire
	call scanf
	addl $8, %esp
	incl %ebx
	jmp cLegaturi_while
exit_cLegaturi_while:

#citire matrice de adiacenta
movl $0, %ebx # ebx = i
cMat_while1:
	cmp %ebx, nrNoduri
	je exit_cMat_while1
	movl legaturi(, %ebx, 4), %edi
	movl $0, %esi
	cMat_while2:
		cmp %esi, %edi
		je exit_cMat_while2
		push $auxiliar
		push $formatCitire
		call scanf
		addl $8, %esp
		#eax = j
		#accesam elementul din matrice pe pozitia i, j
		push nrNoduri
		push auxiliar
		push %ebx
		call access_element
		addl $12, %esp
		#acum putem accesa elementul din matrice cu m1(%eax)
		movl $1, m1(%eax)
		incl %esi
		jmp cMat_while2
	exit_cMat_while2:
	incl %ebx
	jmp cMat_while1
exit_cMat_while1:

movl cerinta, %eax
cmp $1, %eax
je cerinta1
cmp $2, %eax
je cerinta2
cmp $3, %eax
je cerinta3


cerinta1:
	push nrNoduri
	push $m1
	call afisare_matrice
	addl $8, %esp
exit_cerinta1:
jmp end

cerinta2:


#citire lungime drun, nod sursa si nod destinatie
push $lungimeDrum
push $formatCitire
call scanf
addl $8, %esp

push $nodSursa
push $formatCitire
call scanf
addl $8, %esp

push $nodDestinatie
push $formatCitire
call scanf
addl $8, %esp

push nrNoduri
push $m2
push $m1
call cp_matrix
addl $12, %esp

subl $1, lungimeDrum
movl $0, %ebx
cerinta2_while: #ridica matricea la puterea lungimeDrum - 1
	cmp %ebx, lungimeDrum
	je exit_cerinta2_while
	push nrNoduri
	push $mres
	push $m2
	push $m1
	call matrix_mult
	addl $16, %esp

	push nrNoduri	
	push $m2
	push $mres
	call cp_matrix
	addl $12, %esp

	incl %ebx
	jmp cerinta2_while
exit_cerinta2_while:

push nrNoduri
push nodDestinatie
push nodSursa
call access_element #acceseaza elementul dorit
addl $12, %esp

push mres(%eax)
push $formatAfisare
call printf #afisam elementul pe consola
addl $8, %esp

call print_newline
 

exit_cerinta2:
jmp end

cerinta3:

#citire lungime drun, nod sursa si nod destinatie
push $lungimeDrum
push $formatCitire
call scanf
addl $8, %esp

push $nodSursa
push $formatCitire
call scanf
addl $8, %esp

push $nodDestinatie
push $formatCitire
call scanf
addl $8, %esp

movl nrNoduri, %eax
mull %eax
mull size
movl %eax, dimensiune


#declararea dinamica a matricei mres -> ebx
movl    $192, %eax #valoarea pentru mmap2
movl    $0, %ebx #adresa de inceput (0 - lasam kernelul sa aleaga)
movl    dimensiune, %ecx #dimensiunea in bytes pe care o alocam
movl    $0x3, %edx #PROT_READ | PROT_WRITE (0x1 | 0x2) -> protection falgs for permissions (read & write)
movl    $0x22, %esi #MAP_PRIVATE | MAP_ANON -> mapping flags 
					#(memoria creata este privata, nu e accesibila din afara 
					#programului si este si anonima adica nu e asociata cu un fisier)
movl    $-1, %edi #nu exista FD daca avem MAP_ANON -> -1
movl    $0, %ebp #offset (0 - incepe de la inceput)
int     $0x80

movl %eax, %ebx

push %ebx
#declararea dinamica a matricei m2 -> edi
movl    $192, %eax 
movl    $0, %ebx
movl    dimensiune, %ecx 
movl    $0x3, %edx 
movl    $0x22, %esi 
movl    $-1, %edi 
movl    $0, %ebp
int     $0x80
pop %ebx

movl %eax, %edi

push %ebx
push %edi
#declararea dinamica a matricei m1 -> esi
movl    $192, %eax
movl    $0, %ebx
movl    dimensiune, %ecx 
movl    $0x3, %edx 
movl    $0x22, %esi 
movl    $-1, %edi 
movl    $0, %ebp
int     $0x80
pop %edi
pop %ebx

movl %eax, %esi

#acum avem in esi -> m1, edi -> m2, ebx -> mres declarate dinamic
#copiem m1 citit in esi si in edi

push nrNoduri
push %esi
push $m1
call cp_matrix
addl $12, %esp

push nrNoduri
push %edi
push $m1
call cp_matrix
addl $12, %esp

subl $1, lungimeDrum
movl $0, %edx
cerinta3_while: #ridica matricea la puterea lungimeDrum - 1
	cmp %edx, lungimeDrum
	je exit_cerinta3_while
	push %edx
	push nrNoduri
	push %ebx
	push %edi
	push %esi
	call matrix_mult
	addl $16, %esp

	push nrNoduri	
	push %edi
	push %ebx
	call cp_matrix
	addl $12, %esp
	pop %edx
	incl %edx
	jmp cerinta3_while
exit_cerinta3_while:

push nrNoduri
push nodDestinatie
push nodSursa
call access_element #acceseaza elementul dorit
addl $12, %esp

push (%ebx, %eax, 1)
push $formatAfisare
call printf #afisam elementul pe consola
addl $8, %esp

call print_newline

movl $11, %eax #valoarea pentru munmap
movl %ebx, %ebx #pointer catre mres (am pus sa se vada explicit)
movl dimensiune, %ecx #dimensiunea pentru eliberarea memoriei
int $0x80

movl $11, %eax
movl %edi, %ebx #pointer catre m2
movl dimensiune, %ecx
int $0x80

movl $11, %eax
movl %esi, %ebx #pointer catre m1
movl dimensiune, %ecx
int $0x80


exit_cerinta3:
jmp end

end:
movl $1, %eax
movl $0, %ebx
int $0x80
