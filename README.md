# SimGrid Dockerization project

A dockerized version of Simgrid to run SimGrid everywhere Docker is available. 

## Motivations, pros & cons
The aim of this project is to improve reproducibility of experiments based on simgrid. 

## Pros & Cons
How does this solution compare to other distribution means, such as ready to use linux distro packages or user installs?

Lots of pros:
* **Fully Controlled Environment**: in docker **all** all the software stack used for building simgrid is controlled. No hidden dependency.
* **Automated full build**: simgrid is automacally build from scratch. In docker, from scracth really means from scracth, including the OS install.
* **OS Agnostic**: Docker runs on Linux, MACOS and Windows. The same docker install can be used in any of those environmnt without change.
* **Customizable build**: Simply edit the Makefile to customize the build with your favourite SG build option enabled. 
* **Customizable Environment**: Adjust the docker execution machine to your needs (number of CPUs cores, size of memory)
* **Extensible**: The layered approach of Docker allows anyone to contribute and test additions to the project incrementally, without compromising existing layers.
* **Compact**: Docker images are incredibly compact and easy to download or transfer. Nothing to compare with traditional virtualization.

Some Cons:
* **Docker is still under development**: Docker is pretty stable but still suffers some bugs, either directly or transitively (eg. AUFS bugs). 
* **Virtualized environment**: Working with SG in a container is a constraint. Of course you can fit the container to your need and hook it to your working environment, but this is still a bit of a complication.

## Installation

1. [Install docker](https://docs.docker.com/engine/installation/) and check that it works (hello world)
2. Install gnumake on your OS if necessary
2. Clone the content of the directory where you found this README:
```shell
git clone https://github.com/odalle/simgrid-docker.git
```
3. Edit the config section of the Makefile according to your needs (or keep defaults). 
3. run `make` to see makefile targets.
4. For example, run `make run` to build all in one shot:
   * Create a new docker machine
   * Install linux distribution in machine
   * Install and compile simgrid
   * Open a shell in newly creatyed image


## TODO
* Untested yet in Linux and Windows environment.
* Deploy images on docker hub
* Dockerize some examples and SG tutos


