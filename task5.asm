.model small
.stack 100h
.186
.data 

top_left_corner dw 10, 20 ; row, column (y; x)
rect dw 10, 10 			  ; row, column (y; x)
bottom_right_corner db 20, 30
char_symb db 'D'
char_att db 05h
mode db ?

.code

;Определить текущий видеорежим и текущую активную страницу
;(функция 0Fh прерывания int 10h) и сохранить их в стеке
;Получение/установка видеорежима
B10MODE proc       
	; Получаем текущий режим в регистре AL: 
	mov ah, 0fh  ; в регистр AH заносим значение 0Fh после чего вызывается прерывание 10h.
	int 10h 
	; Сохраняем номер текущего режима: 
	mov mode, al ; заносим в mode содержимое регистра AL.
	; Переводим экран в текстовый режим с номером 03: 
	mov ah, 00h  ; в регистр AH помещается значение 00h,
	mov al, 03h  ; в регистр AL – номер режима 03, 25x80 страницы 0-7 
	int 10h      ;  после чего вызывается прерывание 10h.
	ret          ; Выполняем возврат из подпрограммы в точку вызова.
B10MODE endp

B10DISPLAY proc       ;Сохраняет символ и атрибут в области видеопамяти
	mov dl, char_symb  ; *
	mov dh, char_att ; 
	
	; ----------------------
	;di <- [( ((row = 5) * 80) + (column = 30) ) * 2]
	push dx
	mov dx, 0
	mov ax, top_left_corner
	mov bx, 80
	mul bx
	add ax, top_left_corner + 2
	mov bx, 2
	mul bx
	mov di, ax ; di = (top_left_corner.y * 80 + top_left_corner.x) * 2
	pop dx
	; --------------------
	;xor cx, cx
	mov cx, rect
	print_row:
		push cx
		mov cx, rect + 2
		print_line: 
			; вывод строки символов
			mov [es:di], dx
			add di, 2 ; след позиция в строке
			loop print_line
		
		; ---------------------
		; di += (2 * (80 - rect.x))
		push dx
		mov ax, 80
		sub ax, rect + 2
		mov dx, 0
		mul bx
		add di, ax
		pop dx
		; ---------------------
		pop cx
		
		inc dl
		inc dh
		loop print_row
		
	ret
B10DISPLAY endp

start:
	mov ax, @data
	mov ds, ax
	
	mov ax, 0b800h ;Используя сегментный регистр ES,  
	mov es, ax	   ;организовать запись данных в видеопамять
                   ;по адресу В800h:0000h (страница 0)
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