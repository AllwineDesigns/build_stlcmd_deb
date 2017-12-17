# Docker image that builds stl_cmd as a Debian package

    # will build the source and binary package for amd64
    docker build -t build_stlcmd_deb .

    # runs bash, cd /tmp where the packages are built
    docker run -ti build_stlcmd_deb
