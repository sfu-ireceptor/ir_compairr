# Change base image to a python image with g++ and make already installed
# FROM alpine:3.13
FROM python:3.9-slim
WORKDIR /opt/compairr

# iReceptor custom changes 
RUN apt-get update
# We need ZIP
RUN apt-get install -y zip
#RUN apk add --update-cache zip
# We need python (if the container isn't already a pyton container)
RUN apt-get install -y python3-pip python3-venv
#RUN apk add --update-cache python3-pip python3-venv

# We need to copy the iReceptor specific files into the container. There may
# not be any, but as a recipe we leave this in.
ENV IRECEPTOR_FOLDER="/opt/ireceptor"
COPY ./ireceptor $IRECEPTOR_FOLDER
# Set up our python environment. Between AIRR and anndata we get all subpackages
# we need, the key one being pandas.
RUN python3 -m venv $IRECEPTOR_FOLDER 
ENV PATH="$IRECEPTOR_FOLDER/bin:$PATH"
RUN pip3 install wheel
RUN pip3 install airr
RUN pip3 install anndata

COPY Makefile .
COPY src ./src
COPY test ./test
# Don't need to intall g++ and make any more
RUN make clean && make && make test && make install && make clean

ENTRYPOINT ["/usr/local/bin/compairr"]
CMD ["--help"]
