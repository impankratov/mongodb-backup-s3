FROM alpine:edge

RUN apk add --no-cache --update bash mongodb-tools python py-pip
RUN pip install awscli
RUN apk --purge -v del py-pip

ENV CRON_TIME="0 1 * * *" \
  TZ=US/Eastern \
  CRON_TZ=US/Eastern

ADD run.sh /run.sh
CMD /run.sh
