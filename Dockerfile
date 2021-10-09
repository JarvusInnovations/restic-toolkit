FROM biomesh/bio-x86_64-linux:1.6.372

# replace busybox gzip/bzip2/tar with full GNU versions at both /bin and /usr/bin
RUN bio pkg install --binlink --binlink-dir /bin --force \
        core/bzip2 \
        core/gzip \
        core/tar \
        core/xz \
    && bio pkg binlink core/bzip2 --dest /usr/bin --force \
    && bio pkg binlink core/gzip --dest /usr/bin --force \
    && bio pkg binlink core/tar --dest /usr/bin --force \
    && bio pkg binlink core/xz --dest /usr/bin --force \
    && rm -r /hab/cache/artifacts

# install backup tools
RUN bio pkg install --binlink \
        core/kubectl \
        core/mysql-client \
        core/postgresql11-client \
        core/restic \
        jarvus/rclone \
    && rm -r /hab/cache/artifacts
