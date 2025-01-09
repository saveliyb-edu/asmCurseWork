.model small
.stack 100h
.data
    msg1 db 'Secund do gudka: $'
    str db 5,7 dup (0) ;с клавиатуры
    max dw 0
    min dw 0
    num_18
    dw 18
    num_60
    dw 60
.code
.386
start:

    mov ax,@data
    mov ds,ax
    mov es,ax
    mov ah,9            ;вывод на экран
    lea dx,msg1
    int 21h
    mov ah,0ah          ;с клавиатуры
    lea dx,str
    int 21h
    lea si,str[2]
    call string_to_int
    test ax,ax
    jz exit
    mul num_18          ;кол-во срабатываний таймера в секунду
    ; mul num_60
    mov si,ax           ;запоминаем количество тиков
    mov di,dx
    mov ah,0
    int 1ah             ;получаем количество тиков с момента запуска
    add dx,si
    adc cx,di
    mov min,dx
    mov max,cx
kol:
    mov ah,0
    int 1ah
    mov si,min
    mov di,max
    sub si,dx           ;вычитаем из него текущее
    sbb di,cx
    mov ax,si
    mov dx,di
    test ax,ax
    jnz del
    test dx,dx
    jnz del
    jmp snd             ;если ax и dx равны 0, то происходит звук
del:
    div num_18
    cwd
    div num_60          ;в dx - минуты в ax - секунды
    push ax dx
    mov ah,2            ;установка курсора
    mov bh,0
    mov dh,0
    mov dl,25
    int 10h
    pop dx ax
    ;cmp ax,10
    ;jnc min1
    push ax dx
    mov dl,'0'
    mov ah,2
    int 21h
    pop dx ax
min1:
    call ost_min
    push dx
    mov ah,2
    mov dl,'m'
    int 21h
    pop ax
    cmp ax,10
    jnc sec1
    push ax
    mov dl,'0'
    mov ah,2
    int 21h
    pop ax
sec1:
    call ost_min
    mov ah,2
    mov dl,'s'
    int 21h
    jmp kol
snd: 
    ;mov ax,1500
    call Sound1         ;издаем звук
exit:
    mov ah,1
    int 21h
    mov ax,4c00h
    int 21h
Sound1 proc near
    MOV AH,2 ;функция вывода символа на экран
    MOV DL,7 ;посылаем код ASCII 7
    INT 21H ;динамик гудит
Sound1 endp
string_to_int proc
    ;Преобразование строки в число
    ;на выходе ax: число
    push dx
    push si
    xor dx,dx
search:
    xor ax,ax
    lodsb               ;берем символ
    cmp al,13
    jz return
    cmp al,'9'
    jnbe search
    cmp al,'0'
    jb search
    sub ax,'0'
    shl dx,1
    add ax, dx
    shl dx, 2
    add dx, ax
    jmp search
return:
    mov ax,dx           ;помещаем результат в ах
    pop si
    pop dx
    ret
string_to_int endp
ost_min proc
    push cx
    push dx
    push bx
    mov bx,10
    XOR CX,CX
metka1:
    XOR dx,dx
    DIV bx
    PUSH DX
    INC CX
    TEST AX,AX
    JNZ metka1
    mov ah,2
metka2:
    POP dx              ;берем десятичное число из стека
    ADD DL,'0'
    int 21h
    LOOP metka2
    pop bx
    POP dx
    POP cx
    RET
ost_min endp
end start
end
