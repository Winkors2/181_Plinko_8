#!/bin/bash

# Интерактивное меню для iOS CI/CD инструментов
# Позволяет выбирать и запускать различные скрипты

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функции для вывода с цветом
print_header() {
    echo -e "${BLUE}🚀 iOS CI/CD Menu${NC}"
    echo -e "${BLUE}==================${NC}"
    echo ""
}

print_option() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Функция для отображения главного меню
show_main_menu() {
    clear
    print_header
    echo "Выберите действие:"
    echo ""
    print_option "1. 📖 Обновить метаданные приложения"
    print_option "2. 📐 Изменить размер скриншотов"
    print_option "3. 📸 Группировать скриншоты по локалям"
    print_option "4. 📚 Показать документацию"
    print_option "5. ❌ Выход"
    echo ""
    echo -n "Введите номер (1-5): "
}

# Функция для обновления метаданных
update_metadata() {
    echo ""
    echo "📖 Обновление метаданных приложения..."
    echo ""
    
    if [ ! -f "update_metadata.sh" ]; then
        print_error "Скрипт update_metadata.sh не найден!"
        return 1
    fi
    
    if [ ! -f "app_metadata.env" ]; then
        print_error "Файл app_metadata.env не найден!"
        print_warning "Сначала настройте конфигурацию (опция 4)"
        return 1
    fi
    
    ./update_metadata.sh
    print_success "Метаданные обновлены!"
    echo ""
    read -p "Нажмите Enter для возврата в меню..."
}

# Функция для изменения размера скриншотов
resize_screenshots() {
    echo ""
    echo "📐 Изменение размера скриншотов..."
    echo ""
    
    if [ ! -f "resize_screenshots.sh" ]; then
        print_error "Скрипт resize_screenshots.sh не найден!"
        return 1
    fi
    
    if [ ! -d "Screenshots" ]; then
        print_warning "Папка Screenshots не найдена!"
        echo "Создайте папку Screenshots и поместите туда скриншоты"
        echo ""
        read -p "Нажмите Enter для продолжения..."
        return 1
    fi
    
    ./resize_screenshots.sh
    print_success "Размер скриншотов изменен!"
    echo ""
    read -p "Нажмите Enter для возврата в меню..."
}

# Функция для группировки скриншотов
group_screenshots() {
    echo ""
    echo "📸 Группировка скриншотов по локалям..."
    echo ""
    
    if [ ! -f "group_screenshots.sh" ]; then
        print_error "Скрипт group_screenshots.sh не найден!"
        return 1
    fi
    
    if [ ! -f "app_metadata.env" ]; then
        print_error "Файл app_metadata.env не найден!"
        print_warning "Сначала настройте конфигурацию (опция 4)"
        return 1
    fi
    
    ./group_screenshots.sh
    print_success "Скриншоты сгруппированы!"
    echo ""
    read -p "Нажмите Enter для возврата в меню..."
}


# Функция для показа документации
show_documentation() {
    echo ""
    echo "📚 Документация:"
    echo ""
    print_option "1. README.md - Полная документация"
    print_option "2. TEMPLATE_CONFIG.md - Шаблон конфигурации"
    print_option "3. CHECKLIST.md - Чек-лист настройки"
    print_option "4. Назад в главное меню"
    echo ""
    echo -n "Выберите документ (1-4): "
    
    read -r choice
    case $choice in
        1)
            if [ -f "README.md" ]; then
                if command -v less &> /dev/null; then
                    less README.md
                else
                    cat README.md
                fi
            else
                print_error "README.md не найден!"
            fi
            ;;
        2)
            if [ -f "TEMPLATE_CONFIG.md" ]; then
                if command -v less &> /dev/null; then
                    less TEMPLATE_CONFIG.md
                else
                    cat TEMPLATE_CONFIG.md
                fi
            else
                print_error "TEMPLATE_CONFIG.md не найден!"
            fi
            ;;
        3)
            if [ -f "CHECKLIST.md" ]; then
                if command -v less &> /dev/null; then
                    less CHECKLIST.md
                else
                    cat CHECKLIST.md
                fi
            else
                print_error "CHECKLIST.md не найден!"
            fi
            ;;
        4)
            return 0
            ;;
        *)
            print_error "Неверный выбор!"
            ;;
    esac
    
    echo ""
    read -p "Нажмите Enter для возврата в меню..."
}

# Главный цикл меню
main() {
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1)
                update_metadata
                ;;
            2)
                resize_screenshots
                ;;
            3)
                group_screenshots
                ;;
            4)
                show_documentation
                ;;
            5)
                echo ""
                print_success "До свидания! 👋"
                exit 0
                ;;
            *)
                print_error "Неверный выбор! Попробуйте снова."
                echo ""
                read -p "Нажмите Enter для возврата в меню..."
                ;;
        esac
    done
}

# Запуск меню
main "$@"
