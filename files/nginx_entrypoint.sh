openssl req -x509 -newkey rsa:4096 -nodes -sha256 \
  -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
  -out /etc/ssl/certs/ssl-cert-snakeoil.pem -days 3650 \
  -subj "/CN=$(curl "$${ECS_CONTAINER_METADATA_URI}" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')" && \
  echo '${nginx_conf_template_b64}' | \
  base64 -d > /etc/nginx/templates/default.conf.template && \
  exec /docker-entrypoint.sh nginx -g 'daemon off;'
