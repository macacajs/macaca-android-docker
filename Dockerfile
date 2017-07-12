FROM centos:7

MAINTAINER ibigbug<xiaobayuwei@gmail.com>, xdf<xudafeng@126.com>

#COPY ./CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo
#RUN yum clean all && yum makecache

WORKDIR /pre-run

# yum update
RUN yum -y update

RUN yum -y install xorg-x11-server-Xvfb java-1.8.0-openjdk-devel glibc.i686 libstdc++.i686 glibc-devel.i686 zlib-devel.i686 ncurses-devel.i686 libX11-devel.i686 libXrender.i686 wget unzip git which glx-utils git file make qemu-kvm libvirt virt-install bridge-utils

RUN yum clean all

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk ANDROID_HOME=/opt/android-sdk-linux DISPLAY=:99.0 GRADLE_HOME=/usr/local/gradle-3.5
ENV PATH=$ANDROID_HOME/tools:$PATH

RUN useradd -ms /bin/bash developer && mkdir -p /home/developer/.npm-global && chown developer:developer /home/developer/.npm-global

ENV PATH=/home/developer/.npm-global/bin:${PATH}

RUN curl -o android-sdk.tgz https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && tar -C /opt -xvf android-sdk.tgz > /dev/null

RUN mkdir "$ANDROID_HOME/licenses" || true
RUN echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license"
RUN echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"

# armeabi-v7a x86_64

RUN chown -R developer:developer $ANDROID_HOME

RUN curl -o gradle-3.5-all.zip http://services.gradle.org/distributions/gradle-3.5-all.zip && \
  unzip gradle-3.5-all.zip -d /usr/local > /dev/null
ENV PATH=$GRADLE_HOME/bin:$PATH

WORKDIR /src

USER developer

# sys-img-armeabi-v7a-android-22 sys-img-x86_64-android-22

RUN echo y | android update sdk --proxy-host mirrors.neusoft.edu.cn --proxy-port 80 -s --all --filter build-tools-25.0.2,android-25,android-21,sys-img-armeabi-v7a-android-21,platform-tool,extra-android-support,extra-android-m2repository,extra-google-m2repository --no-ui --force

RUN echo n | android create avd --force -n test -t android-21 --abi armeabi-v7a

COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
