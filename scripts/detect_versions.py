#!/usr/bin/env python3
"""Decide which pgModeler versions have to be built and published.

Compares the upstream GitHub releases with the tags already on Docker Hub and
writes a GitHub Actions build matrix. Uses only the standard library. Running it
locally is always safe: it only reads public APIs and prints the result.

Examples:
  detect_versions.py                            every missing version >= MIN_VERSION
  detect_versions.py --versions 1.2.3           only these (skipping published ones)
  detect_versions.py --versions 1.2.0 --force   rebuild even if already published
  detect_versions.py --validate                 highest version, never tagged latest
"""
import argparse
import json
import os
import re
import sys
import urllib.request

UPSTREAM_REPO = "nullptrlabs/pgmodeler"
IMAGE = "apazga/docker-pgmodeler"
# Oldest version built automatically; older ones are only built on request
MIN_VERSION = "1.2.0"
# Versions known not to build, never selected automatically (explicit requests still work)
SKIP_VERSIONS = frozenset()
# Base image per pgModeler major version: 1.x needs Qt >= 6.4, 2.x needs Qt >= 6.6
BASE_IMAGES = {1: "ubuntu:24.04", 2: "ubuntu:26.04"}

VERSION_RE = re.compile(r"^v?(\d+)\.(\d+)\.(\d+)(?:-(alpha|beta|rc)(\d*))?$")
STAGE_ORDER = {"alpha": 0, "beta": 1, "rc": 2, None: 3}


def parse_version(tag):
    """Return the version of a release tag without the "v" prefix, or None if it is not one."""
    tag = tag.strip()
    return tag.removeprefix("v") if VERSION_RE.match(tag) else None


def version_key(version):
    """Sort key: 2.0.0-alpha < 2.0.0-alpha1 < 2.0.0-beta < 2.0.0-rc1 < 2.0.0."""
    match = VERSION_RE.match(version)
    if not match:
        raise ValueError(f"not a pgModeler version: {version!r}")
    major, minor, patch, stage, number = match.groups()
    return (int(major), int(minor), int(patch), STAGE_ORDER[stage], int(number or 0))


def base_image_for(version):
    major = version_key(version)[0]
    return BASE_IMAGES.get(major, BASE_IMAGES[max(BASE_IMAGES)])


def parse_requested(text):
    """Split a "1.2.3, v2.0.0-beta1" style list into normalized versions."""
    versions = []
    for item in re.split(r"[,\s]+", text.strip()):
        if not item:
            continue
        version = parse_version(item)
        if version is None:
            raise ValueError(f"not a pgModeler version: {item!r}")
        versions.append(version)
    return versions


def select_versions(upstream, published, requested=None, force=False, validate=False,
                    min_version=MIN_VERSION, skip=SKIP_VERSIONS):
    """Return the build matrix entries: [{"version", "base_image", "latest"}, ...].

    upstream are the versions released upstream and published the tags already on
    Docker Hub. "latest" only goes to the highest upstream version >= min_version
    that is not skipped, so building older versions never moves it backwards.
    """
    if force and not requested:
        raise ValueError("--force needs --versions")
    floor = version_key(min_version)
    candidates = sorted((v for v in set(upstream) if version_key(v) >= floor and v not in skip),
                        key=version_key)
    highest = candidates[-1] if candidates else None

    if validate:
        chosen = candidates[-1:]
    elif requested:
        unknown = sorted(set(requested) - set(upstream))
        if unknown:
            raise ValueError(f"not released upstream: {', '.join(unknown)}")
        chosen = sorted(set(requested), key=version_key)
        if not force:
            chosen = [v for v in chosen if v not in published]
    else:
        chosen = [v for v in candidates if v not in published]

    return [{"version": v, "base_image": base_image_for(v), "latest": v == highest and not validate}
            for v in chosen]


def http_get_json(url, token=None):
    headers = {"Accept": "application/json", "User-Agent": "docker-pgmodeler-ci"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=30) as response:
        return json.load(response)


def fetch_upstream_versions(repo, token=None, get=http_get_json):
    """Versions of the published (non-draft) GitHub releases of repo."""
    versions, page = [], 1
    while True:
        releases = get(f"https://api.github.com/repos/{repo}/releases?per_page=100&page={page}", token)
        if not releases:
            return versions
        for release in releases:
            if release.get("draft"):
                continue
            version = parse_version(release["tag_name"])
            if version:
                versions.append(version)
            else:
                print(f"warning: ignoring upstream tag {release['tag_name']!r}", file=sys.stderr)
        page += 1


def fetch_published_tags(image, get=http_get_json):
    """Every tag of the Docker Hub repository image."""
    tags, url = set(), f"https://hub.docker.com/v2/repositories/{image}/tags?page_size=100"
    while url:
        data = get(url)
        tags.update(tag["name"] for tag in data.get("results", []))
        url = data.get("next")
    return tags


def write_github_output(entries, path):
    with open(path, "a", encoding="utf-8") as f:
        f.write(f"matrix={json.dumps({'include': entries})}\n")
        f.write(f"count={len(entries)}\n")


def summary(entries):
    if not entries:
        return "Nothing to build: every upstream version is already on Docker Hub.\n"
    lines = ["| Version | Base image | latest |", "|---|---|---|"]
    lines += [f"| {e['version']} | {e['base_image']} | {'yes' if e['latest'] else ''} |" for e in entries]
    return "\n".join(lines) + "\n"


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--upstream", default=UPSTREAM_REPO, help="GitHub repository of pgModeler")
    parser.add_argument("--image", default=IMAGE, help="Docker Hub repository")
    parser.add_argument("--min-version", default=MIN_VERSION, help="oldest version built automatically")
    parser.add_argument("--versions", default="", help="comma or space separated versions to build")
    parser.add_argument("--force", action="store_true", help="rebuild versions already on Docker Hub")
    parser.add_argument("--validate", action="store_true", help="only the highest version, never as latest")
    args = parser.parse_args(argv)

    try:
        requested = parse_requested(args.versions)
        upstream = fetch_upstream_versions(args.upstream, os.environ.get("GITHUB_TOKEN"))
        published = fetch_published_tags(args.image)
        entries = select_versions(upstream, published, requested, args.force, args.validate, args.min_version)
    except ValueError as error:
        parser.error(str(error))

    text = summary(entries)
    print(text, end="")
    if os.environ.get("GITHUB_OUTPUT"):
        write_github_output(entries, os.environ["GITHUB_OUTPUT"])
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as f:
            f.write("### pgModeler versions to build\n\n" + text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
