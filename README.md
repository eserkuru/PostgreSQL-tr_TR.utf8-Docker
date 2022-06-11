# How can i create Postges with custom collation on docker?

> You don't need to do this if the language you want to use already exists in the operating system used for the container. You can create a container using the official image and use the commands below to check the available languages.
> ```PowerShell
> docker exec -it your_container_name bash
> ```
> then:
> ```PowerShell
> locale -a
> ```

### If the language you want to use is not already included in the operating system used for the container, let's continue.
1. Extend a latest official version of postgres image with your custom language using `Dockerfile`.

``` Dockerfile
FROM postgres:latest

# Generate a your language pack between operating system languages. We use: tr_TR.UTF-8
RUN apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
	localedef -i tr_TR -c -f UTF-8 -A /usr/share/locale/locale.alias tr_TR.UTF-8

# If you want to change the default language of the container, you can also add the following code. [optional]
# ENV LANG tr_TR.utf8

```

2. Build your custom docker image using this command.
```PowerShell
docker build -t postgres_tr .
```

3. Prepare your `docker-compose.yml` file.

``` YAML
version: '3.1'
services:
  postgres:
    image: postgres_tr:latest
    container_name: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: changeme
      PGDATA: /data/postgres
      # If you want to change the default collation of Postgres you can use the following. [optional]
      #POSTGRES_INITDB_ARGS: '--encoding=UTF-8 --lc-collate=tr_TR.UTF-8 --lc-ctype=tr_TR.UTF-8'
    volumes:
       - postgres:/data/postgres
    ports:
      - "5432:5432"
volumes:
  postgres:
```

4. Build your container using compose file.

```PowerShell
docker compose up -d
```

5. Browse the logs of the created container.

```PowerShell
docker logs -f postgres
```

6. You can now check the collation you added using a database client.

```PLpgSQL
SELECT * FROM pg_catalog.pg_collation pc where pc.collname like '%tr_TR%'
```

7. You can use the following command to see the default collation of your data catalogs.

```PLpgSQL
SELECT * FROM pg_catalog.pg_database pd
```
> If you enable the `POSTGRES_INITDB_ARGS` environment variable in the docker-compose file, the databases will be created with the collation you set by default when creating them. Normally the default value is en_US.utf8.

#
#

### How can you create a new collated database?
 
 ```PLpgSQL
CREATE DATABASE "your_db" WITH OWNER "postgres" ENCODING 'UTF8' LC_COLLATE = 'tr_TR.utf8' LC_CTYPE = 'tr_TR.utf8' TEMPLATE template0;
```

### How can you change the collation of the existing database?

1. Run the script.
 ```PLpgSQL
UPDATE pg_database SET datcollate='tr_TR.utf8', datctype='tr_TR.utf8' where datname='your_db';
```
2. Restart your container.

```PowerShell
docker restart postgres
```

> I hope it was useful for you. Thank you for giving a time.
