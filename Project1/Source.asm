.386
.model flat, stdcall

; ��������� ������� �������� ����������� ���������� extrn, 
; ����� ����� @ ����������� ����� ����� ������������ ����������,
; ����� ��������� ����������� ��������� ��������� � near
extrn  GetStdHandle@4:near
extrn  WriteConsoleA@20:near
extrn  CharToOemA@8:near
extrn  ReadConsoleA@20:near
extrn  ExitProcess@4:near ; ������� ������ �� ���������
extrn  lstrlenA@4:near ; ������� ����������� ����� ������

; ������� ������
.data
din dd ? ; ���������� �����
dout dd ? ; ���������� ������ (��������� dd ����������� ������ ������� 32 ���� (4 �����))
strn db "������� �����: ",13,10,0 ; ��������� ������, 
; ����������� �������: 13 � ������� �������, 10 � ������� �� ����� ������, 0 � ����� ������
; (� �������������� ��������� db ������������� ������ ������)
buf  db 200 dup (?); ����� ��� ��������/��������� ����� 
lens dd ? ; ���������� ���������� ��������
;��� �������� �����
numa dd ?
numb dd ?

; ������� ����
.code
start: ; ����� ����� ����� (����������� ����������)

; ������������ ������ strn
push offset strn ; ��������� ������� ���������� � ���� �������� 
; offset � ��������, ������������ ��������
push offset strn
call CharToOemA@8 ; ����� �������

; ������� ���������� ����� 
push -10
call GetStdHandle@4
mov din, eax ; ����������� ��������� �� �������� eax � ������ ������ � ������ din

; ������� ���������� ������
push -11
call GetStdHandle@4
mov dout, eax 

; ����� ������
push offset strn ; � ���� ���������� ��������� �� ������
call lstrlenA@4 ; ����� � eax
; ����� ������� writeconsolea ��� ������ ������ strn
push 0 ; � ���� ���������� 5-� ��������
push offset lens ; 4-� ��������
push eax ; 3-� ��������
push offset strn ; 2-� ��������
push dout ; 1-� ��������
call WriteConsoleA@20

; ���� ������
push 0 ; � ���� ���������� 5-� ��������
push offset lens ; 4-� ��������
push 200 ; 3-� ��������
push offset buf ; 2-� ��������
push din ; 1-� ��������
call ReadConsoleA@20 

; ��������� 1 ������
xor eax, eax
push offset buf
sub lens, 2
mov ecx, lens
mov esi,offset buf ; ������ ������ �������� � ���������� buf
xor ebx,ebx ; �������� ebx
xor eax,eax ; �������� eax
convert: ; ����� ������ �����
	xor edx, edx ; �������� edx
	mov dl, 10 ; �� ��� ����� ����� ��������, ������ � ����� �.�. ��� ��������� dx ����������
	mov bl, [esi] ; �������� ������ �� ��������� ������ � bl
	sub bl, '0' ; �������� �� ���������� ������� ��� ����
	mul edx ; �������� ������ �������� bx �� 10, ��������� � � ax
	add eax, ebx ; �������� � ����������� ����� ����� ��������	
	inc esi ; ������� �� ��������� ������
loop convert ; ����� �������� �����
mov numa, eax

; ����� ������
push offset strn ; � ���� ���������� ��������� �� ������
call lstrlenA@4
push 0 ; � ���� ���������� 5-� ��������
push offset lens ; 4-� ��������
push eax ; 3-� ��������
push offset strn ; 2-� ��������
push dout ; 1-� ��������
call WriteConsoleA@20

; ���� ������
push 0 ; � ���� ���������� 5-� ��������
push offset lens ; 4-� ��������
push 200 ; 3-� ��������
push offset buf ; 2-� ��������
push din ; 1-� ��������
call ReadConsoleA@20 

; ��������� 2 ������
xor eax, eax
push offset buf
sub lens, 2
mov ecx, lens
mov esi,offset buf ; ������ ������ �������� � ���������� buf
xor ebx, ebx ; �������� ebx
xor eax, eax ; �������� eax
convertb: ; ����� ������ �����
	xor edx,edx ; �������� edx
	mov dl, 10 ; �� ��� ����� ����� ��������, ������ � ����� �.�. ��� ��������� dx ����������
	mov bl, [esi] ; �������� ������ �� ��������� ������ � bl
	sub bl, '0' ; �������� �� ���������� ������� ��� ����
	mul dx ; �������� ������ �������� bx �� 10, ��������� � � ax
	add eax, ebx ; �������� � ����������� ����� ����� ��������	
	inc esi ; ������� �� ��������� ������
loop convertb ; ����� �������� �����
mov numb, eax

; �������� �����
mov eax, numa
mov ebx, numb
mul ebx
mov numa, eax




; �������������� ����������
xor edi, edi
mov edx, numa
xor eax, eax
mov ax, dx ; ax - ������� �����, dx - �������
shr edx, 16 ; �������� ������ 16 ��� � �����
xor ecx, ecx
mov ecx, 16
mov esi, offset buf ; ������ ������ �������� � ���������� buf
mov ebx, edx
shl ebx, 16 ; �������� 16 ��� �����
mov bx, ax ; � ebx �������� ������ �����
.while ebx>=ecx ; ���� ����� > 16
		div cx
		add dx, '0'	
		.if dx>'9' ; ���� ������ > 9, �������� �� A,B,...
		add dx, 7
		.endif	
		push edx ; ������ ������ � ����, ��� ��������������
		add edi, 1
		xor edx, edx
		xor ebx, ebx
		mov bx, ax
.endw
add ax, '0'
.if ax>'9'
	add ax, 7
.endif
push eax
add edi, 1
; ������ ����������� ������
mov ecx, edi
convertc:
	pop [esi]
	inc esi
loop convertc

; ������� ���������
push offset buf ; � ���� ���������� ��������� �� ������
call lstrlenA@4
push 0 ; � ���� ���������� 5-� ��������
push offset lens ; 4-� ��������
push eax ; 3-� ��������
push offset buf ; 2-� ��������
push dout ; 1-� ��������
call WriteConsoleA@20

; ����� �� ��������� 
push 0 ; ��������: ��� ������
call ExitProcess@4
end start