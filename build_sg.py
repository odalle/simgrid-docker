#!/usr/bin/env python
##  -*- encoding: utf-8 -*-
## SimGrid Dockerization project
## File: build_sg.py
## Author: O. Dalle
## Contact: olivier.dalle@unice.fr
## 
## Project Description:
## A Dockerized version of Simgrid to run SimGrid everywhere
## Docker is available in a reproducible way.
"""
File Description:
   A simple python wrapper script to run the simgrid build with
   the limited instruction set of the docker build file.
   This file is part of the docker context of image: it is
   copied and executed within the docker container during the
   image build.
"""


import sys,os
from subprocess import PIPE, Popen

valid_options=[ 'compile_optimizations',
                'java',
                'debug',
                'msg_deprecated',
                'model-checking',
                'compile_warnings',
                'lib_static',
                'maintainer_mode',
                'tracing',
                'smpi',
                'mallocators',
                'jedule',
                'lua',
                'gtnets',
                'ns3',
                'latency_bound_tracking',
                'documentation' ]

def read_env(key,default=''):
    val = default
    try:
        val = os.environ[key]
    except KeyError:
        pass
    if len(val) == 0: return default
    return val

def parse_env_options(option_list):
    str=""
    if len(option_list) == 0:
        return str
    enabled_options = option_list.split(',')
    for option in enabled_options:
        if option in valid_options:
            str += "-Denable_"+option+"=on "
        else:
            print >> sys.stderr, 'Unknown Option:'+option
            raise KeyError
    return str
        
def run_command(command):
    print "RUNNING: "+command
    proc = Popen(command, shell=True)
    output, err = proc.communicate()
    print output
    print >> sys.stderr, err


def execute():   
    sg_version = read_env('SG_VERSION','(latest)')
    # convert git version tag vX_XX to version id XXX
    #if sg_version[0] == 'v': sg_version = sg_version[1:]
    #sg_version = sg_version.replace("_","")
    
    env_options = read_env('ENABLED_BUILD_OPTIONS')
    build_flags = parse_env_options(env_options)
    build_root = read_env('BUILD_ROOT','/opt/')
    target_dir = read_env('TARGET_DIR','/opt/simgrid')

    if sg_version == '(latest)':
        clone_dir = 'simgrid-latest'
        version_spec = ''
    else:
        clone_dir = 'simgrid-'+sg_version
        version_spec= '-b '+sg_version+' '

    build_path = build_root+clone_dir

    ## Build is broken in 3 steps: prepare, clone and build
    PREPARE_COMMAND = "rm -f %s && cd %s && ln -s %s %s"%(target_dir,build_root,clone_dir,target_dir)
    run_command(PREPARE_COMMAND)

    ## The dockerfile is normally designed work with the sources
    ## cloned in the context prior to running this script which
    ## would result in the source being already copied in the
    ## container running this script. Therefore we only clone sources
    ## from within the container when something goes wrong in the
    ## context and we end up missing them here.
    if not os.path.isdir(build_path):
        CLONE_COMMAND = "cd %s && git clone %s --single-branch git://scm.gforge.inria.fr/simgrid/simgrid.git %s"%(build_root,version_spec,clone_dir)
        run_command(CLONE_COMMAND)

    BUILD_COMMAND = "cd %s && cmake -DBUILD_SHARED_LIBS=OFF %s -DCMAKE_INSTALL_PREFIX=%s"%(target_dir,build_flags,target_dir)
    run_command(BUILD_COMMAND)

if __name__ == "__main__":
    execute()
else:
    help(__name__)
