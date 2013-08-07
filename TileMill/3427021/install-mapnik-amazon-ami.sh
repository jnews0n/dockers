# http://aws.amazon.com/amazon-linux-ami/
# http://aws.amazon.com/amazon-linux-ami/faqs/

# Boot up a machine with at least 1.5 to 2 GB Ram

# login
# ssh -i key.pem ec2-user@ec2...compute.amazonaws.com

# update
sudo yum -y update
sudo yum -y upgrade

# enable EPEL6 by changing enabled=0 -> enabled=1
sudo vim /etc/yum.repos.d/epel.repo

# install deps
sudo yum -y install make clang gcc47 protobuf-devel protobuf-lite bzip2-devel libtool-ltdl-devel libpng-devel libtiff-devel \
zlib-devel libjpeg-devel libxml2-devel htop git-all python-nose proj-devel proj proj-epsg proj-nad libtool-ltdl-devel \
libtool-ltdl freetype-devel freetype libicu-devel libicu gdal-devel gdal postgresql-devel sqlite-devel sqlite libcurl-devel \
libcurl cairo-devel cairo pycairo-devel pycairo geos-devel geos

# setup gcc47
# appears to be no longer needed
#sudo ln -s /usr/bin/gcc46 /usr/bin/gcc
#sudo ln -s /usr/bin/g++46 /usr/bin/g++
#export CC=gcc
#export CXX=g++
#alias cc=$CC

# build recent boost
export BOOST_VERSION2="1_54_0"
#export S3_BASE="http://mapnik.s3.amazonaws.com/deps"
#curl -O ${S3_BASE}/boost_${BOOST_VERSION2}.tar.bz2
mkdir -p /usr/local/src
cd /usr/local/src
wget -c http://sourceforge.net/projects/boost/files/boost/1.54.0/boost_1_54_0.tar.gz/download
tar xf boost_1_54_0.tar.gz
tar xf boost_${BOOST_VERSION2}.tar.gz
cd boost_${BOOST_VERSION2}
./bootstrap.sh
./b2 -j8 \
    --with-thread \
    --with-filesystem \
    --with-python \
    --with-regex -sHAVE_ICU=1  \
    --with-program_options \
    --with-system \
    link=shared \
    toolset=gcc \
    stage
sudo ./b2 -j8 \
    --with-thread \
    --with-filesystem \
    --with-python \
    --with-regex -sHAVE_ICU=1 \
    --with-program_options \
    --with-system \
    toolset=gcc \
    link=shared \
    install
cd ../

# set up support for libraries installed in /usr/local/lib
sudo bash -c "echo '/usr/local/lib' > /etc/ld.so.conf.d/boost.conf"
sudo ldconfig

# mapnik
git clone https://github.com/mapnik/mapnik
cd mapnik
./configure
make
sudo make install

# node
wget http://nodejs.org/dist/v0.10.7/node-v0.10.7.tar.gz
tar xf node-v0.10.7.tar.gz
cd node-v0.10.7
./configure
sudo make install
cd ../

# node-mapnik
git clone https://github.com/mapnik/node-mapnik
cd node-mapnik
export LDFLAGS="-L/usr/lib64" # workaround pkg-config --libs-only-L bug
npm install
npm test
cd ../

# tilemill
git clone https://github.com/mapbox/tilemill
cd tilemill
vim package.json # remove the 'topcube' line since the GUI will not work on fedora due to lacking gtk/webkit
npm install
./index.js --server=true # view on http://localhost:20009, more info: http://mapbox.com/tilemill/docs/guides/ubuntu-service/
