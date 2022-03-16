#!/usr/bin/env python3

import git
import json
import requests

from distutils.version import StrictVersion

def get_tags(repo: str):
    all_tags = []
    resp = requests.get((
        "https://api.github.com/"
        f"repos/{repo}/tags"
        "?simple=yes&per_page=100"
    ))
    tags = [t.get("name") for t in resp.json() if "name" in t]
    all_tags += tags

    while resp.links.get("next", {}).get("url", None) is not None:
        resp = requests.get(resp.links.get("next").get("url"))
        tags = [t.get("name") for t in resp.json() if "name" in t]
        all_tags += tags

    return all_tags

if __name__ == "__main__":
    upstream_tags = get_tags("torvalds/linux")

    filtered_upstream_tags = [
        t.replace("v", "")
        for t in upstream_tags
        if "-" not in t
    ]
    filtered_upstream_tags.sort(key=StrictVersion)

    # Print the 2 latest non-RC kernels
    latest_2_kernels = [str(t) for t in filtered_upstream_tags[-2:]]
    print(f"::set-output name=versions::{json.dumps(latest_2_kernels)}")

    # Create tags
    # repo set up by checkout action
    repo = git.Repo(".")
    current_tags = [str(t) for t in repo.tags]

    try:
        assert current_tags == latest_2_kernels
    except AssertionError:
        for tag in repo.tags:
            repo.delete_tag(tag)
            repo.git.push("origin", "-f", "-d", tag)
        for tag in latest_2_kernels:
            repo.create_tag(tag)
        # Force push all our tags
        repo.git.push("origin", "-f", "--tags")
