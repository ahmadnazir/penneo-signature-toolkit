FROM alpine:3.9 

RUN	apk add bash
RUN apk add xmlstarlet
RUN apk add openssl
RUN apk add xmlsec
RUN apk add poppler-utils
RUN apk add libxml2-utils

COPY toolkit.sh /usr/local/bin/toolkit.sh
RUN ["chmod", "a+x", "/usr/local/bin/toolkit.sh"]

ENTRYPOINT ["/usr/local/bin/toolkit.sh"]