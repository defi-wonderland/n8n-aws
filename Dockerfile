FROM docker.n8n.io/n8nio/n8n

USER root
RUN apk add --no-cache ffmpeg
USER node