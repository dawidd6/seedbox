OPTION=

install:
	$(OPTION)=install

uninstall:
	$(OPTION)=uninstall

alpine:
	./alpine.sh $(OPTION)

arch:
	./arch.sh $(OPTION)

debian:
	./ubuntu-debian.sh $(OPTION)

ubuntu:
	./ubuntu-debian.sh $(OPTION)

.PHONY: install uninstall alpine arch debian ubuntu
