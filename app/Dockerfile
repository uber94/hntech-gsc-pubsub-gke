FROM python:3.10.2
WORKDIR /usr/src/app

RUN pip3 install google-cloud-pubsub==2.14.0
RUN pip3 install google-cloud-storage==2.7.0

COPY pubsubapp.py /usr/src/app/pubsubapp.py

CMD ["python", "./pubsubapp.py"]
