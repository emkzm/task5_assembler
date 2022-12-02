.model small
.stack 100h
.186
.data 

top_left_corner db 10, 20 ; row column
rect db 10, 10 			 ; row column
bottom_right_corner db 20, 30
char db 44h
color db 05h
mode db ?

.code

;Определить текущий видеорежим и текущую активную страницу
;(функция 0Fh прерывания int 10h) и сохранить их в стеке
	
B10MODE proc       ;Получение/установка видеорежима
	; Получаем текущий режим в регистре AL: 
	mov ah, 0fh ; в регистр AH заносим значение 0Fh после чего вызывается прерывание 10h.
	int 10h 
	; Сохраняем номер текущего режима: 
	mov mode, al ; заносим в mode содержимое регистра AL.
	; Переводим экран в текстовый режим с номером 03: 
	mov ah, 00h ; в регистр AH помещается значение 00h,
	mov al, 03h ;  в регистр AL – номер режима 03, 25x80 страницы 0-7 
	int 10h ;  после чего вызывается прерывание 10h.
	mov ah, 05h
	mov al, 01h ; первая страница
	int 10h
	ret ; Выполняем возврат из подпрограммы в точку вызова.
B10MODE endp

B10DISPLAY proc       ;Сохраняет символ и атрибут в области видеопамяти
	pusha
	mov al, char ; *
	mov ah, color ; 
	
	; ----------------------
	;di <- [( ((row = 5) * 80) + (column = 30) ) * 2]
	push ax
	push bx
	mov ax, word ptr top_left_corner
	mov bx, 80
	mul bx
	add ax, word ptr top_left_corner+1
	mov bx, 2
	mul bx
		mov di, ax
	pop bx
	pop ax
	; --------------------
	;xor cx, cx
	mov cx, word ptr rect
	print_row:
		push cx
		mov cx, word ptr rect+1
		mov al, char ; символ
		mov ah, color ; атрибут
		print_line: 
			; вывод строки символов
			mov es:word ptr[di], ax
			add di, 2 ; след позиция в строке
			loop print_line
			
		; ---------------------
		; n = ((80 - column) * 2 )
		push ax
		push bx
		mov ax, 80
		sub ax, word ptr top_left_corner+1
		mov bx, 2
		mul bx
			add di, ax 
		push bx
		pop ax
		; ---------------------
		
		pop cx
		;inc cx
		inc char
		inc color
		;cmp cx, word ptr rect ; последняя строка?
		;jne print_row ; нет - еще раз 
		loop print_row
		
	popa
	ret
B10DISPLAY endp

start:
	mov ax, @data
	mov ds, ax
	
	mov ax, 0b900h ;Используя сегментный регистр ES,  
	mov es, ax	   ;организовать запись данных в видеопамять
                   ;по адресу В900h:0000h (страница 1)
	call B10MODE
	call B10DISPLAY
	
	mov ah, 10h ; Запрос на получение символа с клавиатуры
	int 16h

	
	mov ah, 00h ; Возврат исходного графического режима
	mov al, mode
	int 10h
	
	mov ah, 05h
	mov al, 00h ; первая страница
	int 10h
	
	mov ax, 4C00h
	int 21h



end start