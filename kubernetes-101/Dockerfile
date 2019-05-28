FROM  python:3

ENV PYTHONUNBUFFERED 1
ENV APPLICATION_ROOT /app/

RUN mkdir $APPLICATION_ROOT
WORKDIR $APPLICATION_ROOT

COPY requirements.txt $APPLICATION_ROOT
RUN pip install -r requirements.txt

COPY . $APPLICATION_ROOT

EXPOSE 8000
CMD ["python", "seakube/manage.py", "runserver", "0.0.0.0:8000"]
