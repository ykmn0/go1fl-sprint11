FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

WORKDIR /app

ENV CGO_ENABLED=0 \
    GO111MODULE=on

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY . .

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -trimpath -buildvcs=false -ldflags="-s -w" -o app ./...

FROM scratch

WORKDIR /app

COPY --from=builder /app/app /app/app
COPY tracker.db /app/

ENV TRACKER_DB_PATH=/app/tracker.db

ENTRYPOINT ["/app/app"]
