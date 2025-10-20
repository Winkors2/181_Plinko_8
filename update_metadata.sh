#!/bin/bash

# Скрипт для обновления метаданных приложения
# Создает файлы метаданных из app_metadata.env для всех локалей

set -e

echo "📖 Обновляем метаданные приложения..."

# Проверяем наличие app_metadata.env
if [ ! -f "app_metadata.env" ]; then
    echo "❌ Файл app_metadata.env не найден!"
    exit 1
fi

# Загружаем переменные из app_metadata.env
source app_metadata.env

# Функция для создания файла метаданных
create_metadata_file() {
    local locale="$1"
    local filename="$2"
    local text="$3"
    
    # Создаем директорию если не существует
    mkdir -p "fastlane/metadata/$locale"
    
    case "$filename" in
        "name.txt"|"subtitle.txt")
            # Ограничение: 30 символов
            if [ ${#text} -gt 30 ]; then
                text="${text:0:30}"
                echo "⚠️  Обрезано до 30 символов: $filename"
            fi
            ;;
        "description.txt")
            # Ограничение: 4000 символов
            if [ ${#text} -gt 4000 ]; then
                text="${text:0:4000}"
                echo "⚠️  Обрезано до 4000 символов: $filename"
            fi
            ;;
        "keywords.txt")
            # Ограничение: 100 символов
            if [ ${#text} -gt 100 ]; then
                text="${text:0:100}"
                echo "⚠️  Обрезано до 100 символов: $filename"
            fi
            ;;
    esac
    
    # Записываем в файл
    echo "$text" > "fastlane/metadata/$locale/$filename"
    echo "✅ Создан: fastlane/metadata/$locale/$filename"
}

# Собираем только активные локали из app_metadata.env
LOCALES=()

# Добавляем локали из активных групп
if [ "$USE_GROUP_1_SCREENSHOTS" = "true" ] && [ -n "$LOCALE_GROUP_1" ]; then
    IFS=',' read -ra GROUP1_LOCALES <<< "$LOCALE_GROUP_1"
    for locale in "${GROUP1_LOCALES[@]}"; do
        locale=$(echo "$locale" | xargs) # убираем пробелы
        LOCALES+=("$locale")
    done
fi

if [ "$USE_GROUP_2_SCREENSHOTS" = "true" ] && [ -n "$LOCALE_GROUP_2" ]; then
    IFS=',' read -ra GROUP2_LOCALES <<< "$LOCALE_GROUP_2"
    for locale in "${GROUP2_LOCALES[@]}"; do
        locale=$(echo "$locale" | xargs) # убираем пробелы
        LOCALES+=("$locale")
    done
fi

if [ "$USE_GROUP_3_SCREENSHOTS" = "true" ] && [ -n "$LOCALE_GROUP_3" ]; then
    IFS=',' read -ra GROUP3_LOCALES <<< "$LOCALE_GROUP_3"
    for locale in "${GROUP3_LOCALES[@]}"; do
        locale=$(echo "$locale" | xargs) # убираем пробелы
        LOCALES+=("$locale")
    done
fi

if [ "$USE_GROUP_4_SCREENSHOTS" = "true" ] && [ -n "$LOCALE_GROUP_4" ]; then
    IFS=',' read -ra GROUP4_LOCALES <<< "$LOCALE_GROUP_4"
    for locale in "${GROUP4_LOCALES[@]}"; do
        locale=$(echo "$locale" | xargs) # убираем пробелы
        LOCALES+=("$locale")
    done
fi

if [ "$USE_GROUP_5_SCREENSHOTS" = "true" ] && [ -n "$LOCALE_GROUP_5" ]; then
    IFS=',' read -ra GROUP5_LOCALES <<< "$LOCALE_GROUP_5"
    for locale in "${GROUP5_LOCALES[@]}"; do
        locale=$(echo "$locale" | xargs) # убираем пробелы
        LOCALES+=("$locale")
    done
fi

# Убираем дубликаты
LOCALES=($(printf "%s\n" "${LOCALES[@]}" | sort -u))

echo "🌍 Обрабатываем ${#LOCALES[@]} активных локалей..."

if [ ${#LOCALES[@]} -eq 0 ]; then
    echo "⚠️  Не найдено активных локалей!"
    echo "Проверьте настройки USE_GROUP_X_SCREENSHOTS в app_metadata.env"
    exit 1
fi

for locale in "${LOCALES[@]}"; do
    echo "   📝 Обрабатываем локаль: $locale"
    
    # Создаем файлы метаданных
    create_metadata_file "$locale" "name.txt" "$APP_NAME"
    create_metadata_file "$locale" "subtitle.txt" "$APP_SUBTITLE"
    create_metadata_file "$locale" "description.txt" "$APP_DESCRIPTION"
    create_metadata_file "$locale" "release_notes.txt" "$APP_RELEASE_NOTES"
    create_metadata_file "$locale" "keywords.txt" "$APP_KEYWORDS"
    create_metadata_file "$locale" "privacy_url.txt" "$APP_PRIVACY_URL"
    create_metadata_file "$locale" "support_url.txt" "$APP_PRIVACY_URL"
    create_metadata_file "$locale" "marketing_url.txt" "$APP_PRIVACY_URL"
done

echo "✅ Метаданные обновлены для всех локалей!"
echo "📁 Файлы созданы в: fastlane/metadata/"
