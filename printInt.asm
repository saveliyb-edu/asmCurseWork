.model small
.stack 100h
.data
    buffer db 7 dup('$')   ; Буфер для строки (6 символов + '$')
    ten dw 10              ; Константа для деления на 10
.code
main proc
    mov ax, @data
    mov ds, ax

    ; Примеры чисел для вывода
    ; Число 1
    mov ax, 1
    call print_number

    ; Число 12
    mov ax, 12
    call print_number

    ; Число 1234
    mov ax, 1234
    call print_number

    ; Число -1234
    mov ax, -1234
    call print_number

    ; Число 0
    mov ax, 0
    call print_number
    
    mov ax, 50
    call print_number

    ; Завершение программы
    mov ax, 4C00h
    int 21h
main endp

print_number proc
    ; Инициализация указателя на конец буфера
    lea di, buffer + 6       ; Указатель на конец буфера (исключая символ '$')

    ; Проверка числа на 0
    cmp ax, 0
    jge convert_start        ; Если число >= 0, переход к преобразованию

    ; Обработка отрицательного числа
    neg ax                   ; Преобразование числа в положительное
    mov byte ptr [buffer], '-' ; Запись '-' в начало буфера
    lea di, buffer + 6       ; Сброс указателя на конец буфера
    dec di                   ; Сдвиг указателя на одну позицию влево

convert_start:
    mov cx, 0                ; Сброс счетчика символов

convert_loop:
    xor dx, dx               ; Очистка DX перед делением
    div ten                  ; AX / 10, результат в AX, остаток в DX
    add dl, '0'              ; Преобразование остатка в ASCII-символ
    dec di                   ; Сдвиг указателя на одну позицию влево
    mov [di], dl             ; Запись символа в буфер
    inc cx                   ; Увеличение счетчика символов
    cmp ax, 0                ; Проверка, все ли цифры обработаны
    jne convert_loop         ; Если нет, продолжение цикла

    ; Обработка вывода строки
    lea dx, buffer + 6       ; Указатель на конец буфера
    sub dx, cx               ; Сдвиг указателя на начало числа
    
    ; Проверка на наличие знака '-'
    cmp byte ptr [buffer], '-'
    jne skip_minus
    lea dx, buffer           ; Указатель на начало строки, если есть '-'

skip_minus:
    ; Вывод строки на экран
    mov ah, 09h
    int 21h

    ; Печать символов новой строки и возврата каретки
    mov ah, 02h
    mov dl, 0Dh              ; Символ возврата каретки
    int 21h
    mov dl, 0Ah              ; Символ новой строки
    int 21h

    ret
print_number endp
end main
