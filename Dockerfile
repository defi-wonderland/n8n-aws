# Use a specific version for stability, or :latest for newest
FROM docker.n8n.io/n8nio/n8n:1.123.6

USER root
RUN apk add --no-cache ffmpeg
USER node