ARG BASE=dellelce/uwsgi
FROM $BASE as build

LABEL maintainer="Antonio Dell'Elce"

ARG BASEDIR=/app/uwsgi
ARG PYTHON=${BASEDIR}/bin/python3

# commands are intended for busybox: if BASE is changed to non-BusyBox these may fail!
ARG GID=2001
ARG UID=2000
ARG GROUP=wagtail
ARG USERNAME=wagtail
ARG DATA=/app/data/${USERNAME}
ARG WTHOME=/home/${USERNAME}
ARG WTAPP=/app/${USERNAME}
ARG WTENV=${WTAPP}/wagtail-env

ENV ENV   $WTHOME/.profile

RUN addgroup -g "${GID}" "${GROUP}" && adduser -D -s /bin/sh \
    -g "wagtail user" \
    -G "${GROUP}" -u "${UID}" \
    "${USERNAME}" \
    && chown -R "${USERNAME}:${GROUP}" "${BASEDIR}" \
    && mkdir -p "${DATA}" && chown "${USERNAME}":"${GROUP}" "${DATA}" \
    && mkdir -p "${WTAPP}" && chown "${USERNAME}":"${GROUP}" "${WTAPP}" \
    && echo 'export PATH="'${PREFIX}'/bin:$PATH"' >> ${WTHOME}/.profile \
    && echo '. "${WTENV}/bin/activate"' >> ${WTHOME}/.profile 

WORKDIR "${WTHOME}"
COPY requirements.txt .

RUN    mkdir -p "${WTENV}" && cd "${WTENV}" \
    && ${PYTHON} -m venv . && . ${WTENV}/bin/activate \
    && pip install -U pip setuptools \
    && pip install -r ${WTHOME}/requirements.txt

USER ${USERNAME}

VOLUME ${DATA}
