.model small
.stack 100h
.186
.data
;Определение переменных:

;row – строка, в которой находится курсор, начальное значение равно 4
row db 4
;col – столбец, в котором находится курсор, начальное значение равно 24
col db 24
;mode – номер режима, начальное значение не определено (равно ?)
mode db ?
;char_ctr – счетчик ASCII-символов, начальное значение равно 0
char_ctr db 0

.code
start:
mov ax,@data
mov ds,ax
call B10MODE ; установка видео режима
call C10CLEAR ; очистка экрана

no_lsymbol_and_no_lim: 
call D10CURSOR ; устанока курсора
cmp char_ctr, 255 ; последний символ ?
je last_symbol  

inc char_ctr ; увеличить значение счетчика аски символов на 1
add col, 2 ; увеличить значение столбца на 2
cmp col, 56 ; достигнет ли конец столбца 56 = 24 + 16 * 2

jne no_lsymbol_and_no_lim 
; переход к новой строке 
inc row; увеличим значение row на 1
mov col, 24; и устанавливаем значение col на 24 (дефолт)
jmp no_lsymbol_and_no_lim;

last_symbol:
mov ah, 10h ; Запрос на получение символа с клавиатуры
int 16h

mov ah, 00h ; Возврат исходного графического режима
mov al, mode
int 10h

mov ax,4C00h       ;Завершение программы
int 21h

;Определение подпрограмм

B10MODE proc       ;Получение/установка видеорежима
mov ah, 0fh
int 10h
mov mode, al
mov ah, 00h
mov al, 03h
int 10h
ret
B10MODE endp

C10CLEAR proc      ;Очистка экрана
;Код подпрограммы
;. . .
ret
C10CLEAR endp

D10CURSOR proc     ;Установка курсора
;Код подпрограммы
;. . .
ret
D10CURSOR endp

E10DISPLAY proc    ;Вывод символа на экран
;Код подпрограммы
;. . .
ret
E10DISPLAY endp

end start          ;Конец программы