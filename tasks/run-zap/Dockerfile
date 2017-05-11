FROM owasp/zap2docker-stable

USER root
RUN apt-get update && apt-get install -q -y --fix-missing jq
RUN pip install --upgrade pip && pip install --upgrade zapcli
USER zap
