FROM debian:bullseye-slim

RUN apt update
RUN apt-get dist-upgrade -y
RUN apt-get --no-install-recommends install cups printer-driver-brlaser -y

# add print user
RUN adduser --home /home/admin --shell /bin/bash --gecos "admin" --disabled-password admin \
  && adduser admin sudo \
  && adduser admin lp \
  && adduser admin lpadmin

# disable sudo password checking
RUN echo 'admin ALL=(ALL:ALL) ALL' >> /etc/sudoers

# enable access to CUPS
RUN /usr/sbin/cupsd \
  && while [ ! -f /var/run/cups/cupsd.pid ]; do sleep 1; done \
  && cupsctl --remote-admin --remote-any --share-printers \
  && kill $(cat /var/run/cups/cupsd.pid) \
  && echo "ServerAlias *" >> /etc/cups/cupsd.conf \
  && echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

RUN cp -rp /etc/cups /etc/cups-skel

# entrypoint
ENV ADMIN_PASSWORD=admin

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh 
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

# default command
CMD ["cupsd", "-f"]

EXPOSE 631
