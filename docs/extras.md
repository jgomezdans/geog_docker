# Step by step instructions to use this repository

## Get a GitHub account

You probably have one, but if not... Go ahead and get one. 

## Create a copy of our *template* repository

Go to the [github page](https://github.com/UCL-EO/geog_docker) of this repository, and click on the **Use this template** button. This will basically create a new repository under your username, with all the files and stuff that we've put together.

## If you can't create from the template, fork the repository 

Forking is only really recommended if you want to quickly fixe something and feed it back to the main repository, but can also work as a way to publish your own course.

Go to the [github page](https://github.com/UCL-EO/geog_docker) of this repository, and click on the **Fork** icon.

![Fork button](fork.png)

## Setting up the credentials for Docker builds

### Get a Docker account

Go to [Docker Hub](https://hub.docker.com/) and get yourself an account.

You'll need the username and password to allow GitHub to upload (i.e. *push*) your images to docker hub.

### Linking Docker hub and github

We need to connect the hubs. On the forked repository, go to the **"Settings"** tab, and then on to the tab that reads **"Secrets"**

![Secrets tab](secrets.png)


You need to create two variables `DOCKERHUB_USERNAME` and `DOCKERHUB_PASSWORD`, which will store your username and password in [hub.docker.com](https://hub.docker.com/). 

![Secret variables](secrets2.png)

## Modifying the image itself

### Clone your forked repository

You can do this on the command line using

```
   git clone  git@github.com:jgomezdans/geog_docker.git
```

(change that github address to that of your repository). You can then edit the files locally.

### Changing packages

You can edit the `Docker/environment.yml` file to change the packages you want installed.

You may also want to change the names of the Docker images to reflect your course name (e.g. `geog0666`). To do this, you need to change the image name in a couple of places:

- `.github/workflows/docker-run.yml` Change all the occurrences of `uclgeog` to your course name (e.g. `geog0666`). 
- `.github/workflows/docker-image.yml` Change all the occurrences of `uclgeog` to your course name (e.g. `geog0666`).


### Adding content

You can also add notebooks by dropping them in the `notebooks` folder. They will be copied to the Docker image. You may also want to add Python code files here, although it may be better to pack this as individual Python packages that can be pip-installed.

You can just copy the files to the folder, and then add them to the repository using e.g.

```
git add notebooks/*.ipynb
```

### Test locally

You can use the local dockerfile to build the image locally, and test that it meets your requirements. You may want to peruse the [Docker documentation](https://docs.docker.com/get-started/).

### Commit your changes

Before uploading your changes to github, we have to *commit* them.

```
git commit -a
```

This will launch a text editor to allow you to document your changes

### Push to github

```
git push origin master
```

This will upload your commited changes to github, and will start building a docker file.

### Check the build was succesful

Go to github, and check the "Actions" tab. There you can see that your image is building (it takes a while, some 15-20 minutes), and whether it's succeeded or not. If it doesn't succeed, you can see what part of the process failed.

## Making a release

Once you're happy with things, you can make a release, and share the Docker image with the rest of the world. On the github page, click on Releases and make a new release (you can tag it with a version number e.g. `v1.0` or something like that), and write some blurb. Once that is done, the system will build the image and push it to Docker hub to be used by everyone.



