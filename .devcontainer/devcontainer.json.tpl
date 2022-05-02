{
  "name": "devcontainer",
  "dockerFile": "Dockerfile",
  "context": "..",
  "remoteUser": "default",
  // "workspaceFolder": "/tee-gc",
  // "workspaceMount": "source=/path/to/tee-gc,target=/tee-gc,type=bind,consistency=default",
  "extensions": [
    "exiasr.hadolint",
    "yzhang.markdown-all-in-one",
  ],
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind,consistency=default",
  ],
  "forwardPorts": [
    8090,
    9000,
    9001,
    8081
  ]
}