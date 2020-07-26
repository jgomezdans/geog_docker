<p><img src="https://static.ucl.ac.uk/indigo/images/ucl-logo.svg" align="right" />
</p>
[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/jgomezdans/geog_docker/blob/master/LICENSE?style=for-the-badge)
[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/jgomezdans/uclgeog)](https://hub.docker.com/r/jgomezdans/uclgeog/tags)
[![Read the Docs](https://img.shields.io/readthedocs/geog-docker?style=for-the-badge)](https://geog-docker.readthedocs.io/en/latest/)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/jgomezdans/uclgeog?style=for-the-badge)](https://hub.docker.com/r/jgomezdans/uclgeog/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jgomezdans/uclgeog?style=for-the-badge)](https://hub.docker.com/r/jgomezdans/uclgeog/tags)
[![GitHub issues](https://img.shields.io/github/issues-raw/jgomezdans/geog_docker?style=for-the-badge)](https://github.com/jgomezdans/geog_docker/issues)

# University College London Department of Geography Base Docker image

This repository contains a basic teaching Docker image using Python via Jupyter notebooks. This repository is designed to be modified and tailored to suit different courses (by virtue of e.g. modifying the installed Python packages).

## Design concepts

We assume that:
1. You want to use a fairly recent version of Python (3.7 is current and well-supported in terms of packages). 
2. We also assume that all packages can be installed either as [conda](http://docs.conda.io) or [pip](https://pypi.org/project/pip/) packages. 
3. You have both a [Github](https://github.com) and a [Docker hub](https://hub.docker.com) account.
4. Most of the teaching material includes notebooks.
5. You have nerves of steel, laser-focus and substantial amounts of patience.

## Online documentation

You can also peruse the [online documentation](https://geog-docker.readthedocs.io/).
