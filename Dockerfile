FROM ubuntu:14.04
MAINTAINER yasadi <yassine.aouadi90@gmail.com>

RUN apt-get update && apt-get install -y --force-yes \
curl \
git \
npm \
build-essential

RUN curl -sL https://deb.nodesource.com/setup_4.x |sh
RUN apt-get install -y nodejs

WORKDIR /root/ahmed/E-commerce_Movies
COPY . /root/ahmed/E-commerce_Movies
RUN npm install -g bower
RUN npm install 
RUN bower install --allow-root 

RUN mkdir -p /opt/confd/bin /etc/confd/templates  /etc/confd/conf.d && \
  curl -sLk https://github.com/kelseyhightower/confd/releases/download/v0.9.0/confd-0.9.0-linux-amd64 > /opt/confd/bin/confd && \
  ln -s /opt/confd/bin/confd /bin/confd && \
chmod +x /opt/confd/bin/confd

RUN echo   "[template] \n src  =\"myconfig.sh.tmpl\" \n dest = \"/tmp/myconfig.sh\" \n keys = [ \n \"/portahmed\" \n ]" > /etc/confd/conf.d/myconfig.toml

RUN echo  "#!/bin/bash  \n port={{getv \"/portahmed\"}} \n sed  \"s/^\s*var\s*PORT.*$/var PORT = \$port/g\" /root/ahmed/E-commerce_Movies/server.js > server1.js \n cp  server1.js   /root/ahmed/E-commerce_Movies/server.js \n rm server1.js  \n nodejs /root/ahmed/E-commerce_Movies/server.js " > /etc/confd/templates/myconfig.sh.tmpl
 
COPY myStartupScript.sh /usr/local/myscripts/myStartupScript.sh
EXPOSE 3001
CMD ["/bin/bash", "/usr/local/myscripts/myStartupScript.sh"]
