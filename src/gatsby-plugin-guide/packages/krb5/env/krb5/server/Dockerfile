# docker build --tag nikita_krb5 .
# Run the container and tail /var/log/kerberos/krb5kdc.log
# docker run --rm -it nikita_krb5

FROM centos:7
MAINTAINER SequenceIQ

# EPEL
RUN yum install -y epel-release

# kerberos
RUN yum install -y krb5-server krb5-libs krb5-auth-dialog krb5-workstation 

EXPOSE 88 749

ADD ./config.sh /config.sh

ENTRYPOINT ["/config.sh"]
