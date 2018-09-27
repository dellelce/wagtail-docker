ARG BASE=dellelce/uwsgi
FROM $BASE as build

LABEL maintainer="Antonio Dell'Elce"

ARG PREFIX=/app/uwsgi
ARG PYTHON=${PREFIX}/bin/python3
ENV INSTALLDIR  ${PREFIX}

# commands are intended for busybox: if BASE is changed to non-BusyBox these may fail!
ARG GID=2001
ARG UID=2000
ARG GROUP=wagtail
ARG USERNAME=wagtail
ARG DATA=/app/data/${USERNAME}
ARG WTHOME=/home/${USERNAME}
ARG WTENV=${WTHOME}/wagtail-env

ENV ENV   $WTHOME/.profile

RUN addgroup -g "${GID}" "${GROUP}" && adduser -D -s /bin/sh \
    -g "wagtail user" \
    -G "${GROUP}" -u "${UID}" \
    "${USERNAME}" \
    && chown -R "${USERNAME}:${GROUP}" "${PREFIX}" \
    && mkdir -p "${DATA}" && chown "${USERNAME}":"${GROUP}" "${DATA}" \
    && echo 'export PATH="'${PREFIX}'/bin:$PATH"' >> ${WTHOME}/.profile \
    && echo '. "${WTENV}/bin/activate"' >> ${WTHOME}/.profile 

WORKDIR "${WTHOME}"
COPY requirements.txt .

RUN  . ${WTENV}/bin/activate \
    && mkdir -p "${WTENV}" && cd "${WTENV}" \
    && ${PYTHON} -m venv . && . ${WTENV}/bin/activate \
    && pip install -U pip setuptools \
    && pip install -r ${WTHOME}/requirements.txt

USER ${USERNAME}

VOLUME ${DATA}
