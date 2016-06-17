FROM owasp/zap2docker-stable

RUN pip install --upgrade beautifulsoup4 requests zapcli

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY scan.py .
COPY uaa-auth.js .

# https://github.com/zaproxy/zaproxy/blob/develop/src/org/zaproxy/zap/extension/api/OptionsParamApi.java
CMD zap-cli start --start-options '-config api.disablekey=true -config api.incerrordetails=true' && python scan.py || tail -n 25 /zap/zap.log
