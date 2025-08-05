# practice-simulation

curl -fsSL https://get.docker.com | sh

sudo usermod -aG docker $USER

docker build -t flask-demo .

docker save flask-demo | sudo k3s ctr images import -