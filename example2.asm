.model small
.stack 100h
.186
.data
row db 5
col db 30
height db 15
long db 20
.code
start:
mov ax,@data
mov ds,ax
;Код главной программы
 
mov ax,0b900h         ;Используя сегментный регистр ES,   
mov es,ax             ;организовать запись данных в видеопамять
                      ;по адресу В900h:0000h (страница 1)

; mov ah, 0fh;Определить текущий видеорежим и текущую активную страницу
 ;int 10h;(функция 0Fh прерывания int 10h) и сохранить их в стеке
;. . .

mov ah, 00h;Установить видеорежим 03 (функция 00h прерывания int 10h)
mov al, 03h
int 10h
mov ah, 05h;и текущую страницу 01 (функция 05h прерывания int 10h)
mov al, 01h
int 10h;. . .

;Вызвать подпрограмму B10DISPLAY,
;которая подготавливает область вывода

call B10DISPLAY

;После завершения вывода программа ожидает нажатия клавиши
;и, восстановив исходную страницу и видеорежим, завершается
;. . .

mov ax,4C00h          ;Завершение программы
int 21h

;Определение подпрограммы

B10DISPLAY proc       ;Сохраняет символ и атрибут в области видеопамяти
pusha ; поместить в стек все регистры общ назначения
mov al, 2Ah ; символ * в аски
mov ah, 0A8h ; значение атрибута
;mov di, (((row*80)+col)*2)

mov Al, byte ptr row
mov bl, 80
mul bl
add AX, col
mov bx, 2
mul bx
mov di, AX

mov cx, 0

label1:
    push cx ; сохраняем cx
    mov cx, word ptr long ; кладём в сх длинну строки
    print:
        mov es:word ptr[di], ax ; al (символ) в первый байти видеостраницы
                                ; ah (атрибут) во второй байт
        add di, 2 ; переход к след позиции в строке
        loop print
    ; задать отступ для след строки 
    ;add di, (80-(col*2)) ; к знач добавляется n положений до начала след строки
    mov Al, col
    mov bl, 2
    mul bl
    mov bx, 80
    sub bx, ax
    mov di, bx

    pop cx ; восстановить из стека
    inc cx ; увеличить cx на единицу
    cmp cx, word ptr height
    jne label1

popa 
ret
B10DISPLAY endp

end start             ;Конец программы