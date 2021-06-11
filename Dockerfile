FROM postgis/postgis:latest
MAINTAINER MOHSSIN mohssin.nagib@edu.uah.es
RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install unzip
RUN apt-get -y install postgis

ENV PGDATA=/var/lib/postgresql/data/pgdata


RUN wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/raster/NE1_50M_SR_W.zip
RUN unzip NE1_50M_SR_W.zip

USER postgres

RUN pg_createcluster 13 main --start &&\
    psql --command "CREATE DATABASE gis_database" &&\
    psql --command "CREATE EXTENSION postgis;"

USER root
RUN raster2pgsql -I -C -s 4326 NE1_50M_SR_W/NE1_50M_SR_W.tif public.rasterr > shadedrelief.sql

USER postgres
RUN service postgresql start &&\
    psql --command "\c gis_database" &&\
    psql -d gis_database -U postgres --command "CREATE EXTENSION postgis_raster CASCADE;" &&\
    psql -d gis_database -U postgres -f shadedrelief.sql

USER root
RUN rm shadedrelief.sql
RUN rm -rf NE1_50M_SR_W
RUN rm NE1_50M_SR_W.zip

USER postgres

EXPOSE 5432

CMD ["postgres"]

RUN chmod 777 /var/lib/postgresql/data
