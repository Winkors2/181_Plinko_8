#!/bin/bash

# 🚀 Скрипт автоматической настройки iOS CI/CD

echo "🚀 Настройка iOS CI/CD шаблона..."
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода с цветом
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Создание необходимых файлов и папок
create_structure() {
    echo "🔍 Проверка и создание структуры файлов..."
    
    # Создаем папки
    mkdir -p .github/actions/setup-env
    mkdir -p .github/workflows
    mkdir -p fastlane/metadata
    
    # Создаем action.yml если его нет
    if [ ! -f ".github/actions/setup-env/action.yml" ]; then
        cat > .github/actions/setup-env/action.yml << 'EOF'
name: 'Setup Environment Variables'
description: 'Устанавливает общие переменные окружения для всех workflow'

# Использование: 
# - name: Setup environment variables
#   uses: ./.github/actions/setup-env

runs:
  using: 'composite'
  steps:
    - name: Set environment variables
      shell: bash
      run: |
        # Apple Developer настройки
        echo "DEVELOPER_APP_ID=АППАЙДИ" >> $GITHUB_ENV
        echo "DEVELOPER_APP_IDENTIFIER=БАНДЛАЙДИ" >> $GITHUB_ENV
        echo "TEAM_ID=ТИМАЙДИ" >> $GITHUB_ENV
        echo "XCODE_VERSION=16.2" >> $GITHUB_ENV
        echo "XCODEPROJ_PROJECTNAME_W_EXTENSION=НАЗВАНИЕ_ПРОЕКТА.xcodeproj" >> $GITHUB_ENV
        echo "XCODEPROJ_WORKSPACE_W_EXTENSION=НАЗВАНИЕ_ПРОЕКТА.xcworkspace" >> $GITHUB_ENV
        echo "XCODEPROJ_SCHEMENAME=НАЗВАНИЕ_ПРОЕКТА" >> $GITHUB_ENV
        echo "APPLE_KEY_ID=APPLE_KEY_ID" >> $GITHUB_ENV
        echo "APPLE_ISSUER_ID=APPLE_ISSUER_ID" >> $GITHUB_ENV
        # APPLE_KEY_CONTENT не задается здесь; указывайте прямо в workflows
        echo "PROVISIONING_PROFILE_SPECIFIER=match AppStore БАНДЛАЙДИ" >> $GITHUB_ENV
        echo "MATCH_PASSWORD=tempMatchPassword" >> $GITHUB_ENV
        echo "TEMP_KEYCHAIN_USER=tempKeychainUser" >> $GITHUB_ENV
        echo "TEMP_KEYCHAIN_PASSWORD=tempKeychainPassword" >> $GITHUB_ENV
        echo "GIT_AUTHORIZATION=GITHUB_TOKEN" >> $GITHUB_ENV
        
        # Match настройки
        echo "MATCH_GIT_URL=РЕПОЗИТОРИЙ.ГИТ" >> $GITHUB_ENV
        echo "MATCH_STORAGE_MODE=git" >> $GITHUB_ENV
        echo "MATCH_TYPE=appstore" >> $GITHUB_ENV
EOF
        print_status "Создан .github/actions/setup-env/action.yml"
    fi
    
    # Создаем Matchfile если его нет
    if [ ! -f "fastlane/Matchfile" ]; then
        cat > fastlane/Matchfile << 'EOF'
git_url("РЕПОЗИТОРИЙ.ГИТ")

storage_mode("git")

type("appstore")

app_identifier("БАНДЛАЙДИ")
EOF
        print_status "Создан fastlane/Matchfile"
    fi
    
    # Создаем Fastfile если его нет
    if [ ! -f "fastlane/Fastfile" ]; then
        cat > fastlane/Fastfile << 'EOF'
default_platform(:ios)
default_platform(:ios)

DEVELOPER_APP_ID = ENV["DEVELOPER_APP_ID"]
DEVELOPER_APP_IDENTIFIER = ENV["DEVELOPER_APP_IDENTIFIER"]
PROVISIONING_PROFILE_SPECIFIER = ENV["PROVISIONING_PROFILE_SPECIFIER"]
TEMP_KEYCHAIN_USER = ENV["TEMP_KEYCHAIN_USER"]
TEMP_KEYCHAIN_PASSWORD = ENV["TEMP_KEYCHAIN_PASSWORD"]
APPLE_ISSUER_ID = ENV["APPLE_ISSUER_ID"]
APPLE_KEY_ID = ENV["APPLE_KEY_ID"]
APPLE_KEY_CONTENT = ENV["APPLE_KEY_CONTENT"]
GIT_AUTHORIZATION = ENV["GIT_AUTHORIZATION"]
XCODEPROJ_PROJECTNAME_W_EXTENSION = ENV["XCODEPROJ_PROJECTNAME_W_EXTENSION"]
XCODEPROJ_WORKSPACE_W_EXTENSION = ENV["XCODEPROJ_WORKSPACE_W_EXTENSION"]
XCODEPROJ_SCHEMENAME = ENV["XCODEPROJ_SCHEMENAME"]
LOCALIZATION_KEY = ENV["LOCALIZATION_KEY"]
DESCRIPITON_BEZ_KAVICHEK = ENV["DESCRIPITON_BEZ_KAVICHEK"]
KEYWORDS_CHEREZ_ZAPYATUU = ENV["KEYWORDS_CHEREZ_ZAPYATUU"]
SUPPORT_URL = ENV["SUPPORT_URL"]
PRIVACY_URL = ENV["PRIVACY_URL"]
PRIMARY_CATEGORY = ENV["PRIMARY_CATEGORY"]
REVIEW_FIRST_NAME = ENV["REVIEW_FIRST_NAME"]
REVIEW_LAST_NAME = ENV["REVIEW_LAST_NAME"]
REVIEW_PHONE_NUMBER = ENV["REVIEW_PHONE_NUMBER"]
REVIEW_EMAIL = ENV["REVIEW_EMAIL"]
TEAM_ID = ENV["TEAM_ID"]

def delete_temp_keychain(name)
  delete_keychain(
    name: name
  ) if File.exist? File.expand_path("~/Library/Keychains/#{name}-db")
end

def create_temp_keychain(name, password)
  create_keychain(
    name: name,
    password: password,
    unlock: false,
    timeout: 0
  )
end

def ensure_temp_keychain(name, password)
  delete_temp_keychain(name)
  create_temp_keychain(name, password)
end

platform :ios do
  # Лейн для сборки и загрузки билда в TestFlight
  lane :build_and_upload do
    keychain_name = TEMP_KEYCHAIN_USER
    keychain_password = TEMP_KEYCHAIN_PASSWORD
    ensure_temp_keychain(keychain_name, keychain_password)

    api_key = app_store_connect_api_key(
      key_id: APPLE_KEY_ID,
      issuer_id: APPLE_ISSUER_ID,
      key_content: APPLE_KEY_CONTENT,            
      is_key_content_base64: false,            
      in_house: false
    )

    current_version = get_version_number(xcodeproj: XCODEPROJ_PROJECTNAME_W_EXTENSION)

    latest_build_number = latest_testflight_build_number(
      api_key: api_key,
      version: current_version,
      app_identifier: DEVELOPER_APP_IDENTIFIER
    )

    increment_build_number(
      build_number: (latest_build_number + 1),
    )
    
    match(
      type: 'appstore',
      app_identifier: "#{DEVELOPER_APP_IDENTIFIER}",
      git_basic_authorization: Base64.strict_encode64(GIT_AUTHORIZATION),
      readonly: false,
      keychain_name: keychain_name,
      keychain_password: keychain_password,
      api_key: api_key
    )

    update_code_signing_settings(
        use_automatic_signing: false,
        team_id: TEAM_ID,
        profile_name: PROVISIONING_PROFILE_SPECIFIER,
        code_sign_identity: "Apple Distribution",
        path: XCODEPROJ_PROJECTNAME_W_EXTENSION
    )

    gym(
      workspace: XCODEPROJ_WORKSPACE_W_EXTENSION,
      scheme: XCODEPROJ_SCHEMENAME,
      configuration: "Release",
      destination: "generic/platform=iOS",
      export_options: {
        method: "app-store",
        signingStyle: "manual",
        provisioningProfiles: { DEVELOPER_APP_IDENTIFIER => PROVISIONING_PROFILE_SPECIFIER }
      },
      output_name: "#{XCODEPROJ_SCHEMENAME}"
    )

    pilot(
      apple_id: "#{DEVELOPER_APP_ID}",
      app_identifier: "#{DEVELOPER_APP_IDENTIFIER}",
      skip_waiting_for_build_processing: true,
      skip_submission: true,
      distribute_external: false,
      notify_external_testers: false,
      ipa: "./#{XCODEPROJ_SCHEMENAME}.ipa"
    )

    delete_temp_keychain(keychain_name)
  end

  # Лейн для загрузки метаданных без precheck
  lane :upload_metadata do
    api_key = app_store_connect_api_key(
      key_id: APPLE_KEY_ID,
      issuer_id: APPLE_ISSUER_ID,
      key_content: APPLE_KEY_CONTENT,            
      is_key_content_base64: false,            
      in_house: false
    )

    # Получаем текущую версию из проекта
    current_version = get_version_number(xcodeproj: XCODEPROJ_PROJECTNAME_W_EXTENSION)
    UI.message("Используем версию: #{current_version}")

    UI.message("Загружаем метаданные в App Store Connect...")

    deliver(
      api_key: api_key,
      app_identifier: DEVELOPER_APP_IDENTIFIER,
      app_version: current_version,
      metadata_path: "./fastlane/metadata",
      app_rating_config_path: "./fastlane/rating_config.json",
      skip_binary_upload: true,
      skip_screenshots: true,
      submit_for_review: false,
      force: true,
      run_precheck_before_submit: false,
      app_review_information: nil
    )

    UI.message("Метаданные успешно загружены!")
  end

  # Лейн для загрузки скриншотов
  lane :upload_screenshots do
    api_key = app_store_connect_api_key(
      key_id: APPLE_KEY_ID,
      issuer_id: APPLE_ISSUER_ID,
      key_content: APPLE_KEY_CONTENT,
      is_key_content_base64: false
    )

    ENV["FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS"] = "1"

    deliver(
      app_identifier: DEVELOPER_APP_IDENTIFIER,
      screenshots_path: "./fastlane/screenshots",
      skip_binary_upload: true,
      skip_metadata: true,
      skip_app_version_update: true,
      overwrite_screenshots: true,
      force: true,
      run_precheck_before_submit: false
    )
  end

  # Оригинальный лейн (оставляем для совместимости)
  lane :closed_beta do
    keychain_name = TEMP_KEYCHAIN_USER
    keychain_password = TEMP_KEYCHAIN_PASSWORD
    ensure_temp_keychain(keychain_name, keychain_password)

    api_key = app_store_connect_api_key(
      key_id: APPLE_KEY_ID,
      issuer_id: APPLE_ISSUER_ID,
      key_content: APPLE_KEY_CONTENT,            
      is_key_content_base64: false,            
      in_house: false
    )

    current_version = get_version_number(xcodeproj: XCODEPROJ_PROJECTNAME_W_EXTENSION)

    latest_build_number = latest_testflight_build_number(
      api_key: api_key,
      version: current_version,
      app_identifier: DEVELOPER_APP_IDENTIFIER
    )

    increment_build_number(
      build_number: (latest_build_number + 1),
    )
    
    match(
      type: 'appstore',
      app_identifier: "#{DEVELOPER_APP_IDENTIFIER}",
      git_basic_authorization: Base64.strict_encode64(GIT_AUTHORIZATION),
      readonly: false,
      keychain_name: keychain_name,
      keychain_password: keychain_password,
      api_key: api_key
    )

    update_code_signing_settings(
        use_automatic_signing: false,
        team_id: TEAM_ID,
        profile_name: PROVISIONING_PROFILE_SPECIFIER,
        code_sign_identity: "Apple Distribution",
        path: XCODEPROJ_PROJECTNAME_W_EXTENSION
    )

    gym(
        scheme: XCODEPROJ_SCHEMENAME,
        output_name: "#{XCODEPROJ_SCHEMENAME}",
        configuration: "Release",
        export_options: {
            method: "app-store",
            provisioningProfiles: {
                DEVELOPER_APP_IDENTIFIER => PROVISIONING_PROFILE_SPECIFIER
            }
        },
          xcargs: "CODE_SIGN_STYLE='Manual' DEVELOPMENT_TEAM='#{TEAM_ID}' PROVISIONING_PROFILE_SPECIFIER='#{PROVISIONING_PROFILE_SPECIFIER}' CODE_SIGN_IDENTITY='Apple Distribution'"
    )

    pilot(
      apple_id: "#{DEVELOPER_APP_ID}",
      app_identifier: "#{DEVELOPER_APP_IDENTIFIER}",
      skip_waiting_for_build_processing: true,
      skip_submission: true,
      distribute_external: false,
      notify_external_testers: false,
      ipa: "./#{XCODEPROJ_SCHEMENAME}.ipa"
    )


    delete_temp_keychain(keychain_name)
  end
end

EOF
        print_status "Создан fastlane/Fastfile"
    fi
    
    # Создаем workflow файлы если их нет
    create_workflows
    
    # Создаем метаданные если их нет
    create_metadata
    
    # Создаем скрипт для изменения размера скриншотов
    create_resize_script
    
    # Создаем скрипт для группировки скриншотов по локалям
    create_group_script
    
    # Создаем конфигурацию для группировки скриншотов
    create_group_config
    
    # Создаем скрипт для обновления метаданных
    create_metadata_update_script
    
    # Создаем интерактивное меню
    create_menu_script
    
    print_status "Структура файлов создана"
}

# Создание workflow файлов
create_workflows() {
    # Build and Upload workflow
    if [ ! -f ".github/workflows/1) build and upload.yml" ]; then
        cat > ".github/workflows/1) build and upload.yml" << 'EOF'
name: 1) Build and Upload to TestFlight

# Запуск: вручную через GitHub Actions или по расписанию
on:
  workflow_dispatch:  # Ручной запуск
  # schedule:  # Автоматический запуск по расписанию
  #   - cron: '0 9 * * 1'  # Каждый понедельник в 9:00 UTC

jobs:
  build_and_upload:
    name: Build and Upload to TestFlight
    runs-on: macos-15

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup environment variables
        uses: ./.github/actions/setup-env

      - name: Install CocoaPods (if needed) and install Pods
        run: |
          if [ -f Gemfile ]; then
            echo "Using Bundler to install gems..."
            gem install bundler -N || true
            bundle install --path vendor/bundle
            bundle exec pod --version
            bundle exec pod repo update
            bundle exec pod install --clean-install
          else
            echo "Installing CocoaPods gem..."
            sudo gem install cocoapods -N || true
            pod --version
            pod repo update
            pod install --clean-install
          fi

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: ${{ env.XCODE_VERSION }}
          
      - name: Xcode first launch (license & platforms)
        run: |
          sudo xcodebuild -license accept
          sudo xcodebuild -runFirstLaunch
          sudo xcodebuild -downloadPlatform iOS || true
          xcode-select -p
          xcodebuild -showsdks

      - name: Show Xcode & SDKs
        run: |
          xcodebuild -version
          xcodebuild -showsdks

      - name: Build and Upload to TestFlight
        uses: maierj/fastlane-action@v1.4.0
        with:
          lane: build_and_upload
        env:
          DEVELOPER_APP_ID: ${{ env.DEVELOPER_APP_ID }}
          DEVELOPER_APP_IDENTIFIER: ${{ env.DEVELOPER_APP_IDENTIFIER }}
          PROVISIONING_PROFILE_SPECIFIER: ${{ env.PROVISIONING_PROFILE_SPECIFIER }}
          TEAM_ID: ${{ env.TEAM_ID }}
          GIT_AUTHORIZATION: ${{ env.GIT_AUTHORIZATION }}
          XCODEPROJ_PROJECTNAME_W_EXTENSION: ${{ env.XCODEPROJ_PROJECTNAME_W_EXTENSION }}
          XCODEPROJ_WORKSPACE_W_EXTENSION: ${{ env.XCODEPROJ_WORKSPACE_W_EXTENSION }}
          XCODEPROJ_SCHEMENAME: ${{ env.XCODEPROJ_SCHEMENAME }}
          TEMP_KEYCHAIN_USER: ${{ env.TEMP_KEYCHAIN_USER }}
          APPLE_KEY_ID: ${{ env.APPLE_KEY_ID }}
          APPLE_ISSUER_ID: ${{ env.APPLE_ISSUER_ID }}
          APPLE_KEY_CONTENT: |
            -----BEGIN PRIVATE KEY-----
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgRfNaaUcNJR19bTqk
            C8ePDmcdE2AtGF6y4W0mbEYFb9mgCgYIKoZIzj0DAQehRANCAAQQ/tw+zOdG0P/g
            LhV5CAwvdp35jo9Wpu9ZrtgSXuFZu9i3w90FHYkTW7ICvjWi4kcGVEra1Byo5gcv
            FI0ze32b
            -----END PRIVATE KEY-----
          MATCH_PASSWORD: ${{ env.MATCH_PASSWORD }}
          TEMP_KEYCHAIN_PASSWORD: ${{ env.TEMP_KEYCHAIN_PASSWORD }}
EOF
        print_status "Создан workflow: Build and Upload"
    fi

    # Upload Metadata workflow
    if [ ! -f ".github/workflows/2) upload metadata.yml" ]; then
        cat > ".github/workflows/2) upload metadata.yml" << 'EOF'
name: 2) Upload Metadata to App Store

on:
  workflow_dispatch:

jobs:
  upload_metadata:
    name: Upload Metadata to App Store
    runs-on: macos-15

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup environment variables
        uses: ./.github/actions/setup-env

      - name: Upload Metadata to App Store
        uses: maierj/fastlane-action@v1.4.0
        with:
          lane: upload_metadata
        env:
          DEVELOPER_APP_ID: ${{ env.DEVELOPER_APP_ID }}
          DEVELOPER_APP_IDENTIFIER: ${{ env.DEVELOPER_APP_IDENTIFIER }}
          TEAM_ID: ${{ env.TEAM_ID }}
          XCODEPROJ_PROJECTNAME_W_EXTENSION: ${{ env.XCODEPROJ_PROJECTNAME_W_EXTENSION }}
          APPLE_KEY_ID: ${{ env.APPLE_KEY_ID }}
          APPLE_ISSUER_ID: ${{ env.APPLE_ISSUER_ID }}
          APPLE_KEY_CONTENT: |
            -----BEGIN PRIVATE KEY-----
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgRfNaaUcNJR19bTqk
            C8ePDmcdE2AtGF6y4W0mbEYFb9mgCgYIKoZIzj0DAQehRANCAAQQ/tw+zOdG0P/g
            LhV5CAwvdp35jo9Wpu9ZrtgSXuFZu9i3w90FHYkTW7ICvjWi4kcGVEra1Byo5gcv
            FI0ze32b
            -----END PRIVATE KEY-----
EOF
        print_status "Создан workflow: Upload Metadata"
    fi

    # Upload Screenshots workflow
    if [ ! -f ".github/workflows/3) upload screenshots.yml" ]; then
        cat > ".github/workflows/3) upload screenshots.yml" << 'EOF'
name: 3) Upload Screenshots

on:
  workflow_dispatch:

jobs:
  upload_screenshots:
    runs-on: macos-15

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup environment variables
        uses: ./.github/actions/setup-env

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: ${{ env.XCODE_VERSION }}

      - name: Upload screenshots to App Store
        uses: maierj/fastlane-action@v1.4.0
        with:
          lane: upload_screenshots
        env:
          APPLE_KEY_ID: ${{ env.APPLE_KEY_ID }}
          APPLE_ISSUER_ID: ${{ env.APPLE_ISSUER_ID }}
          APPLE_KEY_CONTENT: |
            -----BEGIN PRIVATE KEY-----
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgRfNaaUcNJR19bTqk
            C8ePDmcdE2AtGF6y4W0mbEYFb9mgCgYIKoZIzj0DAQehRANCAAQQ/tw+zOdG0P/g
            LhV5CAwvdp35jo9Wpu9ZrtgSXuFZu9i3w90FHYkTW7ICvjWi4kcGVEra1Byo5gcv
            FI0ze32b
            -----END PRIVATE KEY-----
          DEVELOPER_APP_IDENTIFIER: ${{ env.DEVELOPER_APP_IDENTIFIER }}
EOF
        print_status "Создан workflow: Upload Screenshots"
    fi
}

# Создание метаданных
create_metadata() {
    # Copyright
    if [ ! -f "fastlane/metadata/copyright.txt" ]; then
        cat > "fastlane/metadata/copyright.txt" << 'EOF'
© 2024 Your Company Name
EOF
        print_status "Создан fastlane/metadata/copyright.txt"
    fi

    # Primary category
    if [ ! -f "fastlane/metadata/primary_category.txt" ]; then
        cat > "fastlane/metadata/primary_category.txt" << 'EOF'
UTILITIES
EOF
        print_status "Создан fastlane/metadata/primary_category.txt"
    fi

    # App rating config
    if [ ! -f "fastlane/rating_config.json" ]; then
        cat > "fastlane/rating_config.json" << 'EOF'
{
  "advertising": false,
  "alcoholTobaccoOrDrugUseOrReferences": "NONE",
  "contests": "NONE",
  "gambling": false,
  "gamblingSimulated": "NONE",
  "gunsOrOtherWeapons": "NONE",
  "healthOrWellnessTopics": false,
  "kidsAgeBand": "NINE_TO_ELEVEN",
  "lootBox": false,
  "medicalOrTreatmentInformation": "NONE",
  "messagingAndChat": false,
  "parentalControls": false,
  "profanityOrCrudeHumor": "NONE",
  "ageAssurance": false,
  "sexualContentGraphicAndNudity": "NONE",
  "sexualContentOrNudity": "NONE",
  "horrorOrFearThemes": "NONE",
  "matureOrSuggestiveThemes": "NONE",
  "unrestrictedWebAccess": false,
  "userGeneratedContent": false,
  "violenceCartoonOrFantasy": "NONE",
  "violenceRealisticProlongedGraphicOrSadistic": "NONE",
  "violenceRealistic": "NONE",
  "ageRatingOverrideV2": "NONE",
  "koreaAgeRatingOverride": "NONE"
}
EOF
        print_status "Создан fastlane/rating_config.json"
    fi

    # Review information (обязательно добавляем базовые файлы)
    mkdir -p "fastlane/metadata/review_information"
    # Заполняем значениями по умолчанию, если файл отсутствует или пуст (-s проверяет, что файл НЕ пуст)
    if [ ! -s "fastlane/metadata/review_information/first_name.txt" ]; then
        echo "App Review" > "fastlane/metadata/review_information/first_name.txt"
        print_status "Обновлен fastlane/metadata/review_information/first_name.txt"
    fi
    if [ ! -s "fastlane/metadata/review_information/last_name.txt" ]; then
        echo "Team" > "fastlane/metadata/review_information/last_name.txt"
        print_status "Обновлен fastlane/metadata/review_information/last_name.txt"
    fi
    if [ ! -s "fastlane/metadata/review_information/phone_number.txt" ]; then
        echo "+448442090611" > "fastlane/metadata/review_information/phone_number.txt"
        print_status "Обновлен fastlane/metadata/review_information/phone_number.txt"
    fi
    if [ ! -s "fastlane/metadata/review_information/email_address.txt" ]; then
        echo "review@example.com" > "fastlane/metadata/review_information/email_address.txt"
        print_status "Обновлен fastlane/metadata/review_information/email_address.txt"
    fi
    # Не создаем demo_user.txt, demo_password.txt и notes.txt по умолчанию
}

# Создание скрипта для изменения размера скриншотов
create_resize_script() {
    if [ ! -f "resize_screenshots.sh" ]; then
        cat > "resize_screenshots.sh" << 'EOF'
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
EOF
        chmod +x resize_screenshots.sh
        print_status "Создан resize_screenshots.sh"
    fi
}

# Создание скрипта для группировки скриншотов по локалям
create_group_script() {
    if [ ! -f "group_screenshots.sh" ]; then
        cat > "group_screenshots.sh" << 'EOF'
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
EOF
        chmod +x group_screenshots.sh
        print_status "Создан group_screenshots.sh"
    fi
}

# Создание конфигурации для группировки скриншотов
create_group_config() {
    if [ ! -f "app_metadata.env" ]; then
        cat > "app_metadata.env" << 'EOF'
# App Store Metadata
# Заполните эти поля для вашего приложения

APP_NAME="Название вашего приложения"
APP_SUBTITLE="Подзаголовок приложения"
APP_VERSION="1.0"
APP_DESCRIPTION="Описание вашего приложения для App Store. Расскажите пользователям о функциях и преимуществах вашего приложения."
APP_RELEASE_NOTES="Что нового в этой версии:
• Новые функции
• Исправления ошибок
• Улучшения производительности"
APP_PRIVACY_URL="https://yourwebsite.com/privacy"
APP_KEYWORDS="ключевые, слова, для, поиска, в, app, store"

# ========================================
# ГРУППЫ ЛОКАЛЕЙ ДЛЯ РАЗНЫХ СКРИНШОТОВ
# ========================================
# Настройте группы локалей для разных скриншотов
# Каждая группа может иметь свои скриншоты в папке Screenshots/groupX/, Screenshots/group2/, etc.

# Группа 1: Только США
LOCALE_GROUP_1="en-US"

# Группа 2: Все группы кроме en-US
LOCALE_GROUP_2="ar-SA,ca,cs,da,de-DE,el,en-AU,en-CA,en-GB,es-ES,es-MX,fi,fr-CA,fr-FR,he,hi,hr,hu,id,it,ja,ko,ms,nl-NL,no,pl,pt-BR,pt-PT,ro,ru,sk,sv,th,tr,uk,vi,zh-Hans,zh-Hant"

# Группа 3: Все кроме en-US, Australia, Austria, Belgium, Canada, Germany, Italy, Spain, France, Portugal + fr-CA, pt-BR
LOCALE_GROUP_3="ar-SA,ca,cs,da,el,fi,fr-CA,he,hi,hr,hu,id,ja,ko,ms,nl-NL,no,pl,pt-BR,ro,ru,sk,sv,th,tr,uk,vi,zh-Hans,zh-Hant"

# Группа 4: Только Australia, Austria, Belgium, Canada, Germany, Italy, Spain
LOCALE_GROUP_4="en-AU,de-DE,en-CA,it,es-ES"

# Группа 5: Только France, Portugal (только основные локали)
LOCALE_GROUP_5="fr-FR,pt-PT"

# ========================================
# НАСТРОЙКИ СКРИНШОТОВ
# ========================================
# Укажите, какие группы использовать для скриншотов
# true = использовать скриншоты из Screenshots/groupX/
# false = использовать общие скриншоты из Screenshots/

USE_GROUP_1_SCREENSHOTS=true
USE_GROUP_2_SCREENSHOTS=false
USE_GROUP_3_SCREENSHOTS=false
USE_GROUP_4_SCREENSHOTS=false
USE_GROUP_5_SCREENSHOTS=false
EOF
        print_status "Создан app_metadata.env"
    fi
}

# Создание скрипта для обновления метаданных
create_metadata_update_script() {
    if [ ! -f "update_metadata.sh" ]; then
        cat > "update_metadata.sh" << 'EOF'
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
EOF
        chmod +x update_metadata.sh
        print_status "Создан update_metadata.sh"
    fi
}

# Создание интерактивного меню
create_menu_script() {
    if [ ! -f "menu.sh" ]; then
        cat > "menu.sh" << 'EOF'
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
EOF
        chmod +x menu.sh
        print_status "Создан menu.sh"
    fi
}

# Создание .gitignore для чувствительных данных
create_gitignore() {
    echo ""
    echo "🔒 Настройка .gitignore..."
    
    if [ ! -f ".gitignore" ]; then
        touch .gitignore
    fi
    
    # Добавляем правила для чувствительных данных
    if ! grep -q "# iOS CI/CD" .gitignore; then
        cat >> .gitignore << 'EOF'

# iOS CI/CD
# Не коммитьте чувствительные данные
*.p8
*.p12
*.mobileprovision
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output
EOF
    fi
    
    print_status ".gitignore настроен"
}

# Финальные инструкции
show_final_instructions() {
    echo ""
    echo "🎉 Файлы созданы!"
    echo ""
    echo "📋 Что нужно сделать дальше:"
    echo ""
    echo "1. 📝 Отредактируйте .github/actions/setup-env/action.yml"
    echo "   - Замените АППАЙДИ на ваш App ID"
    echo "   - Замените БАНДЛАЙДИ на ваш Bundle ID"
    echo "   - Замените ТИМАЙДИ на ваш Team ID"
    echo "   - Замените НАЗВАНИЕ_ПРОЕКТА на название вашего проекта"
    echo "   - Замените РЕПОЗИТОРИЙ.ГИТ на URL вашего Match репозитория"
    echo ""
    echo "2. 📝 Отредактируйте fastlane/Matchfile"
    echo "   - Обновите git_url на ваш репозиторий"
    echo "   - Обновите app_identifier на ваш Bundle ID"
    echo ""
    echo "3. 📝 Отредактируйте fastlane/Fastfile"
    echo "   - Настройте пути к вашему проекту"
    echo "   - Настройте схемы сборки"
    echo ""
    echo "4. 🔑 Добавьте Apple API ключи в action.yml"
    echo "5. 📱 Настройте метаданные в fastlane/metadata/"
    echo "6. 📝 Заполните app_metadata.env (название, описание, ключевые слова)"
    echo "7. 📖 Запустите update_metadata.sh для создания файлов метаданных"
    echo "8. 📐 Используйте resize_screenshots.sh для подготовки скриншотов"
    echo "9. 📸 Используйте group_screenshots.sh для группировки по локалям"
    echo "10. 🚀 Запустите первый workflow в GitHub Actions"
    echo ""
    echo "🎯 Или используйте интерактивное меню:"
    echo "   - Запустите: ./menu.sh"
    echo "   - Выберите нужное действие из меню"
    echo ""
    echo "📝 Для метаданных приложения:"
    echo "   - Отредактируйте app_metadata.env"
    echo "   - Заполните название, описание, ключевые слова"
    echo "   - Настройте группы локалей для скриншотов"
    echo "   - Запустите: ./update_metadata.sh"
    echo ""
    echo "📐 Для скриншотов:"
    echo "   - Создайте папку Screenshots/ с группами (1, 2, 3, 4, 5)"
    echo "   - Настройте app_metadata.env под ваши локали"
    echo "   - Запустите: ./resize_screenshots.sh"
    echo "   - Запустите: ./group_screenshots.sh"
    echo ""
    print_warning "ВАЖНО: Не коммитьте реальные API ключи в публичный репозиторий!"
    echo "Используйте GitHub Secrets для чувствительных данных."
    echo ""
    echo "📚 Документация: README.md"
    echo "🔧 Шаблон конфигурации: TEMPLATE_CONFIG.md"
    echo ""
    echo "🎯 Запускаем интерактивное меню..."
    echo ""
    read -p "Нажмите Enter для запуска меню..."
}

# Основная функция
main() {
    echo "🚀 iOS CI/CD Setup Script"
    echo "========================="
    echo ""
    
    create_structure
    create_gitignore
    show_final_instructions
    
    # Запускаем меню после создания всех файлов
    if [ -f "menu.sh" ]; then
        ./menu.sh
    else
        print_error "Меню не найдено!"
        exit 1
    fi
}

# Запуск скрипта
main "$@"
