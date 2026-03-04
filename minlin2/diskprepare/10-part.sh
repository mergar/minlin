#!/bin/sh
# Очистка подписей
wipefs -a /dev/vdb

# Создание разметки (используем fdisk)
(
echo g    # создать новую таблицу GPT
echo n    # новый раздел
echo 1    # номер раздела
echo      # первый сектор по умолчанию
echo +512M # размер (хватит с запасом)
echo t    # изменить тип
echo 1    # тип EFI System
echo w    # записать изменения
) | fdisk /dev/vdb

# Форматирование в FAT32 (обязательно для EFI)
mkfs.vfat -F 32 /dev/vdb1
