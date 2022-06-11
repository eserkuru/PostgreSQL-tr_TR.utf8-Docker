FROM postgres:latest

# create a Turkish language pack between operating system languages
RUN apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
	localedef -i tr_TR -c -f UTF-8 -A /usr/share/locale/locale.alias tr_TR.UTF-8

# make the "tr_TR.UTF-8" locale so postgres will be utf-8 enabled by default [optional]
# ENV LANG tr_TR.utf8