#!/usr/bin/env sh

set -eu

REPO_URL="https://github.com/anza-labs/infra-ansible.git"
LOG_FILE="/var/log/ansible-pull.log"
EMAIL_RECIPIENT="root"  # Change to a real email if needed

# Trap errors and send email on failure
error_handler() {
    [ $? -eq 0 ] && exit 0
    echo "Ansible pull failed on $(hostname) at $(date)" > /tmp/ansible-fail.txt
    tail -n 50 "${LOG_FILE}" >> /tmp/ansible-fail.txt
    mail -s "Ansible Pull Failed on $(hostname)" "${EMAIL_RECIPIENT}" < /tmp/ansible-fail.txt
    rm -f /tmp/ansible-fail.txt
}

pull() {
    REPO="$1"
    PLAYBOOK="$2"

    echo "[$(date)] Running ansible-pull for ${REPO}/${PLAYBOOK}..."

    ansible-pull \
        -U "${REPO}" \
        -i localhost \
        "${PLAYBOOK}"
}

trap error_handler EXIT

mkdir -p $(dirname "${LOG_FILE}")

(
    echo "[$(date)] Starting ansible-pull..."

    pull "${REPO_URL}" 'playbooks/vmboot.yaml'
    pull "${REPO_URL}" 'playbooks/prerequisites.yaml'

    echo "[$(date)] Ansible pull finished successfully."
) >> "${LOG_FILE}" 2>&1
