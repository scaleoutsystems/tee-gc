{
  "name": "devcontainer",
  "dockerFile": "../Dockerfile",
  "context": "..",
  "remoteUser": "default",
  // "workspaceFolder": "/tee-gsc",
  // "workspaceMount": "source=/path/to/tee-gsc,target=/tee-gsc,type=bind,consistency=default",
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