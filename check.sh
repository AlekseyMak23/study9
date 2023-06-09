#!/bin/bash

# Считывание значения из файла
number=$(cat ./lines 2>/dev/null);status=$?

# Считывание количесва строк в файле лога
checkLines=$(wc ./access.log | awk '{print $1}')

# Если возвращается пустое значение, считаем количество строк и записываем значение в файл
if ! [ -n "$number" ]
then
    # Дата начала и конца
    TimeBegin=$(awk '{print $4}' access.log | sed -n 1p | sed -e "s/^.//")
    TimeEnd=$(awk '{print $4}' access.log | sed -n "$checkLines"p | sed -e "s/^.//")
    # Запись количества строк в файл
    echo $checkLines > ./lines
    # Список IP адресов
    IP=$(awk '{print $1}' access.log | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 5 ) { print "Количество запросов: " $1, "IP:" $2 } }')
    # Список запрашиваемых Url
    addresses=$(awk '{print $7}' access.log | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 5 ) { print "Количество запросов: " $1, "URL:" $2 } }')
    # Список кодов Http
    codes=$(awk '{print $9}' access.log | sort | grep -v "-" | uniq -c | sort -rn | awk '{ if ( $1 >= 0) { print "Список всех кодов Http ответа: " $1, "Code:" $2} }')
    # Ошибки веб сервера
    errors=$(awk '{print $9}' access.log | sort | grep -v "-" | grep ^4 | uniq -c | sort -rn | awk '{ if ( $1 >= 0) { print "Список кодов ошибок: " $1, "Code:" $2} }')
    # Отправка почты
    echo -e "Данные за период: $TimeBegin-$TimeEnd\n\n"Список IP адресов:"\n$IP\n\n"Список запрашиваемых URL:"\n$addresses\n\n"Список кодов URL:"\n$codes\n\n"Ошибки веб сервера:"\n$errors" | mail -s "CheckLog Data" root@localhost 
else
    # Дата начала и конца
    TimeBegin=$(awk '{print $4}' access.log | sed -n "$(($number+1))"p | sed -e "s/^.//")
    TimeEnd=$(awk '{print $4}' access.log | sed -n "$(($checkLines+1))"p | sed -e "s/^.//")
    # Список IP адресов
    IP=$(awk "NR>$(($number+1))"  access.log | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 5 ) { print "Количество запросов: " $1, "IP:" $2 } }')
    # Список запрашиваемых Url
    addresses=$(awk "NR>$(($number+1))" access.log | awk '{print $7}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 5 ) { print "Количество запросов: " $1, "URL:" $2 } }')
    # Список кодов Http
    errors=$(awk "NR>$(($number+1))" access.log | awk '{print $9}' | sort | grep -v "-" | uniq -c | sort -rn | awk '{ if ( $1 >= 0) { print "Список всех кодов Http ответа: " $1, "Code:" $2} }')
    # Ошибки веб сервера
    errors=$(awk "NR>$(($number+1))" access.log | awk '{print $9}' | sort | grep -v "-" | grep ^4 |uniq -c | sort -rn | awk '{ if ( $1 >= 0) { print "Список кодов ошибок: " $1, "Code:" $2} }')
    # Запись количества строк в файле
    echo $checkLines > ./lines
    # Отправка почты
    echo -e "Данные за период: $TimeBegin-$TimeEnd\n\n"Список IP адресов:"\n$IP\n\n"Список запрашиваемых URL:"\n$addresses\n\n"Список кодов URL:"\n$codes\n\n"Ошибки веб сервера:"\n$errors" | mail -s "CheckLog Data" root@localhost
fi
