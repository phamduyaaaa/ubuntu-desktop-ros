FROM kasmweb/ubuntu-focal-desktop:x86_64-1.16.0
USER root

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update -q && \
    apt-get install -y -q software-properties-common && \
    add-apt-repository universe && \
    apt-get update -q && \
    apt-get install -y -q git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ros_install_noetic.sh /ros_install_noetic.sh
COPY dueling_dqn_gazebo /home/kasm-user/dueling_dqn_gazebo
COPY mapRL /home/kasm-user/mapRL
COPY models /home/kasm-user/models

RUN chmod +x /ros_install_noetic.sh && \
    sed -i 's/read -p.*$/REPLY=1/' /ros_install_noetic.sh && \
    sed -i 's/answer=.*/answer=1/' /ros_install_noetic.sh && \
    sed -i '1 i answer=1' /ros_install_noetic.sh
RUN /ros_install_noetic.sh

RUN echo "source /opt/ros/noetic/setup.bash" >> /home/kasm-user/.bashrc && \
    echo "source /mapRL/devel/setup.bash" >> /home/kasm-user/.bashrc

WORKDIR /home/kasm-user/mapRL
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

RUN chown -R kasm-user:kasm-user /home/kasm-user/.ros 


ENTRYPOINT ["/dockerstartup/kasm_default_profile.sh", "/dockerstartup/vnc_startup.sh", "/dockerstartup/kasm_startup.sh"]
