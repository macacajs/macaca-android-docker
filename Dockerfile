FROM ubuntu:16.04

MAINTAINER Samuel "samuel.zhao.yue@live.com"

# Specially for SSH access and port redirection
ENV ROOTPASSWORD macaca

# Expose ADB, ADB control and VNC ports
EXPOSE 22
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555
EXPOSE 5900
EXPOSE 80
EXPOSE 443

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /root

#COPY ./etc/apt/sources.list_backup /etc/apt/sources.list
#RUN apt update

RUN apt-get update && \
    apt-get install -y build-essential git vim make zip unzip curl wget bzip2 ssh openssh-server socat && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y software-properties-common && \
    apt-get install -y net-tools iputils-ping dnsutils && \
    apt-get install -y python-dev python-pip  && \
    apt-get install -y apt-utils usbutils locales udev && \
    apt-get autoremove -y && \
	apt-get clean

# Install packages needed for android sdk tools
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386

# Install Ant version specified above and Set the environment variable for Ant
# ENV ANT_VERSION 1.9.4
# ENV ANT_HOME /opt/ant
# ENV PATH ${PATH}:/opt/ant/bin
# RUN wget -q http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
#     tar -xzf apache-ant-${ANT_VERSION}-bin.tar.gz && \
#     mv apache-ant-${ANT_VERSION} /opt/ant && \
#     rm apache-ant-${ANT_VERSION}-bin.tar.gz

# Set the environment variable for Ant
# ENV ANT_HOME /opt/ant
# ENV PATH ${PATH}:/opt/ant/bin

# Java Environment Path
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH=${JAVA_HOME}/bin:$PATH

# Install Android SDK
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV ANDROID_NDK_HOME=$ANDROID_HOME/android-ndk-r14b
ENV PATH=$PATH:$ANDROID_HOME/tools/:$ANDROID_HOME/platform-tools:$ANDROID_NDK_HOME

RUN curl -o android-sdk.tgz https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && tar -C /opt -zxvf android-sdk.tgz > /dev/null
RUN curl -o ndk-bundle.zip https://dl.google.com/android/repository/android-ndk-r14b-linux-x86_64.zip && unzip ndk-bundle.zip -d $ANDROID_HOME > /dev/null

RUN mkdir "$ANDROID_HOME/licenses" || true
RUN echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license"
RUN echo -e "\d56f5187479451eabf01fb78af6dfcb131a6481e" >> "$ANDROID_HOME/licenses/android-sdk-license"
RUN echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"

# Install Android Build Tools and the required version of Android SDK
# You can create several versions of the Dockerfile if you need to test several versions
RUN ( sleep 4 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --force -a --filter \
    platform-tool,android-25,android-26,build-tools-25.0.2,build-tools-26.0.1,extra-android-support,extra-android-m2repository,extra-google-m2repository && \
    echo "y" | android update adb

# RUN which adb
# RUN which android

# Gradle 4.2
ENV GRADLE_HOME=/usr/local/gradle-4.2
ENV PATH=$GRADLE_HOME/bin:$PATH

RUN curl -o gradle-4.2-all.zip -L https://services.gradle.org/distributions/gradle-4.2-all.zip && unzip gradle-4.2-all.zip -d /usr/local > /dev/null

# Nodejs Environment Path
ENV PATH=$PATH:/opt/node-v6.11.4-linux-x64/bin
RUN curl -o node-v6.11.4-linux-x64.tar.xz https://nodejs.org/dist/v6.11.4/node-v6.11.4-linux-x64.tar.xz && tar -C /opt -Jxvf node-v6.11.4-linux-x64.tar.xz > /dev/null

# Run sshd
RUN mkdir /var/run/sshd && \
    echo "root:$ROOTPASSWORD" | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

# Add entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
