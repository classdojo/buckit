# syntax=docker/dockerfile:1

FROM public.ecr.aws/docker/library/golang:1.22 AS builder

WORKDIR /app
ADD . /app
RUN go build -o buckit

FROM public.ecr.aws/debian/debian:bookworm-slim AS runner

RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/buckit /usr/local/bin/
ENTRYPOINT ["buckit"]
