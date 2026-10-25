#!/usr/bin/env bash
# Load versions from versions.properties into environment variables
# Usage: source scripts/load-versions.sh

set -euo pipefail

VERSIONS_FILE="${1:-versions.properties}"

if [[ ! -f "${VERSIONS_FILE}" ]]; then
    echo "ERROR: ${VERSIONS_FILE} not found" >&2
    exit 1
fi

# Export all key=value pairs from the properties file
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ -z "${key}" ]] && continue
    [[ "${key}" =~ ^#.*$ ]] && continue

    # Remove any inline comments
    value=$(echo "${value}" | sed 's/#.*$//' | xargs)

    # Export with uppercase key and underscores
    export_key=$(echo "${key}" | tr '[:lower:]-' '[:upper:]_')
    export "${export_key}"="${value}"
done < "${VERSIONS_FILE}"

echo "Loaded versions from ${VERSIONS_FILE}"
echo "JAVA_VERSION=${JAVA_VERSION}"
echo "MAVEN_VERSION=${MAVEN_VERSION}"
echo "SPRING_BOOT_VERSION=${SPRING_BOOT_VERSION}"
echo "KUBERNETES_VERSION=${KUBERNETES_VERSION}"
echo "APP_VERSION=${APP_VERSION}"
echo "DOCKER_IMAGE=${DOCKER_IMAGE}"