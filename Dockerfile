# DOCKER-VERSION 0.3.4
FROM    centos:6.4
RUN     yum install -y updates

# Enable EPEL for Node.js
RUN     rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN     yum install -y updates
# Install Node.js and npm
RUN     yum install -y npm

# Bundle app source
ADD . /src
# Install app dependencies
RUN cd /src; npm install
RUN cd /src; npm install -g yo
RUN cd /src; npm install -g karma
RUN cd /src; npm install -g bower

EXPOSE  8080
CMD ["node", "/src/index.js"]