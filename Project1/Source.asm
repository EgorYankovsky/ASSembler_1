.386
.model flat, stdcall

; прототипы внешних процедур описываются директивой extrn, 
; после знака @ указывается общая длина передаваемых параметров,
; после двоеточия указывается дистанция «ближняя» – near
extrn  GetStdHandle@4:near
extrn  WriteConsoleA@20:near
extrn  CharToOemA@8:near
extrn  ReadConsoleA@20:near
extrn  ExitProcess@4:near ; функция выхода из программы
extrn  lstrlenA@4:near ; функция определения длины строки

; сегмент данных
.data
din dd ? ; дескриптор ввода
dout dd ? ; дескриптор вывода (директива dd резервирует память объемом 32 бита (4 байта))
strn db "введите число: ",13,10,0 ; выводимая строка, 
; управляющие символы: 13 – возврат каретки, 10 – переход на новую строку, 0 – конец строки
; (с использованием директивы db резервируется массив байтов)
buf  db 200 dup (?); буфер для вводимых/выводимых строк 
lens dd ? ; количество выведенных символов
;два вводимых числа
numa dd ?
numb dd ?

; сегмент кода
.code
start: ; метка точки входа (завершается двоеточием)

; перекодируем строку strn
push offset strn ; параметры функции помещаются в стек командой 
; offset – операция, возвращающая смещение
push offset strn
call CharToOemA@8 ; вызов функции

; получим дескриптор ввода 
push -10
call GetStdHandle@4
mov din, eax ; переместить результат из регистра eax в ячейку памяти с именем din

; получим дескриптор вывода
push -11
call GetStdHandle@4
mov dout, eax 

; вывод строки
push offset strn ; в стек помещается указатель на строку
call lstrlenA@4 ; длина в eax
; вызов функции writeconsolea для вывода строки strn
push 0 ; в стек помещается 5-й параметр
push offset lens ; 4-й параметр
push eax ; 3-й параметр
push offset strn ; 2-й параметр
push dout ; 1-й параметр
call WriteConsoleA@20

; ввод строки
push 0 ; в стек помещается 5-й параметр
push offset lens ; 4-й параметр
push 200 ; 3-й параметр
push offset buf ; 2-й параметр
push din ; 1-й параметр
call ReadConsoleA@20 

; обработка 1 строки
xor eax, eax
push offset buf
sub lens, 2
mov ecx, lens
mov esi,offset buf ; начало строки хранится в переменной buf
xor ebx,ebx ; очистить ebx
xor eax,eax ; очистить eax
convert: ; метка начала цикла
	xor edx, edx ; очистить edx
	mov dl, 10 ; на это число будем умножать, делаем в цикле т.к. при умножении dx затирается
	mov bl, [esi] ; помещаем символ из введенной строки в bl
	sub bl, '0' ; вычитаем из введенного символа код нуля
	mul edx ; умножаем старое значение bx на 10, результат – в ax
	add eax, ebx ; добавить к полученному числу новое значение	
	inc esi ; перейти на следующую строку
loop convert ; новая итерация цикла
mov numa, eax

; вывод строки
push offset strn ; в стек помещается указатель на строку
call lstrlenA@4
push 0 ; в стек помещается 5-й параметр
push offset lens ; 4-й параметр
push eax ; 3-й параметр
push offset strn ; 2-й параметр
push dout ; 1-й параметр
call WriteConsoleA@20

; ввод строки
push 0 ; в стек помещается 5-й параметр
push offset lens ; 4-й параметр
push 200 ; 3-й параметр
push offset buf ; 2-й параметр
push din ; 1-й параметр
call ReadConsoleA@20 

; обработка 2 строки
xor eax, eax
push offset buf
sub lens, 2
mov ecx, lens
mov esi,offset buf ; начало строки хранится в переменной buf
xor ebx, ebx ; очистить ebx
xor eax, eax ; очистить eax
convertb: ; метка начала цикла
	xor edx,edx ; очистить edx
	mov dl, 10 ; на это число будем умножать, делаем в цикле т.к. при умножении dx затирается
	mov bl, [esi] ; помещаем символ из введенной строки в bl
	sub bl, '0' ; вычитаем из введенного символа код нуля
	mul dx ; умножаем старое значение bx на 10, результат – в ax
	add eax, ebx ; добавить к полученному числу новое значение	
	inc esi ; перейти на следующую строку
loop convertb ; новая итерация цикла
mov numb, eax

; сложение чисел
mov eax, numa
mov ebx, numb
mul ebx
mov numa, eax




; преобразование результата
xor edi, edi
mov edx, numa
xor eax, eax
mov ax, dx ; ax - младшая часть, dx - старшая
shr edx, 16 ; сдвигаем первые 16 бит в право
xor ecx, ecx
mov ecx, 16
mov esi, offset buf ; начало строки хранится в переменной buf
mov ebx, edx
shl ebx, 16 ; сдвигаем 16 бит влево
mov bx, ax ; в ebx хранится полное число
.while ebx>=ecx ; пока число > 16
		div cx
		add dx, '0'	
		.if dx>'9' ; если символ > 9, заменить на A,B,...
		add dx, 7
		.endif	
		push edx ; кладем данные в стек, для инвертирования
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
; теперь инвертируем строку
mov ecx, edi
convertc:
	pop [esi]
	inc esi
loop convertc

; выводим результат
push offset buf ; в стек помещается указатель на строку
call lstrlenA@4
push 0 ; в стек помещается 5-й параметр
push offset lens ; 4-й параметр
push eax ; 3-й параметр
push offset buf ; 2-й параметр
push dout ; 1-й параметр
call WriteConsoleA@20

; выход из программы 
push 0 ; параметр: код выхода
call ExitProcess@4
end start