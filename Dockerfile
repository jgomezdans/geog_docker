# Choose your desired base image
FROM jupyter/minimal-notebook:latest

# name your environment
ARG CONDA_ENV=uclgeog

# alternatively, you can comment out the lines above and uncomment those below
# if you'd prefer to use a YAML file present in the docker build context

COPY environment.yml "/home/${NB_USER}/tmp/"
RUN cd /home/$NB_USER/tmp/ && \
     conda env create -p "${CONDA_DIR}/envs/${CONDA_ENV}/" -f environment.yml && \
     conda clean --all -f -y


# create Python 3.x environment and link it to jupyter
RUN "${CONDA_DIR}/envs/${CONDA_ENV}/bin/python" -m ipykernel install --user --name="${CONDA_ENV}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# any additional pip installs can be added by uncommenting the following line
# RUN $CONDA_DIR/envs/${CONDA_ENV}/bin/pip install

# prepend conda environment to path
ENV PATH "$CONDA_DIR/envs/${CONDA_ENV}/bin/":$PATH

# if you want this environment to be the default one, uncomment the following line:
ENV CONDA_DEFAULT_ENV "${CONDA_ENV}"

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
ENV JUPYTER_ENABLE_LAB=yes
RUN jupyter labextension install nbdime-jupyterlab --no-build && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter labextension install jupyter-matplotlib --no-build && \
    jupyter labextension install @jupyterlab/debugger --no-build && \
    jupyter labextension install jupyter-leaflet --no-build && \
    jupyter lab build && \
        jupyter lab clean && \
        jlpm cache clean && \
        npm cache clean --force && \
        rm -rf "${HOME}/.node-gyp/" && \
        rm -rf "${HOME}/.local/" && \
    fix-permissions "${CONDA_DIR}" "${HOME}"


# READ-ONLY notebooks
RUN mkdir -p "notebooks"
COPY notebooks/* notebooks/
RUN jupyter trust notebooks/*ipynb

# Dont want it called work as well as ONED
# to avoid confusion. But dont remove if its got anything in it.
RUN rmdir work

# generate non-volative disk
RUN mkdir -p notebooks/data && fix-permissions notebooks/data

###########################################
# This might be repeated in derived dockers
ENV COURSENAME ${CONDA_ENV}
# sort local directories
# local mount point for OneDrive: it should reside in home
ARG ONED='OneDrive - University College London'
ENV ONEDRIVE "${HOME}/${ONED}"
# for mounting: in the home directory
RUN mkdir -p "${ONEDRIVE}/${COURSENAME}"
VOLUME "${ONEDRIVE}/${COURSENAME}"

# make a link in case base of jupyter in notebooks
#RUN mkdir -p "notebooks/${ONED}"
RUN ln -s "${ONEDRIVE}/${COURSENAME}" "notebooks/${COURSENAME}"
RUN mv notebooks/README.md /tmp && sed < /tmp/README.md 's/__COURSE__/'"${COURSENAME}"'/g' > notebooks/README.md

# clean up
#RUN rm -rf tmp
