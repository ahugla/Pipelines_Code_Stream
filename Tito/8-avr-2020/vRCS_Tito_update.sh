#
#
#   UPDATE Tito version et reconfigure le serveur web:
#         - configure pour le distributed tracing  (prerequis python doit etre present sur le serveur)
#		  - reconfigure wavefront avec les nouveaux inputs
#
#	Date :  8/04/2020 
#	Owner:  Alexandre Hugla
#

systemctl stop httpd

cd /tmp
rm -rf /var/www/html

git clone https://github.com/vmeoc/Tito.git  /var/www/html           

cd /var/www/html 
git checkout $Tito_Version



# Si le fichier existe, rendre executable le script Python de Tracing
if [ -e /var/www/html/sendTraces.py ]
then
    chmod 777 /var/www/html/sendTraces.py
fi


# Si pas deja fait, config httpd.conf pour autoriser le lancement de scripts
is_present=`more /etc/httpd/conf/httpd.conf | grep "AddHandler cgi-script .cgi .pl .py" | wc -l`
if [ $is_present -eq "0" ]
then
	sed -i '/<Directory "\/var\/www\/html">/a AddHandler cgi-script .cgi .pl .py' /etc/httpd/conf/httpd.conf
	sed -i '/<Directory "\/var\/www\/html">/a Options +ExecCGI' /etc/httpd/conf/httpd.conf
fi


# Update Wavefront config (au cas ou l'url/port changeraient)
sed -i '/PROXY_NAME/d' /etc/sysconfig/httpd
sed -i '/PROXY_PORT/d' /etc/sysconfig/httpd
echo "PROXY_NAME=$PROXY_NAME" >> /etc/sysconfig/httpd
echo "PROXY_PORT=$PROXY_PORT" >> /etc/sysconfig/httpd


systemctl start httpd
