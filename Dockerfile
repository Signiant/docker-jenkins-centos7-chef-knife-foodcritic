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

#install RVM 1.9.3

RUN /bin/bash -l -c "gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
RUN /bin/bash -l -c "curl -L get.rvm.io | bash -s stable"
RUN /bin/bash -l -c "rvm install 1.9.3"
RUN /bin/bash -l -c "echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
RUN source /etc/profile.d/rvm.sh
RUN /bin/bash -l -c "rvm install 2.1.1"

RUN /bin/bash -l -c "rvm use 1.9.3"

#Install required gems for our promotion scripts
COPY gem.packages.list /tmp/gem.packages.list
RUN chmod +r /tmp/gem.packages.list

COPY gem.packages.r21.list /tmp/gem.packages.r21.list
RUN chmod +r /tmp/gem.packages.r21.list

RUN /bin/bash -l -c "gem install `cat /tmp/gem.packages.list | tr \"\\n\" \" \"`"

RUN /bin/bash -l -c "rvm use 2.1.1"

RUN /bin/bash -l -c "gem install `cat /tmp/gem.packages.r21.list | tr \"\\n\" \" \"`"

# Install the AWS CLI - used by promo process
RUN pip install awscli

# Install shyaml - used by promo process to ECS
RUN pip install shyaml

# Install boto and requests - used by the S3 MIME type setter
RUN pip install boto
RUN pip install requests

# Folder for secure files
RUN mkdir /etc/chef

RUN ln -s /etc/chef ~/.chef

RUN ln -s /etc/chef /.chef


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
