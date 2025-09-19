# 🚀 Настройка CI/CD для Go1FL Sprint 11

Этот документ описывает настройку автоматического тестирования и публикации Docker образов в DockerHub для проекта.

## 📋 Обзор

Настроенный CI/CD pipeline включает два основных job'а:

### 1. 🧪 Test Job (Тестирование и проверка качества кода)
- **Запускается**: При каждом push и pull request
- **Выполняет**:
  - Проверку форматирования кода (`gofmt`)
  - Статический анализ с помощью `go vet`
  - Линтинг с `golangci-lint`
  - Запуск тестов с покрытием кода
  - Проверку безопасности
  - Сборку приложения

### 2. 🐳 Docker Publish Job (Публикация в DockerHub)
- **Запускается**: Только при создании тегов версий (например, `v1.0.0`)
- **Выполняет**:
  - Сборку Docker образа с multi-stage build
  - Публикацию в DockerHub с тегами версий
  - Поддержку multiple архитектур (amd64, arm64)
  - Создание GitHub Release с описанием

## 🔧 Начальная настройка

### Шаг 1: Настройка DockerHub секретов

Необходимо добавить следующие секреты в настройках репозитория GitHub:

1. Перейдите в **Settings** → **Secrets and variables** → **Actions**
2. Добавьте секреты:

```bash
# DockerHub логин (ваш username)
DOCKERHUB_USERNAME=ykmn0

# DockerHub токен доступа (создайте в DockerHub → Account Settings → Security)
DOCKERHUB_TOKEN=your_dockerhub_access_token
```

### Шаг 2: Создание DockerHub Access Token

1. Войдите в [DockerHub](https://hub.docker.com/)
2. Перейдите в **Account Settings** → **Security**
3. Нажмите **New Access Token**
4. Выберите права доступа: **Read, Write, Delete**
5. Скопируйте созданный токен и добавьте его как `DOCKERHUB_TOKEN`

### Шаг 3: Создание DockerHub репозитория

1. Создайте репозиторий в DockerHub с именем `go1fl-sprint11`
2. Или измените переменную `IMAGE_NAME` в workflow файле на другое имя

## 🏃‍♂️ Использование

### Запуск тестов

Тесты запускаются автоматически при каждом push:

```bash
git add .
git commit -m "Add new feature"
git push origin main
```

### Создание релиза с Docker образом

Для создания релиза и публикации Docker образа:

```bash
# Создание тега версии
git tag v1.0.0
git push origin v1.0.0
```

Это автоматически:
- Запустит все тесты
- Соберет Docker образ
- Опубликует образ в DockerHub с тегами:
  - `ykmn0/go1fl-sprint11:v1.0.0`
  - `ykmn0/go1fl-sprint11:1.0`
  - `ykmn0/go1fl-sprint11:1`
  - `ykmn0/go1fl-sprint11:latest`
- Создаст GitHub Release

## 🐳 Использование Docker образа

### Запуск контейнера

```bash
# Запуск последней версии
docker run -p 8080:8080 ykmn0/go1fl-sprint11:latest

# Запуск конкретной версии
docker run -p 8080:8080 ykmn0/go1fl-sprint11:v1.0.0

# Запуск с подключением базы данных
docker run -p 8080:8080 -v $(pwd)/data:/app/data ykmn0/go1fl-sprint11:latest
```

### Docker Compose (опционально)

Создайте `docker-compose.yml`:

```yaml
version: '3.8'
services:
  app:
    image: ykmn0/go1fl-sprint11:latest
    ports:
      - "8080:8080"
    volumes:
      - ./data:/app/data
    environment:
      - ENV=production
    restart: unless-stopped
```

## 📊 Мониторинг и отладка

### Просмотр логов workflow

1. Перейдите в **Actions** tab в GitHub
2. Выберите нужный workflow run
3. Просмотрите логи каждого job'а

### Локальная отладка

```bash
# Запуск тестов локально
go test -v ./... -coverprofile=coverage.out

# Просмотр покрытия кода
go tool cover -html=coverage.out

# Локальная сборка Docker образа
docker build -t go1fl-sprint11:local .

# Запуск линтера
golangci-lint run
```

## 🔧 Кастомизация

### Изменение конфигурации линтера

Редактируйте `.golangci.yml` для настройки правил линтинга.

### Изменение Docker образа

Редактируйте `Dockerfile` для изменения процесса сборки.

### Добавление дополнительных проверок

Редактируйте `.github/workflows/ci-cd.yml` для добавления новых steps.

## 🚨 Устранение неполадок

### Ошибки аутентификации DockerHub

- Проверьте правильность `DOCKERHUB_USERNAME` и `DOCKERHUB_TOKEN`
- Убедитесь, что токен имеет необходимые права доступа

### Ошибки сборки Docker

- Проверьте синтаксис `Dockerfile`
- Убедитесь, что все зависимости доступны

### Ошибки тестов

- Запустите тесты локально: `go test -v ./...`
- Проверьте совместимость версий Go

## 📈 Расширенные возможности

### Добавление уведомлений

Можно добавить уведомления в Slack, Discord или email при успешной/неуспешной сборке.

### Deployment в Kubernetes

Можно расширить pipeline для автоматического деплоя в Kubernetes кластер.

### Интеграция с security сканерами

Можно добавить дополнительные security проверки типа Trivy, Snyk и др.

---

💡 **Совет**: Начните с простых тегов типа `v0.1.0` для тестирования процесса, затем переходите к более сложной схеме версионирования.