OPTION=

help:
	@echo "OPTIONS:"
	@echo "sudo make install alpine"
	@echo "sudo make uninstall alpine"
	@echo "sudo make install arch"
	@echo "sudo make uninstall arch"
	@echo "sudo make install debian"
	@echo "sudo make uninstall debian"
	@echo "sudo make install ubuntu"
	@echo "sudo make uninstall ubuntu"

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
