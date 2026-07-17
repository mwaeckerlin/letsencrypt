FROM mwaeckerlin/very-base AS build
RUN $PKG_INSTALL g++ ca-certificates
WORKDIR /build
COPY le-run.cpp .
RUN g++ -std=c++17 -O2 -o /usr/bin/le-run le-run.cpp
# lego: a single compiled Go ACME client -- no Python, no shell, no cron.
COPY --from=goacme/lego:latest /lego /usr/bin/lego

# Writable runtime directories, owned by the unprivileged run user.
RUN mkdir -p /root/acme /root/etc/letsencrypt /root/tmp
RUN chmod 1777 /root/tmp
RUN chown -R somebody:somebody /root/acme /root/etc/letsencrypt

# Install the two executables, their libraries and the CA bundle (to validate
# the real Let's Encrypt endpoint) into /root for the scratch image.
ENV EXE "/usr/bin/le-run /usr/bin/lego"
RUN tar cph $EXE /etc/ssl/certs/ca-certificates.crt \
    $(for f in $EXE; do \
    ldd $f | sed -n 's,.* => \([^ ]*\) .*,\1,p'; \
    done 2> /dev/null) 2> /dev/null \
    | tar xpC /root/

RUN test -e /root/usr/bin/lego
RUN test -e /root/usr/bin/le-run

# The final image has no shell, no Python and no cron -- only lego, the C++
# launcher and their dependencies.
FROM mwaeckerlin/scratch
ENV CONTAINERNAME "letsencrypt"
ENV MODE "webroot"
ENV PREFIXES "www"
COPY --from=build /root /
CMD [ "/usr/bin/le-run" ]
