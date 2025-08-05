# Hackathon Demo

Create a build and deploy pipeline that run a simple flask app in Vagrant.

To test you can run
vagrant ssh -c "curl http://localhost:30007"

Architecture
1. Flask app
2. Docker Image
3. Kubernetes deployment

For security ensure that commands not ran as root in the Dockerfile

Added resource limitations in the kubenetes manifest

Also added liveness and readiness probes from kubernetes.

