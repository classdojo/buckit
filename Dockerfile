FROM golang:1.22-bookworm as builder

WORKDIR /app
ADD . /app
RUN go build -o buckit

FROM debian:bookworm-slim

COPY --from=builder /app/buckit /usr/local/bin/
ENTRYPOINT ["buckit"]
