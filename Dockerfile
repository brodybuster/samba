FROM alpine:edge

RUN set -eu && \
    apk --no-cache add \
    tini \
    bash \
    samba \
    samba-client \
    tzdata \
    shadow && \
    rm -f /etc/samba/smb.conf && \
    rm -rf /tmp/* /var/cache/apk/*

COPY --chmod=700 samba.sh /usr/bin/samba.sh
COPY --chmod=600 smb.conf /etc/samba/smb.conf
COPY --chmod=600 secrets/users /run/secrets/users
COPY --chmod=600 secrets/agent /run/secrets/agent

EXPOSE 445

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/samba.sh"]

HEALTHCHECK --interval=60s --timeout=15s CMD sh -ec 'agent="$(cut -d: -f1,2 /run/secrets/agent | tr ":" "%")"; smbclient -L localhost --configfile=/etc/samba.conf -U "$agent" -m SMB3 -c "exit"'
