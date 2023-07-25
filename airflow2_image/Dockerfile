# NEW IMAGE FOR AIRFLOW2 

ARG AIRFLOW_VERSION=2.6.3
ARG PYTHON_VERSION_TO_USE=3.8
FROM apache/airflow:${AIRFLOW_VERSION}-python${PYTHON_VERSION_TO_USE}

LABEL maintainer="data-team@earnest.com"
ARG IMPALA_JAR_PATH=/opt/airflow
ARG AIRFLOW_USER=airflow

USER root

ENV DEBIAN_FRONTEND=noninteractive LANGUAGE=C.UTF-8 LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    LC_CTYPE=C.UTF-8 LC_MESSAGES=C.UTF-8

RUN apt-get update \
    && apt-get install -y -qq groff jq unzip \
    && apt-get install -y wget \
    && rm -rf /var/lib/apt/lists/*


ARG PACKAGES_BASE=" \
    python3-dev \
    wget \
    libpq5 \
    tar \
    git \
    gettext-base \
    jq \
    openjdk-11-jdk-headless \
"
RUN set -ex \
    # && echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list \
    && mkdir -p /usr/share/man/man1 \
    && apt-get update -yqq \
    # && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $PACKAGES_BASE \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    # && pip install --upgrade setuptools wheel \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base


# Install OpenJDK-8
# RUN apt-get update \
#     && apt-get install -y software-properties-common \
#     && add-apt-repository ppa:openjdk-r/ppa \
#     && apt-get -y update \
#     && apt-get install -y openjdk-8-jdk

# Set JAVA_HOME
# ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
# RUN export JAVA_HOME

# Add Impala JDBC Jar
RUN wget -nv --output-document /tmp/ImpalaJDBC.zip https://downloads.cloudera.com/connectors/ClouderaImpala_JDBC-2.6.17.1020.zip \
    && unzip /tmp/ImpalaJDBC.zip -d /tmp/ \
    && cp /tmp/ClouderaImpala_JDBC-2.6.17.1020/ClouderaImpalaJDBC41-2.6.17.1020/ImpalaJDBC41.jar $IMPALA_JAR_PATH/

# check all task related to this library and modify path



#WORKDIR ${AIRFLOW_USER_HOME} !check

USER airflow

ENV PATH "$PATH:/home/airflow/.local/bin"
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --upgrade setuptools wheel && \
    # pip uninstall -y numpy &&  \
    # pip install --no-cache-dir numpy==1.22.4 && \
    pip install --no-cache-dir -r /tmp/requirements.txt

COPY requirements.txt $IMPALA_JAR_PATH/requirements.txt


#check snowflake location to target the next step
# RUN echo $(pip show snowflake-sqlalchemy)
# This is a workaround due to a known issue with the snowflake namespace. Source: https://github.com/snowflakedb/snowflake-sqlalchemy/issues/112
RUN touch /home/airflow/.local/lib/python3.8/site-packages/snowflake/__init__.py

