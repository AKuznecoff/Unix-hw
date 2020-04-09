#!/bin/bash

# Сообщения для пользователя 
COORDINATE_MSG="Выберете ячейку"
INVALID_CEIL="\nНеправильная ячейка"
RIVAL_TURN="Ход противника"
DRAW="Ничья"
WIN="Вы победили"
LOOSE="Вы проиграли"
# Поле для игры
field=(" " " " " " " " " " " " " " " " " ")
# Чей ход
turn=0

print_field() {
    echo -e "\033[4m${field[0]}|${field[1]}|${field[2]}\033[0m"
    echo -e "\033[4m${field[3]}|${field[4]}|${field[5]}\033[0m"
    echo "${field[6]}|${field[7]}|${field[8]}"
}

check() {
    # Проверяем, что кто-то выиграл
    # Проверим горизонтальные линии
    if [[ (${field[0]} == ${field[1]}) && (${field[1]} == ${field[2]}) && (${field[0]} != " ") ]]; then
        WINNER=${field[0]}
        return 0
    fi
    if [[ (${field[3]} == ${field[4]}) && (${field[4]} == ${field[8]}) && (${field[3]} != " ") ]]; then
        WINNER=${field[3]}
        return 0
    fi
    if [[ (${field[6]} == ${field[7]}) && (${field[7]} == ${field[9]}) && (${field[6]} != " ") ]]; then
        WINNER=${field[6]}
        return 0
    fi
    # Проверим вертикальные линии
    if [[ (${field[0]} == ${field[3]}) && (${field[3]} == ${field[6]}) && (${field[0]} != " ") ]]; then
        WINNER=${field[0]}
        return 0
    fi
    if [[ (${field[1]} == ${field[4]}) && (${field[4]} == ${field[7]}) && (${field[1]} != " ") ]]; then
        WINNER=${field[1]}
        return 0
    fi
    if [[ (${field[2]} == ${field[5]}) && (${field[5]} == ${field[8]}) && (${field[2]} != " ") ]]; then
        WINNER=${field[2]}
        return 0
    fi
    # Проверим диагонали
    if [[ (${field[0]} == ${field[4]}) && (${field[4]} == ${field[8]}) && (${field[0]} != " ") ]]; then
        WINNER=${field[0]}
        return 0
    fi
    if [[ (${field[2]} == ${field[4]}) && (${field[4]} == ${field[6]}) && (${field[2]} != " ") ]]; then
        WINNER=${field[0]}
        return 0
    fi
    
    return 1
    
}

check_draw() {
    # Проверяем на ничью
    for ceil in "${field[@]}"; do
        if [[ $ceil == " " ]]; then
            return 1
        fi
    done
    return 0
}

put_symbol() {
    # Вставляем символ в ячейку
    # Проверяем, что ячейка свободна
    if [[ "${field[$coordinate]}" == " " ]]; then
        field[$coordinate]=$1
        return 1
    else
        return 0
    fi
}

# Создаем соединение
if [[ $2 ]]; then
    coproc nc -w 5 $1 $2
    MY_TURN=$((RANDOM%2))
    echo $(((MY_TURN+1)%2)) >& ${COPROC[1]}
    MY_SYMBOL="x"
    RIVAL_SYMBOL="o"
else
    coproc nc -l -p $1
    read -u ${COPROC[0]} MY_TURN
    MY_SYMBOL="o"
    RIVAL_SYMBOL="x"
fi

# Соединились, начинаем игру
tput clear
print_field
while true; do
    if [[ $MY_TURN == $turn ]]; then
        read -n 1 -p "$COORDINATE_MSG: " coordinate
        # put_symbol $MY_SYMBOL
        while put_symbol $MY_SYMBOL; do
            echo -e $INVALID_CEIL
            read -n 1 -p "$COORDINATE_MSG: " coordinate
        done
        echo $coordinate >& ${COPROC[1]}
    else
        echo $RIVAL_TURN
        read -u ${COPROC[0]} coordinate
        put_symbol $RIVAL_SYMBOL
    fi
    turn=$(((turn+1)%2))
    tput clear
    print_field
    if check; then
        if [[ $WINNER == $MY_SYMBOL ]]; then
            echo $WIN
        else
            echo $LOOSE
        fi
        break
    elif check_draw; then
        echo $DRAW
        break
    fi
done

exit