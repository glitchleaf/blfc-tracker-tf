#!/usr/bin/env bash

set -euo pipefail

TASK="${1:-}"
if [ -z "$TASK" ]; then
  TASKS="$(aws ecs list-tasks --cluster default --service tracker \
    --desired-status RUNNING --query 'taskArns[]' --output text)"

  if [ "$TASKS" == "" ]; then
    echo "no tasks detected, is the service running?"
    exit 1
  elif [ "$(echo "$TASKS" | wc -l | grep -Eo '[0-9]+')" -ne "1" ]; then
    echo -e "multiple tasks detected, pick one from this list then run this command again like:\n  bin/exec.sh arn:aws:ecs:xxx:xxx:task/default/xxx"
    exit 0
  else
    TASK="$TASKS"
  fi
fi

exec aws ecs execute-command --cluster default --container tracker --command '/bin/bash' --interactive --task "$TASK"
