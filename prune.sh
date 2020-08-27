#!/usr/bin/env bash

grab_version() {
    conda search -c "${CHANNEL}" --platform "${platform}" "${PKG}" 2>/dev/null | \
        grep "${CHANNEL}" | \
        awk -F '  *' '{print $2}' | \
        uniq | \
        head -n -1 | \
        xargs
}

grab_latest_version() {
    conda search -c "${CHANNEL}" --platform "${platform}" "${PKG}" 2>/dev/null | \
        grep "${CHANNEL}" | \
        awk -F '  *' '{print $2}' | \
        uniq | \
        tail -n 1 | \
        xargs
}

grab_builds() {
    conda search -c "${CHANNEL}" --platform "${platform}" "${PKG}" 2>/dev/null | \
        grep "${CHANNEL}" | \
		grep "$1" | \
        awk -F '  *' '{print $3}' | \
		uniq | \
        xargs
}

# TODO: Write this in a proper programming language

set -eou pipefail

CHANNEL=${CHANNEL:-pytorch-nightly}
PKG=${PKG:-pytorch}
PLATFORMS=${PLATFORMS:-noarch osx-64 linux-64 win-64}

for platform in ${PLATFORMS}; do
    latest_version="$(grab_latest_version || true)"
	latest_builds="$(grab_builds "${latest_version}" || true)"
    versions_to_prune="$(grab_version || true)"
	for version in ${versions_to_prune}; do
		builds="$(grab_builds "${version}" || true)"
		for build in ${builds}; do
		    if [[ "${latest_builds}" =~ "${build}" ]];then
			    (
			        set -x
			        anaconda remove --force ${CHANNEL}/${PKG}/${version}/${PLATFORMS}/${PKG}-${version}-${build}.tar.bz2
				)
			fi
        done
    done
done