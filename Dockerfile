# Многоступенчатая сборка для оптимизации размера образа

# Стадия 1: Сборка приложения
FROM golang:1.22-alpine AS builder

# Установка необходимых пакетов для сборки
RUN apk add --no-cache git ca-certificates tzdata gcc musl-dev sqlite-dev

# Создание рабочей директории
WORKDIR /app

# Копирование файлов зависимостей
COPY go.mod go.sum ./

# Загрузка зависимостей
RUN go mod download
RUN go mod verify

# Копирование исходного кода
COPY . .

# Сборка приложения с оптимизациями
RUN CGO_ENABLED=1 GOOS=linux go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main .

# Стадия 2: Финальный образ
FROM alpine:latest

# Установка необходимых runtime зависимостей
RUN apk --no-cache add ca-certificates tzdata sqlite

# Создание пользователя для безопасности
RUN adduser -D -s /bin/sh appuser

# Создание рабочей директории
WORKDIR /app

# Копирование сертификатов и временных зон
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Копирование собранного приложения
COPY --from=builder /app/main .
COPY tracker.db /app/

# Установка владельца файлов
RUN chown -R appuser:appuser /app

# Переключение на пользователя appuser
USER appuser

# Открытие порта (если приложение использует HTTP)
EXPOSE 8080

# Healthcheck для проверки состояния контейнера
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["./main", "--health-check"] || exit 1

# Команда запуска
CMD ["./main"]