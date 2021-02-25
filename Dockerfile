FROM registry.redhat.io/ubi8/ubi

ARG USERNAME=vscode
ENV HOME=/home/${USERNAME}

RUN yum -y install --disableplugin=subscription-manager \
  python3 python3-devel python3-requests vim git gcc make \
  iputils sudo procps-ng \
  && yum --disableplugin=subscription-manager clean all

# COPY ca.crt  /etc/pki/ca-trust/source/anchors/
# RUN update-ca-trust extract

RUN useradd -u 1001 ${USERNAME} -s /bin/bash -G wheel
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME /commandhistory \
    && echo $SNIPPET >> "/home/$USERNAME/.bashrc"

USER ${USERNAME}
RUN pip3 install tox --user

RUN mkdir ${HOME}/local && mkdir ${HOME}/etc
COPY --chown=${USERNAME} bootstrap_ansible ${HOME}/local/bootstrap_ansible

WORKDIR ${HOME}/local/bootstrap_ansible
RUN ${HOME}/.local/bin/tox --notest

WORKDIR ${HOME}
RUN echo 'source ~/local/python/tox/py3-ansible30/bin/activate' >> ${HOME}/.bash_profile
RUN echo 'export PS1="[\\w]\\$ "' >> ${HOME}/.bash_profile