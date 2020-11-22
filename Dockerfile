FROM debian:buster-slim

RUN apt update
RUN apt-get dist-upgrade -y
RUN apt-get --no-install-recommends install libcups2-dev g++ cmake make ca-certificates wget cups -y

WORKDIR /src

RUN wget https://github.com/pdewacht/brlaser/archive/v6.tar.gz

RUN tar zxvf v6.tar.gz

WORKDIR /src/brlaser-6

RUN cmake .
RUN make
RUN make install

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
  && echo "ServerAlias *" >> /etc/cups/cupsd.conf

RUN echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf
RUN cp -rp /etc/cups /etc/cups-skel

# entrypoint
ENV ADMIN_PASSWORD=admin

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh 
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

# default command
CMD ["cupsd", "-f"]

EXPOSE 631
