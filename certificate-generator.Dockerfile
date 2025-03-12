FROM alpine:latest

RUN apk add --no-cache openssl

COPY ./generate_certs.sh /generate_certificates.sh

RUN chmod +x /generate_certificates.sh

CMD [ "sh", "/generate_certificates.sh" ]