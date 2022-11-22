.model small
.stack 100h
.186
.data
Hello db "Maggseemus!$"
;row
;col
;mode
;char_ctr
.code
org 100h

start:
mov ax, @data
mov ds, ax
mov ah, 09h
mov dx, offset Hello
int 21h

mov ax, 4C00h
int 21h

end start
