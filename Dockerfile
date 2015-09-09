FROM signiant/docker-jenkins-centos-base:centos7
MAINTAINER devops@signiant.com

ENV BUILD_USER bldmgr
ENV BUILD_USER_GROUP users

# Set the timezone
#RUN sed -ri '/ZONE=/c ZONE="America\/New York"' /etc/sysconfig/clock
#RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

# Install yum packages required for build node
COPY yum-packages.list /tmp/yum.packages.list
RUN chmod +r /tmp/yum.packages.list
RUN yum install -y -q `cat /tmp/yum.packages.list`

#install RVM 2.1.2

RUN /bin/bash -l -c "gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
RUN /bin/bash -l -c "curl -L get.rvm.io | bash -s stable"

RUN /bin/bash -l -c "rvm install 2.1.2"

COPY gem.packages.r21.list /tmp/gem.packages.r21.list
RUN chmod +r /tmp/gem.packages.r21.list

RUN /bin/bash -l -c "gem install `cat /tmp/gem.packages.r21.list | tr \"\\n\" \" \"`"

# Folder for secure files
RUN mkdir /etc/chef

RUN ln -s /etc/chef ~/.chef

# Make sure anything/everything we put in the build user's home dir is owned correctly
RUN chown -R $BUILD_USER:$BUILD_USER_GROUP /home/$BUILD_USER  

EXPOSE 22

# This entry will either run this container as a jenkins slave or just start SSHD
# If we're using the slave-on-demand, we start with SSH (the default)

# Default Jenkins Slave Name
ENV SLAVE_ID JAVA_NODE
ENV SLAVE_OS Linux

ADD start.sh /
RUN chmod 777 /start.sh

CMD ["sh", "/start.sh"]