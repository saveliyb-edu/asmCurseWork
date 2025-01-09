.model small
.stack 100h
.data
    buffer db 7 dup('$')   ; Буфер для строки (6 символов + '$')
    ten dw 10              ; Константа для деления на 10
.code
main proc
    mov ax, @data
    mov ds, ax

    ; Загрузка и вывод чисел
    ; Число 1
    mov ax, 1
    call print_number

    ; Число 12
    mov ax, 12
    call print_number

    ; Число 1234
    mov ax, 1234
    call print_number

    ; Число -4321
    mov ax, -4321
    call print_number

    ; Число 0
    mov ax, 0
    call print_number

    ; Завершение программы
    mov ax, 4C00h
    int 21h
main endp

print_number proc
    ; Установка указателя на конец буфера
    lea di, buffer + 6       ; Указатель на конец буфера (последний символ '$')

    ; Проверка числа на знак
    cmp ax, 0
    jge convert_start        ; Если число >= 0, переходим к конвертации

    ; Обработка отрицательного числа
    neg ax                   ; Делаем число положительным
    mov byte ptr [buffer], '-' ; Записываем '-' в начало буфера
    lea di, buffer + 6       ; Снова устанавливаем указатель на конец
    dec di                   ; Смещаем указатель назад для записи цифр

convert_start:
    mov cx, 0                ; Счетчик символов

convert_loop:
    xor dx, dx               ; Очищаем DX перед делением
    div ten                  ; AX / 10, результат в AX, остаток в DX
    add dl, '0'              ; Преобразуем остаток в ASCII-символ
    dec di                   ; Переходим к следующей позиции
    mov [di], dl             ; Сохраняем символ в буфер
    inc cx                   ; Увеличиваем счетчик символов
    cmp ax, 0                ; Проверяем, все ли цифры обработаны
    jne convert_loop         ; Если нет, продолжаем

    ; Настраиваем указатель для вывода строки
    lea dx, buffer + 6       ; Указываем на конец буфера
    sub dx, cx               ; Смещаем указатель к началу цифр

    ; Если число отрицательное, включаем знак '-'
    cmp word ptr [buffer], '-'
    jge skip_minus
    lea dx, buffer           ; Указываем на начало буфера, чтобы включить '-'

skip_minus:
    ; Вывод строки на экран
    mov ah, 09h
    int 21h

    ; Перевод строки для следующего числа
    mov ah, 02h
    mov dl, 0Dh              ; Символ возврата каретки
    int 21h
    mov dl, 0Ah              ; Символ новой строки
    int 21h

    ret
print_number endp
end main
