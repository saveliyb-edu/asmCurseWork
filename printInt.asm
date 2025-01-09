.model small
.stack 100h

.data
QUEUE_SIZE   equ 10
queue        db QUEUE_SIZE dup(0)
head         dw 0
tail         dw 0
buffer db 7 dup('$')   ; Буфер для строки (6 символов + '$')
ten dw 10              ; Константа для деления на 10

msg db 'Element: $'

.code
main:
    ; Инициализация сегментов
    mov ax, @data
    mov ds, ax
    mov es, ax

    ; Добавление элементов в очередь
    mov al, 100
    call enqueue
    mov al, -1234
    call enqueue
    mov al, 332
    call enqueue

    ; Извлечение элементов из очереди
    call dequeue
    ; элемент теперь в ax, далее можно использовать для вывода
    call print_number

    call dequeue
    call print_number

    call dequeue
    call print_number

    ; Завершение программы
    mov ax, 4C00h
    int 21h

; Процедура добавления нового элемента в очередь
enqueue proc
    push ax
    push bx

    mov bx, tail
    mov queue[bx], al
    inc bx
    cmp bx, QUEUE_SIZE
    jne skip_reset_tail
    mov bx, 0

skip_reset_tail:
    mov tail, bx

    pop bx
    pop ax
    ret
enqueue endp

; Процедура выборки очередного элемента из очереди (со сдвигом очереди)
dequeue proc
    push bx

    mov bx, head
    mov al, queue[bx]
    inc bx
    cmp bx, QUEUE_SIZE
    jne skip_reset_head
    mov bx, 0

skip_reset_head:
    mov head, bx

    ; Сохранение элемента в ax для дальнейшего использования
    mov ah, 0

    pop bx
    ret
dequeue endp

print_number proc
    ; Установка указателя на конец буфера
    lea di, buffer + 6       ; Указатель на конец буфера (последний символ '$')

    ; Инициализация флага знака
    mov bl, 0                ; Флаг знака (0 - положительное, 1 - отрицательное)

    ; Проверка числа на знак
    cmp ax, 0
    jge convert_start        ; Если число >= 0, переходим к конвертации

    ; Обработка отрицательного числа
    neg ax                   ; Делаем число положительным
    mov bl, 1                ; Устанавливаем флаг знака

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
    cmp bl, 0
    je skip_minus
    mov byte ptr [di-1], '-' ; Записываем '-' перед числом
    dec dx                   ; Сдвигаем указатель на знак '-'

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

end main
