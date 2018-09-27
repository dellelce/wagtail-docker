ARG BASE=dellelce/uwsgi
FROM $BASE as build

LABEL maintainer="Antonio Dell'Elce"

ARG BASEDIR=/app/uwsgi
ARG PYTHON=${BASEDIR}/bin/python3

# Extra mess for pillow
RUN apk add zlib-dev jpeg-dev gcc binutils libc-dev

ARG WTAPP=/app/${USERNAME}
ARG WTENV=${WTAPP}/wagtail-env

COPY requirements.txt /tmp 

RUN    mkdir -p "${WTENV}" && cd "${WTENV}" \
    && ${PYTHON} -m venv . && . ${WTENV}/bin/activate \
    && pip install -U pip setuptools \
    && pip install -r /tmp/requirements.txt

# Final stage
ARG BASE=dellelce/uwsgi
FROM $BASE as final

ARG BASEDIR=/app/uwsgi
ARG GID=2001
ARG UID=2000
ARG GROUP=wagtail
ARG USERNAME=wagtail
ARG DATA=/app/data/${USERNAME}
ARG WTHOME=/home/${USERNAME}

VOLUME ${DATA}

# commands are intended for busybox: if BASE is changed to non-BusyBox these may fail!
ENV ENV   $WTHOME/.profile
RUN addgroup -g "${GID}" "${GROUP}" && adduser -D -s /bin/sh -g "wagtail user" \
    -G "${GROUP}" -u "${UID}" "${USERNAME}"

RUN chown -R "${USERNAME}:${GROUP}" "${BASEDIR}" \
    && mkdir -p "${DATA}" && chown "${USERNAME}":"${GROUP}" "${DATA}" \
    && mkdir -p "${WTAPP}" && chown "${USERNAME}":"${GROUP}" "${WTAPP}" \
    && echo 'export PATH="'${PREFIX}'/bin:$PATH"' >> ${WTHOME}/.profile \
    && echo '. "${WTENV}/bin/activate"' >> ${WTHOME}/.profile 

USER ${USERNAME}

COPY --from=build ${WTAPP} ${WTAPP}
