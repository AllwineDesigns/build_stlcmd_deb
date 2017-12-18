# Docker image that builds stl_cmd as a Debian package

    # will build the source and binary package for amd64
    docker build -t build_stlcmd_deb .

    # runs bash, cd /tmp where the packages are built
    docker run -ti build_stlcmd_deb

    # in another terminal
    docker ps
    docker cp <private key> <container id>:/tmp

    # in container terminal
    gpg --import /tmp/<private key>
    cd /tmp
    debsign -k <pgp id> stlcmd_1.0-1_amd64.changes
    dput mentors stlcmd_1.0-1_amd64.changes
    exit
