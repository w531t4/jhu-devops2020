to build the project, run

REQUIREMENTS:
    docker
    must disable firewalld
    ! must disable selinux enforcing (due to /var/run/docker.sock)
    # needed to issue the following in order to get inter-container
    # communication functioning on fedora-latest-stable

    # kudos: https://stackoverflow.com/questions/40214617/docker-no-route-to-host
    # enable the following
    #sysctl net.bridge.bridge-nf-call-iptables=0
    #sysctl net.bridge.bridge-nf-call-arptables=0
    #sysctl net.bridge.bridge-nf-call-ip6tables=0
    #sysctl net.ipv4.ip_forward=1

    Need to get API key for Snyk from https://app.snyk.io/account (once authenticated click dialog towards top of screen that says 'click to show')

RUNNING:

    API_KEY="API key from the requirements above" docker-compose up --build
    docker-compose down --remove-orphans

INSTRUCTIONS:

Logging into docker

    [root@otherbarry proj]# docker login localhost:35000
    Username: root
    Password: 
    WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
    Configure a credential helper to remove this warning. See
    https://docs.docker.com/engine/reference/commandline/login/#credentials-store

    Login Succeeded
    [root@otherbarry proj]# 

Running Snyk via docker

    docker run -it -e "SNYK_TOKEN=token"  -e "MONITOR=true" -v "test:/project" -v "/var/run/docker.sock:/var/run/docker.sock" snyk/snyk-cli:docker test --docker registry:2