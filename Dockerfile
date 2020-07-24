# Choose your desired base image
FROM jupyter/minimal-notebook:latest

# name your environment
ARG conda_env=uclgeog

# alternatively, you can comment out the lines above and uncomment those below
# if you'd prefer to use a YAML file present in the docker build context

# clean out
RUN rm -rf "${HOME}"/tmp/ && mkdir -p "${HOME}"/tmp/

# in case not passed, we derive this from which conda
# https://vsupalov.com/set-dynamic-environment-variable-during-docker-image-build/
RUN echo "$(dirname $(dirname $(which conda)))" > ${HOME}/tmp/conda_env.sh

COPY environment.yml "${HOME}"/tmp/
RUN CONDA_DIR=$(cat ${HOME}/tmp/conda_env.sh) && \
     cd "${HOME}"/tmp/ && \
     conda env create -p $CONDA_DIR/envs/$conda_env -f environment.yml && \
     conda activate $conda_env && \
     conda clean --all -f -y


# create Python 3.x environment and link it to jupyter
RUN CONDA_DIR=$(cat ${HOME}/tmp/conda_env.sh) && \
    $CONDA_DIR/envs/${conda_env}/bin/python -m ipykernel install --user --name=${conda_env} && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $(eval echo ~$NB_USER)

# any additional pip installs can be added by uncommenting the following line
# RUN $CONDA_DIR/envs/${conda_env}/bin/pip install

# prepend conda environment to path
# or put in bashrc
# not sure this is needed?
RUN CONDA_DIR=$(cat ${HOME}/tmp/conda_env.sh) && \
    USER_HOME = $(eval echo ~$NB_USER) && \
    echo "export PATH=\"$CONDA_DIR/envs/${conda_env}/bin:${PATH}\"" >> ${USER_HOME}/.bashrc
# rather than
# ENV PATH="$CONDA_DIR/envs/${conda_env}/bin:${PATH}"
# in case we dont know CONDA_DIR

# if you want this environment to be the default one, uncomment the following line:
ENV CONDA_DEFAULT_ENV=${conda_env}

RUN PATH="$CONDA_DIR/envs/${conda_env}/bin:${PATH}" && \
    python -m pip install jupyterthemes && \
    python -m pip install --upgrade jupyterthemes && \
    python -m pip install jupyter_contrib_nbextensions
    
RUN PATH="$CONDA_DIR/envs/${conda_env}/bin:${PATH}" && \
    jupyter contrib nbextension install --user
    
# enable the Nbextensions
RUN PATH="$CONDA_DIR/envs/${conda_env}/bin:${PATH}" && \
    jupyter nbextension enable contrib_nbextensions_help_item/main && \
    jupyter nbextension enable autosavetime/main && \
    jupyter nbextension enable codefolding/main && \
    jupyter nbextension enable code_font_size/code_font_size && \
    jupyter nbextension enable code_prettify/code_prettify && \
    jupyter nbextension enable collapsible_headings/main && \
    jupyter nbextension enable comment-uncomment/main && \
    jupyter nbextension enable equation-numbering/main
#RUN jupyter nbextension enable execute_time/ExecuteTime 
RUN PATH="$CONDA_DIR/envs/${conda_env}/bin:${PATH}" && \
    jupyter nbextension enable gist_it/main && \
    jupyter nbextension enable hide_input/main && \
    jupyter nbextension enable spellchecker/main && \
    jupyter nbextension enable toc2/main && \
    jupyter nbextension enable toggle_all_line_numbers/main

ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV JUPYTER_ENABLE_LAB=yes
RUN PATH="$CONDA_DIR/envs/${conda_env}/bin:${PATH}" && \
    jupyter labextension install nbdime-jupyterlab --no-build && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter labextension install jupyter-matplotlib --no-build && \
    jupyter labextension install @jupyterlab/debugger --no-build && \
    jupyter labextension install jupyter-leaflet --no-build && \
    jupyter lab build && \
        jupyter lab clean && \
        jlpm cache clean && \
        npm cache clean --force && \
        rm -rf $HOME/.node-gyp && \
        rm -rf $HOME/.local && \
    fix-permissions $CONDA_DIR $HOME

RUN mkdir -p $HOME/notebooks
COPY notebooks/* $HOME/notebooks/
RUN jupyter trust notebooks/*ipynb 
