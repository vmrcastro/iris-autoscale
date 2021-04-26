FROM containers.intersystems.com/intersystems/iris:2020.4.0.547.0

ARG ISC_PWD="sys"
ARG CI_DATABASE="/usr/irissys/mgr/autoscale"
ARG CI_NAMESPACE="AUTOSCALE"
ARG CI_DIRECTORY="/tmp/ci/"
ARG CI_PROJECT_DIRECTORY="/tmp/src/"
#ARG CI_PROJECT_LIBS="/usr/irissys/dev/java/lib/kafka/"
ARG CI_PRODUCTION="autoscale.Production"
#ARG CI_POST_INSTALLER_CLASS="Util.PostInstaller"
#ARG CI_POST_INSTALLER_METHOD="Config"

COPY ./ci/* ${CI_DIRECTORY}
COPY ./src/* ${CI_PROJECT_DIRECTORY}
#COPY ./lib/* ${CI_PROJECT_LIBS}

RUN iris start iris \
&& irissession iris -U%SYS < ${CI_DIRECTORY}load_ci.script \
&& iris stop iris quietly