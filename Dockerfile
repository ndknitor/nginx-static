FROM nginx
COPY ./app /app
COPY ./ssl /ssl
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./entrypoint.sh /entrypoint.sh
ENV WORKER_CONNECTIONS=1024
EXPOSE 80 443
CMD [ "bash" ,"/entrypoint.sh" ]
