# Jupyter Docker base for UCL Geography courses

This repository contains a simple way to create a Jupyter-based Python installation using Docker. It installs a base set of packages via conda from [`environment.yml`](environment.yml).


Docker
------

Use of a Docker container in this way has several advantages for course developers and maintainers::w

  * It has only minimal, well-documented setup  
  * It will run on all operating systems (though we should impose some reasonable conditions)
  * We can guarantee the same working environment for all strudents even when they use their own computers

Further:

  * It will automatically update to deployed containers (is latest tags is ued)
  * It can be deployed on cloud resources 
 
The docker file is created every time you push to the repository, and takes ~15 minutes to build. This is done automatically.

Jupyter lab
-----------

The teaching materials are used via jupyter lab (or jupyter notebooks) from any browser.

Saving work
-----------

The Docker container session is volatile, i.e. anything saved in the container will not be present the next time the container is run.

This has the advantage that it is difficult for the course materials to become corrupted, but it means that any work that needs to be persistent must be stored on a volume mounted in the Docker.

In this setup, we assume the need for two types of folders:

1. Persistent across sessions but not backed up

To achieve this, use:

    docker volume create uclgeog  

This will appear as:

    /home/jovyan/notebooks/data

in the container.

to create a volume called `uclgeog`.

2. Persistent and backed up 

For this, we assume that students will have their UCL OneDrive cloud storage attached to their local computer and that they will use this to backup work. 
It will have the additional advantage of linking the work on their local computer to wider UCL resources. The setup for this is done in the `Dockerfile` in the line `VOLUME "${ONEDRIVE}/${COURSENAME}"`.

We assume below that `OneDrive` is setup on the local computer as:

    ${HOME}/OneDrive - University College London

This will appear as:

    /home/jovyan/OneDrive - University College London

in the container. 

run command
-----------

To enable the disk correspondence, the docker command should be run with the following `-v local:container` options:

    docker run -v uclgeog:/home/jovyan/notebooks/data  -v "${HOME}/OneDrive - University College London/uclgeog:/home/jovyan/OneDrive - University College London/uclgeog" -p 8888:8888 -it jgomezdans/geog DOCKERCMD 

where `jgomezdans/geog` is the base `DOCKERNAME` (generally, that as stored on dockerhub.com) and `DOCKERCMD` is the command to run in the container (or leave blank for the default).


The first of these volume mappings:

    -v uclgeog:/home/jovyan/notebooks/data

creates the persistent disk `notebooks/data`. This can be made available to other Dockers but does not exist outside of that context.

The second mapping:

    -v "${HOME}/OneDrive - University College London/uclgeog:/home/jovyan/OneDrive - University College London/uclgeog"

is a bit of a mouthful only because of the long filename used for OneDrive. It also looks more complicated than it might because it has quotes to dael with the name having spaces.

The port option:

   -p 8888:8888

maps the (tcp/udp) port 8888 internally to external 8888, which you will notice when you run `jupyter lab` or `notebook` as this will specify a URL such as:

   http://127.0.0.1:8888/?token=6856cb877d7594ijfjo8988u8uukhkhueff

It matches the port exposed in the Dockerfile (8888 by default). Use [EXPOSE](https://docs.docker.com/engine/reference/builder/) to change. 

