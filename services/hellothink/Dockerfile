FROM alpine:latest

RUN apk add --no-cache mosquitto mosquitto-clients

WORKDIR /

COPY makehello.sh /
RUN chmod +x ./makehello.sh

CMD ./makehello.sh
