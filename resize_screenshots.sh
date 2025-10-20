#!/bin/bash

# Скрипт для изменения размера скриншотов под требования App Store
# Использует ImageMagick для изменения размера изображений

set -e

echo "📐 Изменяем размер скриншотов для App Store..."

# Проверяем наличие ImageMagick
if ! command -v magick &> /dev/null; then
    echo "❌ ImageMagick не установлен!"
    echo "Установите ImageMagick: brew install imagemagick"
    exit 1
fi

# Единый целевой размер (iPhone 6.5")
TARGET_SIZE="1284x2778"

# Функция для изменения размера скриншота
resize_screenshot() {
    local file_path="$1"
    local target_size="$2"
    
    echo "   📐 Изменяем размер: $(basename "$file_path") -> $target_size"
    
    # Изменяем размер с обрезкой до нужного размера (без белых полей)
    magick "$file_path" -resize "${target_size}^" -gravity center -crop "$target_size+0+0" "$file_path"
    
    echo "   ✅ Готово"
}

# Обрабатываем все скриншоты в Screenshots/
SCREENSHOTS_DIR="Screenshots"

if [ ! -d "$SCREENSHOTS_DIR" ]; then
    echo "❌ Директория $SCREENSHOTS_DIR не найдена!"
    exit 1
fi

echo "🔍 Ищем скриншоты в $SCREENSHOTS_DIR..."

# Обрабатываем каждую группу
for group_dir in "$SCREENSHOTS_DIR"/*/; do
    if [ -d "$group_dir" ]; then
        group_name=$(basename "$group_dir")
        echo "📁 Обрабатываем группу: $group_name"
        
                # Обрабатываем каждый файл изображения
        find "$group_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | while read -r file_path; do
                    # Всегда обрезаем до единого размера
                    resize_screenshot "$file_path" "$TARGET_SIZE"
        done
    fi
done

echo "✅ Изменение размера скриншотов завершено!"
echo "📁 Обработанные скриншоты в: $SCREENSHOTS_DIR"
