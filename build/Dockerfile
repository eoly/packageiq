FROM centos:7

MAINTAINER Eric Olsen <eric@ericolsen.net>

ENV REFRESHED_AT 2015-02-04

RUN yum update -y && yum install -y \
        curl \
        gcc \
        git \
        make \
        rpm-build \
        ruby \
        ruby-devel \
        tar

RUN echo "gem: --no-ri --no-rdoc" >/etc/gemrc
RUN gem install fpm -v 1.4.0
RUN gem install fpm-cookery -v 0.31.0
RUN yum -y install vim

VOLUME /data
WORKDIR /data

CMD ["fpm-cook", "install-build-deps", "--debug", "--tmp-root", "/tmp", "recipes/recipe.rb"]
CMD ["fpm-cook", "package", "--debug", "--tmp-root", "/tmp", "--pkg-dir", "pkg", "--no-deps", "recipes/recipe.rb"]
