#!/bin/bash

# Stop script on errors
set -e

GITLAB_URL=${GITLAB_URL}
GITLAB_TOKEN=${GITLAB_TOKEN}
GITLAB_RUNNER_NAME=${HOSTNAME}

if [ "$*" = "gitlab-runner" ]; then

  # if gitlab runner hasn't registered, erm, register!
  if ! gitlab-runner verify -n "$HOSTNAME"; then

    # Run the gitlab-runner in the background
    /usr/bin/gitlab-runner run \
      --user=gitlab-runner \
      --working-directory=/home/gitlab-runner \
    &

    # Wait 1 second to ensure gitlab has started
    sleep 1

    # Register agent using ENV variables for config
    export REGISTER_LOCKED=false
    export CI_SERVER_URL=${GITLAB_URL}
    export RUNNER_NAME=${GITLAB_RUNNER_NAME}
    export REGISTRATION_TOKEN=${GITLAB_TOKEN}
    export RUNNER_EXECUTOR="docker"
    export DOCKER_IMAGE="docker:git"
    export REGISTER_NON_INTERACTIVE=true

    gitlab-runner register

    # kill previous gitlab job
    kill %1

  fi

  # Re-run (or run if already previously registered) the runner in the
  # foreground, to ensure the container doesn't die
  /usr/bin/gitlab-runner run \
    --user=gitlab-runner \
    --working-directory=/home/gitlab-runner

else
  exec "$@"
fi
