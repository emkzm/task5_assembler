.model small
.stack 100h
.186
.data
;����������� ����������:

;row � ������, � ������� ��������� ������, ��������� �������� ����� 4
start_row db 5
row db 5
last_row db 20  
;col � �������, � ������� ��������� ������, ��������� �������� ����� 24
start_col db 30
col db 30
last_col db 50
;mode � ����� ������, ��������� �������� �� ���������� (����� ?)
mode db ?
;char � ASCII-������, * = 2ah (42)
char db 2Ah

top_left_corner db 30, 5     ; 04:24
bottom_right_corner db 50, 20 ; 19:54  

.code
start:
	mov ax,@data
	mov ds,ax
	call B10MODE ; ��������� ����� ������
	call C10CLEAR ; ������� ������

not_last: 
	;cmp2datas <row, last_row>
	;cmp row, last_row
	push ax
	mov al, row
	cmp al, last_row
	pop ax
	jg stop
	call D10CURSOR ; �������� �������
	call E10DISPLAY
	
	
	add col, 1 ; ��������� �������� ������� �� 2
	;cmp2datas <col, last_col> ; ��������� �� ����� ������� 56 = 24 + 16 * 2
	push ax
	mov al, col
	cmp al, last_col
	pop ax
	jne not_last ; ������� � ����� ������ 

	inc row ; �������� �������� row �� 1
	push ax
	mov al, start_col
	mov col, al ; � ������������� �������� col �� ������
	pop ax
	jmp not_last;

stop:
	mov ah, 10h ; ������ �� ��������� ������� � ����������
	int 16h

	mov ah, 00h ; ������� ��������� ������������ ������
	mov al, mode
	int 10h

mov ax,4C00h       ;���������� ���������
int 21h

;����������� �����������

B10MODE proc       ;���������/��������� �����������
	; �������� ������� ����� � �������� AL: 
	mov ah, 0fh ; � ������� AH ������� �������� 0Fh ����� ���� ���������� ���������� 10h.
	int 10h 
	; ��������� ����� �������� ������: 
	mov mode, al ; ������� � mode ���������� �������� AL.
	; ��������� ����� � ��������� ����� � ������� 03: 
	mov ah, 00h ; � ������� AH ���������� �������� 00h,
	mov al, 03h ;  � ������� AL � ����� ������ 03,
	int 10h ;  ����� ���� ���������� ���������� 10h.
	ret ; ��������� ������� �� ������������ � ����� ������.
B10MODE endp

C10CLEAR proc      ;������� ������
	pusha ; �������� � ���� ��� �������� ������ ����������.
	mov ah, 06h ; ������������ ����� ���� ����� ������� (��. ������� 06h).
	int 10h
	; ������� ���� � 16 �������� � 16 ���������: 
	mov ah, 06h ; � ������� AH ������� �������� 06h
	mov al, 10h ; � ������� AL � ����� ����� 16
	mov bh, 28h ; � ������� BH �������� �������� - �������(2) ���, ����� �������(7)  
	mov cl, top_left_corner ; � ������� CX � ���������� ������ �������� ���� 04:24
	mov ch, top_left_corner + 1
	mov dl, bottom_right_corner
	mov dh, bottom_right_corner + 1
	int 10h ; ����� ���� ���������� ���������� 10h.
	popa ; ��������� �� ����� ��� �������� ������ ����������
	ret ; ��������� ������� �� ������������ � ����� ������
C10CLEAR endp

D10CURSOR proc     ;��������� �������
	pusha ; �������� � ���� ��� �������� ������ ����������.
	; ������������� ������:
	mov ah, 02h; � ������� AH ������� �������� 02h
	mov bh, 0; � ������� BH � ����� �������� 0
	mov dh, row; � ������� DH � �������� ������ row
	mov dl, col; � ������� DL � �������� ������� col
	int 10h; ����� ���� ���������� ���������� 10h
	popa ; ��������� �� ����� ��� �������� ������ ����������
	ret ; ��������� ������� �� ������������ � ����� ������
D10CURSOR endp

E10DISPLAY proc    ;����� ������� �� �����
	pusha; �������� � ���� ��� �������� ������ ����������
	; ������� ������ � ������������� ��������� �� �����:
	mov ah, 0Ah; � ������� AH ������� �������� 0Ah
	mov al, char; � ������� AL � ASCII -��� ������� char
	mov bh, 0; � ������� BH � ����� �������� 0
	mov cx, 1; � ������� CX � ����� �������� 1
	int 10h; ����� ���� ���������� ���������� 10h
	popa; ��������� �� ����� ��� �������� ������ ����������
	ret ; ��������� ������� �� ������������ � ����� ������
E10DISPLAY endp

cmp2datas macro first, second ; cmp a, b 
	push ax
	mov al, first
	mov ah, second
	cmp al, ah
	pop ax
endm

end start          ;����� ���������