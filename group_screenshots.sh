#!/bin/bash

# Скрипт для группировки скриншотов по локалям
# Копирует скриншоты из Screenshots/groupX/ в fastlane/screenshots/{locale}/

set -e

echo "📸 Группируем скриншоты по локалям..."

# Загружаем переменные из app_metadata.env
if [ -f "app_metadata.env" ]; then
    source app_metadata.env
else
    echo "⚠️  Файл app_metadata.env не найден, используем настройки по умолчанию"
fi

# Функция для копирования скриншотов группы
copy_group_screenshots() {
    local group_num="$1"
    local locales="$2"
    local use_group="$3"
    
    if [ "$use_group" != "true" ]; then
        echo "⏭️  Пропускаем группу $group_num (отключена)"
        return
    fi
    
    local source_dir="Screenshots/$group_num"
    if [ ! -d "$source_dir" ]; then
        echo "⚠️  Директория $source_dir не найдена, пропускаем группу $group_num"
        return
    fi
    
    echo "📁 Обрабатываем группу $group_num: $source_dir"
    echo "🌍 Локали: $locales"
    
    # Разделяем локали по запятым
    IFS=',' read -ra LOCALE_ARRAY <<< "$locales"
    
    for locale in "${LOCALE_ARRAY[@]}"; do
        # Убираем пробелы
        locale=$(echo "$locale" | xargs)
        
        local target_dir="fastlane/screenshots/$locale"
        echo "   📂 Копируем в: $target_dir"
        
        # Создаем целевую директорию
        mkdir -p "$target_dir"
        
        # Копируем все файлы
        if [ "$(ls -A "$source_dir" 2>/dev/null)" ]; then
            cp -r "$source_dir"/* "$target_dir/"
            echo "   ✅ Скопировано в $target_dir"
        else
            echo "   ⚠️  Директория $source_dir пуста"
        fi
    done
}

# Проверяем наличие директории fastlane/screenshots
mkdir -p "fastlane/screenshots"

# Обрабатываем каждую группу
copy_group_screenshots "1" "$LOCALE_GROUP_1" "${USE_GROUP_1_SCREENSHOTS:-false}"
copy_group_screenshots "2" "$LOCALE_GROUP_2" "${USE_GROUP_2_SCREENSHOTS:-false}"
copy_group_screenshots "3" "$LOCALE_GROUP_3" "${USE_GROUP_3_SCREENSHOTS:-false}"
copy_group_screenshots "4" "$LOCALE_GROUP_4" "${USE_GROUP_4_SCREENSHOTS:-false}"
copy_group_screenshots "5" "$LOCALE_GROUP_5" "${USE_GROUP_5_SCREENSHOTS:-false}"

echo "✅ Группировка скриншотов завершена!"
echo "📁 Скриншоты размещены в: fastlane/screenshots/"

# Показываем статистику
echo ""
echo "📊 Статистика:"
for locale_dir in fastlane/screenshots/*/; do
    if [ -d "$locale_dir" ]; then
        locale=$(basename "$locale_dir")
        count=$(find "$locale_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | wc -l)
        echo "   $locale: $count файлов"
    fi
done
