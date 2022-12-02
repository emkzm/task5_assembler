.model small
.stack 100h
.186
.data
;Определение переменных:

;rows – строка, в которой находится курсор
start_row db 10
rows db 10
last_row db 20

;cols – столбец, в котором находится курсор
start_col db 10
cols db 10
last_col db 20

;mode – номер режима
mode db ?

;char – ASCII-символ для вывода
char db 44h
color db 05h ; attributes
top_left_corner db 20, 10     ; start position col:row
bottom_right_corner db 30, 20 ; x:y  

.code

dbcmp macro var1, var2
	push ax
	mov al, var1
	cmp al, var2
	pop ax
endm

dbmov macro var1, var2
	push ax
	mov al, var2
	mov var1, al
	pop ax
endm

start:
	mov ax,@data
	mov ds,ax
	call B10MODE ; установка видео режима
	call C10CLEAR ; очистка экрана

print: 
	dbcmp rows, last_row ; проверка на последний символ
	je stop
	call D10CURSOR ; устанока курсора
	call E10DISPLAY ; рисуем символ
	
	;переход на след элемент
	inc cols ; увеличить значение столбца на 1
	dbcmp cols, last_col ; проверим на конец столбца
	jne print  
	
	; переход к новой строке
	inc rows ; увеличим значение rows на 1
	inc char
	inc color
	dbmov cols, start_col ; заносим в переменную cols start_col
	jmp print

stop:
	mov ah, 10h ; Запрос на получение символа с клавиатуры
	int 16h

	mov ah, 00h ; Возврат исходного графического режима
	mov al, mode
	int 10h

mov ax,4C00h       ;Завершение программы
int 21h

;Определение подпрограмм

B10MODE proc       ;Получение/установка видеорежима
	; Получаем текущий режим в регистре AL: 
	mov ah, 0fh ; в регистр AH заносим значение 0Fh после чего вызывается прерывание 10h.
	int 10h 
	; Сохраняем номер текущего режима: 
	mov mode, al ; заносим в mode содержимое регистра AL.
	; Переводим экран в текстовый режим с номером 03: 
	mov ah, 00h ; в регистр AH помещается значение 00h,
	mov al, 03h ;  в регистр AL – номер режима 03,
	int 10h ;  после чего вызывается прерывание 10h.
	ret ; Выполняем возврат из подпрограммы в точку вызова.
B10MODE endp

C10CLEAR proc      ;Очистка экрана
	pusha ; Помещаем в стек все регистры общего назначения.
	mov ah, 06h ; Прокручиваем вверх весь экран целиком (см. функция 06h).
	int 10h
	; Создаем окно с 16 строками и 16 столбцами: 
	mov ah, 06h ; в регистр AH заносим значение 6 
	mov al, 10h ; в регистр AL – число строк 16
	mov bh, color ; в регистр BH значение color 
	mov cl, top_left_corner ; в регистр CX – координаты левого верхнего угла 04:24
	mov ch, top_left_corner + 1
	mov dl, bottom_right_corner
	mov dh, bottom_right_corner + 1
	int 10h ; после чего вызывается прерывание 10h.
	popa ; Загружаем из стека все регистры общего назначения
	ret ; Выполняем возврат из подпрограммы в точку вызова
C10CLEAR endp

D10CURSOR proc     ;Установка курсора
	pusha ; Помещаем в стек все регистры общего назначения.
	; Устанавливаем курсор:
	mov ah, 02h; в регистр AH заносим значение 02h
	mov bh, 0; в регистр BH – номер страницы 0
	mov dh, rows; в регистр DH – значение строки rows
	mov dl, cols; в регистр DL – значение столбца cols
	int 10h; после чего вызывается прерывание 10h
	popa ; Загружаем из стека все регистры общего назначения
	ret ; Выполняем возврат из подпрограммы в точку вызова
D10CURSOR endp

E10DISPLAY proc    ;Вывод символа на экран
	pusha; Помещаем в стек все регистры общего назначения
	; Выводим символ с установленным атрибутом на экран:
	mov ah, 0Ah; в регистр AH заносим значение 0Ah
	mov al, char; в регистр AL – ASCII -код символа char
	mov bh, 0; в регистр BH – номер страницы 0
	mov cx, 1; в регистр CX – число символов 1
	int 10h; после чего вызывается прерывание 10h
	popa; Загружаем из стека все регистры общего назначения
	ret ; Выполняем возврат из подпрограммы в точку вызова
E10DISPLAY endp

end start          ;Конец программы