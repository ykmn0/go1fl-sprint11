FROM golang:1.24-alpine AS builder

RUN apk add --no-cache gcc

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download
RUN go mod verify

COPY . .

RUN CGO_ENABLED=1 GOOS=linux go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main .

FROM alpine:latest

RUN apk --no-cache add sqlite

RUN adduser -D -s /bin/sh appuser

WORKDIR /app

COPY --from=builder /app/main .
COPY tracker.db /app/

RUN chown -R appuser:appuser /app

USER appuser

CMD ["./main"]
