ARG GOLANG_IMAGE=golang:1.24.5-bookworm
ARG BASE=gcr.io/distroless/static-debian12:nonroot
FROM ${GOLANG_IMAGE} AS build
SHELL [ "/bin/sh", "-ec" ]

RUN export DEBCONF_NONINTERACTIVE_SEEN=true \
           DEBIAN_FRONTEND=noninteractive \
           DEBIAN_PRIORITY=critical \
           TERM=linux ; \
    apt-get -qq update ; \
    apt-get -yyqq upgrade ; \
    apt-get -yyqq install ca-certificates libcap2-bin; \
    apt-get clean
WORKDIR /app
COPY . .
RUN go mod download
RUN make build
RUN setcap cap_net_bind_service=+ep /app/bin/coredns

FROM ${BASE}
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /app/bin/coredns /coredns
USER nonroot:nonroot
WORKDIR /
EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
