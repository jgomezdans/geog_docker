# Choose your desired base image
FROM jupyter/minimal-notebook:latest

# name your environment and choose python 3.x version
ARG conda_env=uclgeog
ARG py_ver=3.7

# you can add additional libraries you want conda to install by listing them below the first line and ending with "&& \"
# RUN conda create --quiet --yes -p $CONDA_DIR/envs/$conda_env python=$py_ver ipython ipykernel && \
#    conda clean --all -f -y

# alternatively, you can comment out the lines above and uncomment those below
# if you'd prefer to use a YAML file present in the docker build context

COPY environment.yml /home/$NB_USER/tmp/
RUN cd /home/$NB_USER/tmp/ && \
     conda env create -p $CONDA_DIR/envs/$conda_env -f environment.yml && \
     conda clean --all -f -y


# create Python 3.x environment and link it to jupyter
RUN $CONDA_DIR/envs/${conda_env}/bin/python -m ipykernel install --user --name=${conda_env} && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# any additional pip installs can be added by uncommenting the following line
RUN $CONDA_DIR/envs/${conda_env}/bin/pip install nbgrader

# prepend conda environment to path
ENV PATH $CONDA_DIR/envs/${conda_env}/bin:$PATH

# if you want this environment to be the default one, uncomment the following line:
ENV CONDA_DEFAULT_ENV ${conda_env}

USER root

# RUN jupyter serverextension enable --py jupyter_http_over_ws

RUN jupyter contrib nbextension install --user
RUN jupyter nbextension enable --py widgetsnbextension
RUN jupyter nbextension enable rubberband/main
RUN jupyter nbextension enable exercise2/main
RUN jupyter nbextension enable collapsible_headings/main



# Add jupyterlab extensions here (some might need installing via conda/pip)

RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install jupyter-leaflet

USER $NB_USER

# Trust notebooks in repo
RUN jupyter trust *.ipynb
RUN jupyter trust notebooks/*.ipynb


