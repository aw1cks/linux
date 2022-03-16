FROM docker.io/archlinux:base-devel
RUN useradd -m -d /aurbuilder aurbuilder && \
    printf 'aurbuilder ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/aurbuilder
USER aurbuilder
COPY entrypoint.sh /aurbuilder/
ENTRYPOINT ["bash", "-xc", "/aurbuilder/entrypoint.sh"]
