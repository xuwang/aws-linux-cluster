CWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CA_CERT := $(CWD)/rootCA.pem
SITE_CERT := $(CWD)/site.pem

all: | $(CA_CERT) $(SITE_CERT)

clean:
	rm -f *.pem *.csr *.srl *.key *.crt

ca: | $(CA_CERT)

site: | $(SITE_CERT)

$(CA_CERT): 
	echo "creating rootCA-key.pem and rootCA.pem ..."
	openssl req -x509 -new -nodes -days 9999 -config rootCA.cnf -out rootCA.pem
	chmod 600 *.pem

$(SITE_CERT): | $(CA_CERT)
	echo "creating the site-key.pem and site.csr...."
	openssl req -new -out site.csr -config site.cnf
	echo "signing site.csr..."
	openssl x509 -req -days 9999 -in site.csr \
		-CA rootCA.pem -CAkey rootCA-key.pem -CAcreateserial \
		-extensions v3_req -out site.pem -extfile site.cnf
	echo "site.pem is generated:"
	openssl x509 -text -noout -in site.pem
	chmod 600 *.pem

.PHONY: all clean ca site etcd $(CA_CERT) $(SITE_CERT)
