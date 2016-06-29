FROM owasp/zap2docker-stable

RUN pip install --upgrade beautifulsoup4 python-owasp-zap-v2.4 requests

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY uaa-auth.js .
COPY scan.py .

# https://github.com/zaproxy/zaproxy/blob/develop/src/org/zaproxy/zap/extension/api/OptionsParamApi.java
CMD nohup /zap/zap.sh -daemon -config api.disablekey=true -config api.incerrordetails=true & sleep 5 && python scan.py || tail -n 15 /zap/zap.log
