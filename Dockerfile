FROM ubuntu:16.10

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
        software-properties-common \
        sudo \
    && add-apt-repository ppa:webupd8team/java -y \
    && apt-get update \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Install separate layers so that the above layer can be re-used for
# other IDE images coming below (NetBeans, Eclipse...)

ADD run_in_container /usr/local/bin/intellij

RUN apt-get update && apt-get install -y libgtk2.0-0 libcanberra-gtk-module \
    && wget http://download-cf.jetbrains.com/idea/ideaIC-2016.3.4.tar.gz -O /tmp/intellij.tar.gz --progress=bar \
    && mkdir -p /opt/intellij \
    && tar -xf /tmp/intellij.tar.gz --strip-components=1 -C /opt/intellij \
    && rm /tmp/intellij.tar.gz \
    && chmod +x /usr/local/bin/intellij \
    && mkdir -p /home/developer \
    && echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd \
    && echo "developer:x:1000:" >> /etc/group \
    && echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer \
    && chmod 0440 /etc/sudoers.d/developer \
    && chown developer:developer -R /home/developer \
    && chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

USER developer
ENV HOME /home/developer
WORKDIR /home/developer
CMD /usr/local/bin/intellij
