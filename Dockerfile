FROM ubuntu:20.04

# No apt prompts
ARG DEBIAN_FRONTEND=noninteractive

#installing php7.X
RUN apt update -y && apt install software-properties-common -y && add-apt-repository ppa:ondrej/php -y && apt-get update -y  && apt install php7.4 php7.4-cli php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath -y 

#installing servers and utilities
RUN apt install unzip curl wget vim git mariadb-server apache2 python3-pip python2 -y

#installing pip2 (will be used to install exploit.py dependencies)
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && python2 get-pip.py

# starting web and db server
#RUN /etc/init.d/mysql start && /etc/init.d/apache2 start

#Setting root user password
RUN echo "root:toor" | chpasswd
 
# COPY the web root to container image
COPY ./html/ /var/www/html/

#COPY the database file in the container
COPY ./qdpm.sql /var/www/

#rm deault index.html
RUN rm /var/www/html/index.html

# Configuring mysql
RUN /etc/init.d/mysql start && mysql -uroot -ptoor -e "CREATE DATABASE qdpm default charset utf8; CREATE USER 'qdpm'@'localhost' IDENTIFIED BY 'StrongPasswordHere';GRANT ALL PRIVILEGES ON qdpm.* TO 'qdpm'@'localhost';"

# importing mysql db
RUN /etc/init.d/mysql start && mysql -uroot -ptoor qdpm < /var/www/qdpm.sql

#setting permisioons for web root
RUN chown -R www-data:www-data /var/www/html

# exposing container port 80
EXPOSE 80

ENTRYPOINT ["/usr/bin/bash", "-c","/etc/init.d/mysql start && /etc/init.d/apache2 start && tail -f /dev/null"]

#CMD apachectl -D FOREGROUND
#CMD tail -f /dev/null
