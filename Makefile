## SimGrid Dockerization project
## File: Makefile
## Author: O. Dalle
## Contact: olivier.dalle@unice.fr
## 
## Project Description:
## A Dockerized version of Simgrid to run SimGrid everywhere
## Docker is available in a reproducible way.
## 

###### START OF SETTINGS

# Change the docker machine name to whatever you'd like
MACHINE_NAME=simmachine

# Change the following according to desired version. Be careful to
# change BOTH at the same time
GIT_VERSION_TAG = v3_12
VERSION_ID = 312

# SG Build options (comma separated list)
# Some options are enabled by default, see SG documentation
# Our default: SG default + java enabled
SG_OPTIONS=java
# all available:
# SG_OPTIONS=compile_optimizations,java,debug,msg_deprecated,model-checking,compile_warnings,lib_static,maintainer_mode,tracing,smpi,mallocators,jedule,lua,gtnets,ns3,latency_bound_tracking,documentation
# WARNING: some options ar known to fail build (eg. latency_bound_tracking)
#          and others are not fully supported yet (ns3 and gtnets) or untested.

# VM size
VBOX_MEM_SIZE = 4096

# VM numbr of CPUs
VBOX_NUM_CPUS = 2

# DO NOT CHANGE THIS (unless you know what you're doing)
# New version 1.9.1 of boot2docker hangs on build while installing java
# (Bug found in AUFS under investigation). Docker 1.9.1 with older version
# of boot2docker works fine.
BOOT2DOCKER_URL= https://github.com/boot2docker/boot2docker/releases/download/v1.9.0/boot2docker.iso

###### END OF SETTINGS

.PHONY: default run java check_machine default_$(VERSION_ID) java_$(VERSION_ID) prebuild clean run_$(VERSION_ID) docker_env

-include .docker_env

help: check-machine
	@echo "This is a (gnu)Makefile. Main targets:"
	@echo "  make \n\t this help page"
	@echo "  make default\n\t same as default_$(VERSION_ID) (see below)"
	@echo "  make run\n\t same as run_$(VERSION_ID) (see below)"
	@echo "  make default_$(VERSION_ID)\n\t build docker image labeled 'simgrid:default-$(VERSION_ID)' with stable\n\t version $(GIT_VERSION_TAG)."
	@echo "  make run_$(VERSION_ID)\n\t run docker image simgrid:default-$(VERSION_ID) with host user homedir mounted in \n\t image /home/<user>. Convenient for devlopment or testing"
	@echo "  make clean\n\t destroy build artifacts (mainly git cloned sources)"
	@echo "  make machine\n\t create new docker machine provisioned for simgrid execution (memory \n\t extended by default to 4096 MB) and using workaround to avoid stall build."
	@echo "  make docker_env\n\t (re)set the docker machine env variables. Use in case you want to switch\n\t from one machine to another (pre-exsiting) one."

# Phony target so this cannot be triggered as a dependency
docker_env:
	docker-machine env $(MACHINE_NAME) | tr -d '"' > .docker_env

check-machine: .check_machine

.check_machine:
	@if [ "$(shell docker-machine active)" != "$(MACHINE_NAME)" ] ; then echo "WARNING:  WRONG DOCKER MACHINE SETTINGS.\n To start from scratch, run the following commands:\n make machine \n eval \"\$$(docker-machine env $(MACHINE_NAME))\"\n" ; fi
	touch .check_machine

machine .docker_env:
	docker-machine create --driver virtualbox --virtualbox-boot2docker-url=$(BOOT2DOCKER_URL) --virtualbox-memory $(VBOX_MEM_SIZE) --virtualbox-cpu-count $(VBOX_NUM_CPUS) $(MACHINE_NAME)
	docker-machine env $(MACHINE_NAME) | tr -d '"' > .docker_env

simgrid-$(GIT_VERSION_TAG):
	git clone -b $(GIT_VERSION_TAG) --single-branch git://scm.gforge.inria.fr/simgrid/simgrid.git $@

default: check_machine prebuild default_$(VERSION_ID)

.default_$(VERSION_ID): simgrid-$(GIT_VERSION_TAG) 
	docker build --build-arg ENABLED_BUILD_OPTIONS=$(SG_OPTIONS) --build-arg VERSION=$(GIT_VERSION_TAG) -t simgrid:default-$(VERSION_ID) .
	touch .default_$(VERSION_ID)

default_$(VERSION_ID): check_machine prebuild .default_$(VERSION_ID)

prebuild:  check_machine .prebuild

.prebuild: ./Dockerfile.prebuild
	docker build -f ./Dockerfile.prebuild -t simgrid:prebuild .
	touch .prebuild

clean_$(VERSION_ID): 
	rm -rf simgrid-$(GIT_VERSION_TAG) *~

clean:	clean_$(VERSION_ID)
	rm -f .prebuild .default_* *~ .check_machine *.pyc .docker_env

run: run_$(VERSION_ID)

run_$(VERSION_ID): check_machine default_$(VERSION_ID) 
	docker run -v $(HOME):/home/$(USER)  -w /home/$(USER) -it simgrid:default-$(VERSION_ID)

