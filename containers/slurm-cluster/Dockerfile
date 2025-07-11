FROM centos:7

LABEL org.opencontainers.image.source="https://github.com/kalenpeterson/kube-slurm" \
      org.opencontainers.image.title="slurm-docker-cluster" \
      org.opencontainers.image.description="Slurm Docker cluster on CentOS 7"

ARG SLURM_VERSION=20.11.9
ARG GOSU_VERSION=1.11
ARG MUNGE_UID
ARG MUNGE_GID
ARG SLURM_UID
ARG SLURM_GID

# Setup Users and Groups
RUN groupadd -g $MUNGE_GID munge && \
    useradd  -m -c "MUNGE" -d /var/lib/munge -u $MUNGE_UID -g munge -s /sbin/nologin munge && \
    groupadd -g $SLURM_GID slurm && \
    useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURM_UID -g slurm -s /bin/bash slurm

# Install Base Requirements
RUN set -ex \
    && yum makecache fast \
    && yum -y update \
    && yum -y install epel-release \
    && yum -y install \
       wget \
       bzip2 \
       perl \
       gcc \
       make \
       munge \
       munge-devel \
       python3 \
       mariadb-server \
       mariadb-devel \
       psmisc \
       bash-completion \
       vim-enhanced \
       rpm-build \
       perl-ExtUtils-MakeMaker \
       openssl openssl-devel \
       pam-devel numactl numactl-devel hwloc hwloc-devel \
       lua lua-devel readline-devel rrdtool-devel \
       ncurses-devel man2html libibmad libibumad \
    && yum clean all \
    && rm -rf /var/cache/yum

# Setup Munge
RUN /usr/sbin/create-munge-key && \
    chown -R munge: /etc/munge/ /var/log/munge/ /var/lib/munge/ /run/munge/ && \
    chmod 0700 /etc/munge/ /var/log/munge/ /var/lib/munge/ /run/munge/

# Install Gosu
RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# Install Slurm
# Ref. https://www.schedmd.com/slurm/installation-tutorial/
RUN wget https://download.schedmd.com/slurm/slurm-$SLURM_VERSION.tar.bz2 && \
    rpmbuild -ta slurm-$SLURM_VERSION.tar.bz2 && \
    yum --nogpgcheck -y localinstall /root/rpmbuild/RPMS/x86_64/slurm-* && \
    rm -rf slurm-$SLURM_VERSION.tar.bz2 /root/rpmbuild && \
    mkdir -p /var/spool/slurmctld && \
    chown slurm:slurm /var/spool/slurmctld && \
    chmod 755 /var/spool/slurmctld && \
    mkdir -p /var/log/slurm && \
    touch /var/log/slurm/slurmctld.log && \
    touch /var/log/slurm/slurm_jobacct.log /var/log/slurm/slurm_jobcomp.log && \
    chown -R slurm:slurm /var/log/slurm/

# Copy in the Entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Fix Munge Permissions
RUN chmod +x /run/munge

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Set the default startup service to slurmdbd
#  Pass other service names to start them instead
CMD ["slurmdbd"]
