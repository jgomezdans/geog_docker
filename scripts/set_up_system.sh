#!/bin/bash
  
# get Dockerfile and pull info for postBuild etc
# to inherit from https://raw.githubusercontent.com/jgomezdans/geog_docker/master/

here=$(pwd)
cmddir=$(dirname $0)
base='https://raw.githubusercontent.com/jgomezdans/geog_docker/master/'
NB_USER="${USER}"
SUDO=''
DEBUG=0

THIS=`basename $0`
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -d|--debug)
    DEBUG=1
    shift # past argument
    ;;
    -s|--sudo)
    SUDO=sudo
    shift # past argument
    ;;
    -n|--no_sudo)
    SUDO=''
    shift # past argument
    ;;
    -h|--help)
    echo "$THIS [-d|--debug] [-s|--sudo] | [-n|-no_sudo]']"
    shift # past argument
    exit
esac
done
set -- "${POSITIONAL[@]}"


here=$(pwd)
# generate tmp dir to work in
tmp="${HOME}/tmp.$$"
rm -rf "${tmp}"
mkdir -p "${tmp}"
if [ $? -eq 0 ]; then
   pwd
   echo 'tmp working directory made'
else
   echo 'tmp working directory failed'
   pwd
   exit 1
fi


cd "${tmp}"

# carry the python filter with us
cat << EOF > filter.py
#!/usr/bin/env python
import os
import subprocess

# for miniconda packages

sysname = os.uname().sysname
if sysname == 'Darwin':
    sysname = 'MacOSX'

cmd = "conda info | grep 'base environment' | cut -d ':' -f 2 | awk '{print $1}' | sed 's/(writable)//g'"
cdir=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE)
if cdir.returncode == 0:
    os.environ["CONDA_DIR"]=cdir.stdout.decode("utf-8").strip()

CONDA_DIR=os.environ["CONDA_DIR"]

l=[j for j in [i.split('#')[0].split() for i in open('Docker/Dockerfile','r').read().replace("/fix-permissions","/fix_permissions").replace("fix-permissions","chown -R ${USER} ").replace("/fix_permissions","/fix-permissions").replace('/opt/conda',os.environ["CONDA_DIR"]).replace('\\\\\n','').split('\n')] if len(j)];

WORKDIR = '.'
sudo = ''

# in case its messed up by the docker
fix_env = f' UHOME={os.environ["HOME"]} HOME={os.environ["HOME"]} USER={os.environ["USER"]} CONDA_DIR={os.environ["CONDA_DIR"]}'

for i,m in enumerate(l):
  m = ' '.join(m).replace('/home/$NB_USER',os.environ["HOME"]).split(" ")
  if (m[0] == 'USER'):
    if m[1] == 'root':
        sudo = 'sudo '
    else:
        sudo = ''
  elif(m[0] == 'WORKDIR'):
    WORKDIR = m[1]
  elif(m[0] == 'RUN'):
    # insert this alias in case its used
    # m[0] = 'alias fix-permissions="chown -R ${USER} " && '
    # ignore any cmd with Linux in it
    if ''.join(m).find('Linux') > 0:
        # contaminated
        cmd = ''
    elif ' '.join(m).find('sed ') > 0:
        # contaminated with sed ... hope dont want these!
        cmd = ''
    else:
        cmd = f'{sudo} bash -c \'cd {WORKDIR} && ' + ' '.join(m[1:]) + "'"
  elif (m[0] == 'ARG' or m[0] == 'ENV'):
    if m[1].split('_')[0] == 'NB':
      # ignore these
      cmd = ''
    else:
      cmd = "export " + ' '.join(m[1:]) + fix_env
  elif(m[0] == 'COPY'):
    cmd = sudo + "cp " + ' '.join(m[1:])
  else:
    cmd=''
  print(cmd)
EOF

rm -rf Docker
mkdir -p Docker
cd Docker
echo "Downloading and working in ${CWD}"
# base the install on this
# get this rather than try to mimic the COPY
wget ${base}/Docker/jupyter_notebook_config.py
wget ${base}/Docker/fix-permissions
wget ${base}/Docker/environment.yml
wget ${base}/Docker/Dockerfile
wget ${base}/Docker/start.sh
wget ${base}/Docker/start-notebook.sh
wget ${base}/Docker/start-singleuser.sh
cd ..

export CONDA_DIR=$(conda info | grep 'base environment' | cut -d ':' -f 2 | awk '{print $1}' | sed 's/(writable)//g')

if [[ ! -d "$CONDA_DIR" ]]
then
  unset CONDA_DIR
fi

# check we have it
if [ -z "$CONDA_DIR" ]
then
      echo "${0}: ENV ERROR"
      echo 'ERROR: Cannot find $CONDA_DIR:'
      echo 'conda info returns:'
            conda info
      echo 'from both conda run env and env'
      echo '    - Check you have anacondsa or miniconda installed'
      echo '      and put the dist in CONDA_DIR'
      exit 1
fi

echo "CONDA_DIR: $CONDA_DIR"
#${SUDO} chown -R ${USER} .

# filter Dockerfile
# NB - use -i so conda activate works
echo '#!/bin/bash -i' > conda.recipe
echo "export PATH=\"${CONDA_DIR}/bin:${PATH}\""
echo 'alias fix-permissions="chown -R ${USER} "' >> conda.recipe
echo 'mkdir -p Docker'  >> conda.recipe
echo 'NB_USER=${USER}' >> conda.recipe
echo 'NB_UID=$(id -u)' >> conda.recipe
echo 'NB_GID=$(id -g)' >> conda.recipe
# unset the env to start with
conda_env=$(grep conda_env Docker/Dockerfile | grep ARG | cut -d '=' -f 2)
echo "conda deactivate && conda env remove --prefix ${conda_env}" >> conda.recipe

# take the enviro=nment with us
echo "export CONDA_DIR=${CONDA_DIR}" >> conda.recipe
python filter.py >> conda.recipe
if [ $? -eq 0 ]; then
   pwd
   echo 'python filter ok'
else
   echo 'python filter failed'
   pwd
   exit 1
fi

chmod +x conda.recipe


# get this rather than try to mimic the COPY
wget ${base}/Docker/environment.yml

# so as not to mess up
mkdir -p notebooks
wget ${base}/notebooks/00-Test_Notebook.ipynb
mv *.ipynb notebooks

# set a debug break point here
if [ $DEBUG -eq 1 ]
then
  pwd
  exit 0
fi

${SUDO} ./conda.recipe 2| tee conda.recipe.$$.log

if [ $? -eq 0 ]; then
   echo OK
else
   echo "${0} FAILED with code $?"
   echo "see log in ${CWD}/conda.recipe.$$.log"
   exit 1
fi

# so they can carry through
grep ENV < Docker/Dockerfile | sed 's/ENV /export /' | grep -v 'export HOME=' > ${HOME}/.dockenvrc

grep -v dockenvrc <  ~/.bashrc > ~/.bashrc.bak
echo 'source ~/.dockenvrc' >> ~/.bashrc.bak
mv ~/.bashrc.bak ~/.bashrc

cd "${here}"
# tidy
rm -rf ${tmp} ${HOME}/tmp
