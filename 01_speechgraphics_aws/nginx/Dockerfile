FROM nginx:1.19.6-alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d
EXPOSE 80

WORKDIR /app
COPY staticfiles staticfiles
