ARG IMAGE_NAME=debian
ARG IMAGE_TAG=bookworm-slim
ARG ARCHITECTURE=amd64

FROM ${ARCHITECTURE}/${IMAGE_NAME}:${IMAGE_TAG}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    curl \
    libssl3 \
    procps \
    nano \
    unzip \
    jq \
    dos2unix \
    default-mysql-client && \
    apt-get clean

    ####################################
    # For default remote configuration #
    ####################################

#RUN curl -s "https://gitlab.com/api/v4/projects/34553745/releases/" \
#  | jq -r '.[0].assets.links[] | select(.name == "server-linux-x64") | .direct_asset_url' \
#  | xargs -n1 curl -L -o server-linux-x64.zip

#RUN unzip server-linux-x64.zip && \
#    mv server-linux-x64/* . && \
#    rm -rf server-linux-x64 server-linux-x64.zip


WORKDIR /app

COPY g2o_server/ .
COPY ./RP ./gamemodes/RP

RUN find . -type f -print0 | xargs -0 dos2unix

RUN chmod +x G2O_Server.x64

CMD ["./G2O_Server.x64"]
