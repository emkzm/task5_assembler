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
color db 50h
top_left_corner db 20, 10     ; start position col:row
bottom_right_corner db 30, 20 ; x:y  

.code
start:
	mov ax,@data
	mov ds,ax
	call B10MODE ; установка видео режима
	call C10CLEAR ; очистка экрана

not_last: 
	;cmp2datas <rows, last_row>
	;cmp rows, last_row
	push ax
	mov al, rows
	cmp al, last_row
	pop ax
	jg stop
	call D10CURSOR ; устанока курсора
	call E10DISPLAY
	
	
	add cols, 1 ; увеличить значение столбца на 
	;cmp2datas <cols, last_col>
	push ax
	mov al, cols
	cmp al, last_col
	pop ax
	jne not_last  
	; переход к новой строке
	inc rows ; увеличим значение rows на 1
	inc char
	add color, 10h
	push ax
	mov al, start_col
	mov cols, al ; и устанавливаем значение cols на дефолт
	pop ax
	jmp not_last

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
	mov ah, 06h ; в регистр AH заносим значение 06h
	mov al, 10h ; в регистр AL – число строк 16
	mov bh, color ; в регистр BH значение атрибута color 
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

;cmp2datas macro first, second ; cmp a, b 
;	push ax
;	mov al, first
;	mov ah, second
;	cmp al, ah
;	pop ax
;endm

end start          ;Конец программы