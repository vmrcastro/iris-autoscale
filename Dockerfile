#FROM containers.intersystems.com/intersystems/iris:2020.4.0.547.0
FROM store/intersystems/iris-community:2020.4.0.547.0

ARG ISC_PWD="sys"
ARG CI_DATABASE="/usr/irissys/mgr/autoscale"
ARG CI_NAMESPACE="AUTOSCALE"
ARG CI_DIRECTORY="/tmp/ci/"
ARG CI_PROJECT_DIRECTORY="/tmp/src/"
ARG CI_PRODUCTION="autoscale.Production"

COPY ./ci/* ${CI_DIRECTORY}
COPY ./src/* ${CI_PROJECT_DIRECTORY}

RUN iris start iris \
&& irissession iris -U%SYS < ${CI_DIRECTORY}load_ci.script \
&& iris stop iris quietly