FROM alpine:latest

RUN apk add --no-cache mosquitto mosquitto-clients

COPY makehello.sh ca.crt /root/
RUN chmod +x /root/makehello.sh

ENTRYPOINT ["/root/makehello.sh"]
