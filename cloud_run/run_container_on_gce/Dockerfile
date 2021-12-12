FROM gcr.io/google.com/cloudsdktool/cloud-sdk:latest
ENV PYTHONUNBUFFERED True

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY .. ./

RUN pip3 install poetry
RUN poetry config virtualenvs.create false
RUN poetry install

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
