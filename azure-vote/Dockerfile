FROM tiangolo/uwsgi-nginx-flask:python3.6
COPY requirements.txt .
RUN pip install -r requirements.txt
#redis
ADD /azure-vote /app
