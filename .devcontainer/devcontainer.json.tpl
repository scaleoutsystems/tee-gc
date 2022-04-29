{
  "name": "devcontainer",
  "dockerFile": "../Dockerfile",
  "context": "..",
  "remoteUser": "default",
  // "workspaceFolder": "/tee-poc/mnist-cpp",
  // "workspaceMount": "source=/path/to/tee-poc,target=/tee-poc,type=bind,consistency=default",
  "extensions": [
    "exiasr.hadolint",
    "yzhang.markdown-all-in-one",
  ],
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind,consistency=default",
  ],
  "runArgs": [
    "--privileged"
  ],
  "forwardPorts": [
    8090,
    9000,
    9001,
    8081
  ]
}