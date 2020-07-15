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
# RUN $CONDA_DIR/envs/${conda_env}/bin/pip install

# prepend conda environment to path
ENV PATH $CONDA_DIR/envs/${conda_env}/bin:$PATH

# if you want this environment to be the default one, uncomment the following line:
ENV CONDA_DEFAULT_ENV ${conda_env}

RUN python -m pip install jupyterthemes
RUN python -m pip install --upgrade jupyterthemes
RUN python -m pip install jupyter_contrib_nbextensions
RUN jupyter contrib nbextension install --user
# enable the Nbextensions
RUN jupyter nbextension enable contrib_nbextensions_help_item/main
RUN jupyter nbextension enable autosavetime/main
RUN jupyter nbextension enable codefolding/main
RUN jupyter nbextension enable code_font_size/code_font_size
RUN jupyter nbextension enable code_prettify/code_prettify
RUN jupyter nbextension enable collapsible_headings/main
RUN jupyter nbextension enable comment-uncomment/main
RUN jupyter nbextension enable equation-numbering/main
RUN jupyter nbextension enable execute_time/ExecuteTime 
RUN jupyter nbextension enable gist_it/main 
RUN jupyter nbextension enable hide_input/main 
RUN jupyter nbextension enable spellchecker/main
RUN jupyter nbextension enable toc2/main
RUN jupyter nbextension enable toggle_all_line_numbers/main

ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN jupyter labextension install nbdime-jupyterlab --no-build && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter labextension install jupyterlab_bokeh --no-build && \
    jupyter labextension install bqplot --no-build && \
    jupyter labextension install @jupyterlab/vega3-extension --no-build && \
    jupyter labextension install @jupyterlab/git --no-build && \
    jupyter labextension install @jupyterlab/hub-extension --no-build && \
    jupyter labextension install jupyterlab_tensorboard --no-build && \
    jupyter labextension install jupyterlab-kernelspy --no-build && \
    jupyter labextension install @jupyterlab/plotly-extension --no-build && \
    jupyter labextension install jupyterlab-chart-editor --no-build && \
    jupyter labextension install plotlywidget --no-build && \
    jupyter labextension install @jupyterlab/latex --no-build && \
    jupyter labextension install jupyter-matplotlib --no-build && \
    jupyter labextension install jupyterlab-drawio --no-build && \
    jupyter labextension install jupyter-leaflet --no-build && \
    jupyter labextension install qgrid --no-build && \
    jupyter lab build && \
        jupyter lab clean && \
        jlpm cache clean && \
        npm cache clean --force && \
        rm -rf $HOME/.node-gyp && \
        rm -rf $HOME/.local && \
    fix-permissions $CONDA_DIR $HOME

USER $NB_USER

# Trust notebooks in repo
RUN jupyter trust *.ipynb
RUN jupyter trust notebooks/*.ipynb


