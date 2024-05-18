FROM quay.io/projectquay/golang:1.20 as builder

WORKDIR /go/src/app
COPY . .
ARG TARGETARCH
RUN make TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH} build

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/hobot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot", "start"]	
