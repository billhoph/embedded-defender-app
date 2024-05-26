
FROM tiangolo/uwsgi-nginx-flask:python3.6

RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt --no-cache-dir
ADD . /code/

# ssh
ENV SSH_PASSWD "root:Docker!"
RUN apt-get update \
        && apt-get install -y --no-install-recommends dialog \
        && apt-get update \
	&& apt-get install ca-certificates -y \
	&& apt-get install -y --no-install-recommends openssh-server \
	&& echo "$SSH_PASSWD" | chpasswd 

COPY sshd_config /etc/ssh/
COPY init.sh /usr/local/bin/
	
RUN chmod u+x /usr/local/bin/init.sh
EXPOSE 8000 2222
#CMD ["python", "/code/manage.py", "runserver", "0.0.0.0:8000"]
ENTRYPOINT ["init.sh"]

# Twistlock Container Defender - app embedded
ADD twistlock_defender_app_embedded.tar.gz /tmp
ENV DEFENDER_TYPE="appEmbedded"
ENV DEFENDER_APP_ID="demo-app"
ENV FILESYSTEM_MONITORING="false"
ENV WS_ADDRESS="wss://us-west1.cloud.twistlock.com:443"
ENV DATA_FOLDER="/tmp"
ENV INSTALL_BUNDLE="eyJzZWNyZXRzIjp7InNlcnZpY2UtcGFyYW1ldGVyIjoiMlQ1dnJLUTJaVzlqeGdIbmlXVFB5SjJoekk5SjlTaVAzbUZXaEdTVU10U3FLZ0hTU1FrWnZyUnlaWmprS0E2YnVTTlBVT1FJK1lsQzJHelR2STNXRlE9PSJ9LCJnbG9iYWxQcm94eU9wdCI6eyJodHRwUHJveHkiOiIiLCJub1Byb3h5IjoiIiwiY2EiOiIiLCJ1c2VyIjoiIiwicGFzc3dvcmQiOnsiZW5jcnlwdGVkIjoiIn19LCJjdXN0b21lcklEIjoidXMtNC0xNjEwNTcyMDgiLCJhcGlLZXkiOiJmZTMyTStEOXh5b0ZNVFA4K0MvcHJud1VDaEJZOFh1M1FGbG5XSVhjU3dhTnhUby9IQms2TUlhNjlxdno4SUpIMXhpbFhQbWpFSkU1MEU2WGhBYjJ6Zz09IiwibWljcm9zZWdDb21wYXRpYmxlIjpmYWxzZSwiaW1hZ2VTY2FuSUQiOiJlNmJmZGMzMi0xZTYyLTc1YzQtOWMwNy0zNGNjZTE3OWFlODQifQ=="
ENV FIPS_ENABLED="false"
ENTRYPOINT ["/tmp/defender", "app-embedded", "init.sh"]
