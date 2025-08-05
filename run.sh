#!/bin/bash
set -euo pipefail

GIT_URL="https://github.com/shubhroses/practice-simulation.git"
IMAGE_NAME="flask-demo"
PROJECT_DIR="/home/vagrant/practice-simulation"

echo "1. Making sure vagrant is running."
vagrant up --provider=qemu

echo ""
echo "2. Git pull or clone"
vagrant ssh -c "
  if [ -d ${PROJECT_DIR} ]; then
    echo 'Directory exists so pulling.'
    cd ${PROJECT_DIR} && git pull origin main
  else
    echo 'Directory does not exist so cloning.'
    git clone ${GIT_URL} ${PROJECT_DIR}
  fi
"

echo ""
echo "3. Rebuild docker image"
vagrant ssh -c "cd ${PROJECT_DIR} && docker build -t ${IMAGE_NAME} ."

echo ""
echo "4. Import docker image to k3s"
vagrant ssh -c "docker save ${IMAGE_NAME} | sudo k3s ctr images import -"

echo ""
echo "5. Apply k8c-deploy.yaml"
vagrant ssh -c "cd ${PROJECT_DIR} && sudo k3s kubectl apply -f k8s-deploy.yaml"

echo ""
echo "6. Restart the rollout and wait for it to finish."
vagrant ssh -c "sudo k3s kubectl rollout restart deployment/${IMAGE_NAME}"
vagrant ssh -c "sudo k3s kubectl rollout status deployment/${IMAGE_NAME} --timeout=60s"

echo ""
echo "7. Test main endpoint."
vagrant ssh -c "curl http://localhost:30007"

echo ""
echo "8. Test health endpoint."
vagrant ssh -c "curl http://localhost:30007/health | python3 -m json.tool"

echo ""
echo "9. Test readiness endpoint."
vagrant ssh -c "curl http://localhost:30007/ready"

echo ""
echo "10. Check status:"
vagrant ssh -c "sudo k3s kubectl get pods"

echo ""
echo "11. View logs:"
vagrant ssh -c "sudo k3s kubectl logs -l app=${IMAGE_NAME} --tail=50"