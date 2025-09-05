
## 1. Create a ec2 instance
install DB as seen in hands-on-exercises/db-setup/install-db.sh
open ports 22, 443, 15000, 16000, 17000, 18000

---
## 2. Install Harness Delegate

Install Harness delegate on the ec2 server an example shown below (Harness -> settings -> delegates -> create -> docker delegate)

All the variable values can be obtained from the Harness delegate creation UI just copy paste is enough
ACCOUNT_ID, DELEGATE_TOKEN, MANAGER_HOST_AND_PORT, UPGRADER_TOKEN
Whenever you reboot the ec2 instance you need to run the same command

> ⚠️ WARNING:Just an example don't run this, run the one shown in your UI delegate creation step
```bash

docker run  --cpus=1 --memory=2g \
  -e DELEGATE_NAME=docker-delegate \
  -e NEXT_GEN="true" \
  -e DELEGATE_TYPE="DOCKER" \
  -e ACCOUNT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  -e DELEGATE_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx= \
  -e DELEGATE_TAGS="" \
  -e MANAGER_HOST_AND_PORT=https://app.harness.io us-docker.pkg.dev/gar-prod-setup/harness-public/harness/delegate:25.08.86600


# Run this command to enable auto-upgrade for Docker Delegate

docker run  --cpus=0.1 --memory=100m \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e ACCOUNT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  -e MANAGER_HOST_AND_PORT=https://app.harness.io \
  -e UPGRADER_WORKLOAD_NAME=docker-delegate \
  -e UPGRADER_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx= \
  -e CONTAINER_STOP_TIMEOUT=3600 \
  -e SCHEDULE="0 */1 * * *" harness/upgrader:latest

```

---
