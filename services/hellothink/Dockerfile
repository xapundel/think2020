FROM alpine:latest

RUN apk add --no-cache mosquitto mosquitto-clients

COPY makehello.sh /root/
RUN chmod +x /root/makehello.sh

ENTRYPOINT ["/root/makehello.sh"]
