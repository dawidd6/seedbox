OPTION=

help:
	@echo "OPTIONS:"
	@echo "make install alpine"
	@echo "make uninstall alpine"
	@echo "make install arch"
	@echo "make uninstall arch"
	@echo "make install debian"
	@echo "make uninstall debian"
	@echo "make install ubuntu"
	@echo "make uninstall ubuntu"

install:
	$(eval OPTION="install")

uninstall:
	$(eval OPTION="uninstall")

alpine:
	./alpine.sh $(OPTION)

arch:
	./arch.sh $(OPTION)

debian:
	./ubuntu-debian.sh $(OPTION)

ubuntu:
	./ubuntu-debian.sh $(OPTION)

.PHONY: install uninstall alpine arch debian ubuntu
