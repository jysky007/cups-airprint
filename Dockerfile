FROM ubuntu:lunar

LABEL maintainer="Grzegorz Sterniczuk <docker@sternicz.uk>"
LABEL org.opencontainers.image.source https://github.com/dzikus/cups-airprint

#  && apt-get install -y --no-install-recommends --force-yes \
#  && apt-get install -y --force-yes \
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
	cups \
	cups-pdf \
	cups-bsd \
	cups-filters \
	cups-core-drivers \
	cups-filters-core-drivers \
	cups-ppdc \
	hplip \
	inotify-tools \
	foomatic-db-compressed-ppds \
	printer-driver-all \
	openprinting-ppds \
	hpijs-ppds \
	hp-ppd \
	python3-cups \
	cups-backend-bjnp \
	ghostscript-x foomatic-db-engine \
  && apt clean all \
  && rm -rf /var/lib/apt/lists/*

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*
CMD ["/root/run_cups.sh"]

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing No/Browsing Yes/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf
