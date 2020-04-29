# === Build fixtures (Debian) =================================================
FROM debian:stretch AS debian-build

RUN apt-get update && apt-get -y install equivs reprepro

RUN mkdir -p /pulp-fixtures/fixtures
ADD Makefile /pulp-fixtures
ADD common /pulp-fixtures/common
ADD debian /pulp-fixtures/debian

RUN make -C pulp-fixtures all-debian

# === Serve content ===========================================================
FROM nginx AS server

RUN mkdir -p /usr/share/nginx/html/fixtures
COPY --from=debian-build pulp-fixtures/fixtures /usr/share/nginx/html/fixtures

# turn on autoindex
RUN sed -i -e '/location.*\/.*{/a autoindex on\;' /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
