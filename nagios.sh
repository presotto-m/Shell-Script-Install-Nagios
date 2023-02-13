#!/bin/bash

# Instalando Apache, PHP e outras dependências
apt-get install apache2 php sudo libapache2-mod-php autoconf bc gawk dc build-essential gcc libc6 make wget unzip libgd-dev libmcrypt-dev make libssl-dev snmp libnet-snmp-perl gettext curl -y

# Reiniciando serviços
sudo systemctl start apache2
sudo systemctl enable apache2

# Baixando Nagios
wget https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz

# Extraindo arquivos
tar -xvzf nagios-4.4.6.tar.gz

# Navegando ate o diretorio e configurando
cd nagioscore-nagios-4.4.6
./configure --with-httpd-conf=/etc/apache2/sites-enabled

# Criando programas necessarios
sudo make all
sudo make install-groups-users

# Adicionando usuario Nagios ao Apache
sudo usermod -a -G nagios www-data

# Instalando Nagios, incluindo configuração web, modo de comando e outros componentes
sudo make install
sudo make install-daemoninit
sudo make install-commandmode
sudo make install-config
sudo make install-webconf

# habilitar os módulos rewrite e cgi do Apache
sudo a2enmod rewrite cgi

# Reiniciando Apache2
sudo systemctl restart apache2

# Adicionando senha de adminitrador Nagios
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

sudo chown www-data:www-data /usr/local/nagios/etc/htpasswd.users
sudo chmod 640 /usr/local/nagios/etc/htpasswd.users

wget https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.3.3/nagios-plugins-2.3.3.tar.gz

tar xvzf nagios-plugins-2.3.3.tar.gz

cd nagios-plugins-2.3.3.tar.gz
./configure --with-nagios-user=nagios --with-nagios-group=nagios
sudo make
sudo make install

sudo systemctl restart apache2
sudo systemctl start nagios.service

apt install ufw -y

sudo ufw allow 80

sudo ufw reload

sudo ufw enable
