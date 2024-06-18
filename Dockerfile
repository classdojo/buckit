FROM golang:1.22 as builder

WORKDIR /app
ADD . /app
RUN go build -o buckit

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/buckit /usr/local/bin/
ENTRYPOINT ["buckit"]
