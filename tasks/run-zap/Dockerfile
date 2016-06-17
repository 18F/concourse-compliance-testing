FROM owasp/zap2docker-stable

RUN pip install --upgrade zapcli

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY scan.py .

CMD zap-cli start --start-options '-config api.disablekey=true' && python scan.py
