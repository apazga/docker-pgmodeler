"""Unit tests for detect_versions.py (no network access)."""
import json
import os
import tempfile
import unittest

import detect_versions as dv

# Upstream releases and Docker Hub tags as of 2026-10-04
UPSTREAM = [
    "2.0.0-beta1", "2.0.0-beta", "2.0.0-alpha1", "1.2.3", "2.0.0-alpha",
    "1.2.2", "1.2.1", "1.2.0", "1.2.0-beta1", "1.2.0-beta", "1.1.6", "1.1.5",
]
PUBLISHED = {"latest", "2.0.0-alpha", "1.2.0", "1.1.5", "1.2.0-alpha1", "1.2.0-alpha", "1.1.4"}


class ParseVersionTest(unittest.TestCase):
    def test_strips_v_prefix(self):
        self.assertEqual(dv.parse_version("v2.0.0-beta1"), "2.0.0-beta1")
        self.assertEqual(dv.parse_version("1.2.3"), "1.2.3")
        self.assertEqual(dv.parse_version("v2.1.0-rc1"), "2.1.0-rc1")

    def test_rejects_unexpected_formats(self):
        for tag in ("v1.1.0-alpha1a", "latest", "v2.0", "2.0.0-snapshot", ""):
            with self.subTest(tag=tag):
                self.assertIsNone(dv.parse_version(tag))


class VersionOrderTest(unittest.TestCase):
    def test_prereleases_sort_before_final(self):
        expected = ["1.2.0-beta", "1.2.0-beta1", "1.2.0", "2.0.0-alpha", "2.0.0-alpha1",
                    "2.0.0-beta", "2.0.0-beta1", "2.0.0-rc1", "2.0.0", "2.0.1"]
        shuffled = ["2.0.0", "2.0.0-beta1", "1.2.0", "2.0.1", "2.0.0-alpha", "1.2.0-beta1",
                    "2.0.0-rc1", "2.0.0-beta", "1.2.0-beta", "2.0.0-alpha1"]
        self.assertEqual(sorted(shuffled, key=dv.version_key), expected)

    def test_numeric_not_lexicographic(self):
        self.assertLess(dv.version_key("1.2.9"), dv.version_key("1.2.10"))

    def test_invalid_version_raises(self):
        with self.assertRaises(ValueError):
            dv.version_key("latest")


class BaseImageTest(unittest.TestCase):
    def test_major_versions(self):
        self.assertEqual(dv.base_image_for("1.2.3"), "ubuntu:24.04")
        self.assertEqual(dv.base_image_for("2.0.0-beta1"), "ubuntu:26.04")

    def test_unknown_major_uses_newest_base(self):
        self.assertEqual(dv.base_image_for("3.0.0"), "ubuntu:26.04")


class ParseRequestedTest(unittest.TestCase):
    def test_commas_spaces_and_v_prefix(self):
        self.assertEqual(dv.parse_requested(" v1.2.3, 2.0.0-beta1 2.0.0-beta "),
                         ["1.2.3", "2.0.0-beta1", "2.0.0-beta"])

    def test_empty(self):
        self.assertEqual(dv.parse_requested(""), [])
        self.assertEqual(dv.parse_requested("  "), [])

    def test_invalid_version_fails(self):
        with self.assertRaises(ValueError):
            dv.parse_requested("1.2.3,latest")


class SelectVersionsTest(unittest.TestCase):
    def test_missing_versions_from_min_version(self):
        entries = dv.select_versions(UPSTREAM, PUBLISHED)
        self.assertEqual([e["version"] for e in entries],
                         ["1.2.1", "1.2.2", "1.2.3", "2.0.0-alpha1", "2.0.0-beta", "2.0.0-beta1"])

    def test_only_highest_version_is_latest(self):
        entries = dv.select_versions(UPSTREAM, PUBLISHED)
        self.assertEqual([e["version"] for e in entries if e["latest"]], ["2.0.0-beta1"])

    def test_entries_carry_base_image(self):
        entries = {e["version"]: e for e in dv.select_versions(UPSTREAM, PUBLISHED)}
        self.assertEqual(entries["1.2.3"]["base_image"], "ubuntu:24.04")
        self.assertEqual(entries["2.0.0-beta1"]["base_image"], "ubuntu:26.04")

    def test_nothing_to_build(self):
        self.assertEqual(dv.select_versions(UPSTREAM, set(UPSTREAM)), [])

    def test_no_upstream_versions(self):
        self.assertEqual(dv.select_versions([], PUBLISHED), [])
        self.assertEqual(dv.select_versions([], PUBLISHED, validate=True), [])

    def test_backfill_does_not_move_latest(self):
        entries = dv.select_versions(UPSTREAM, PUBLISHED | {"2.0.0-beta1"})
        self.assertTrue(entries)
        self.assertFalse(any(e["latest"] for e in entries))

    def test_skip_versions(self):
        entries = dv.select_versions(UPSTREAM, PUBLISHED, skip={"2.0.0-beta1"})
        self.assertNotIn("2.0.0-beta1", [e["version"] for e in entries])
        self.assertEqual([e["version"] for e in entries if e["latest"]], ["2.0.0-beta"])

    def test_requested_versions_skip_published_without_force(self):
        entries = dv.select_versions(UPSTREAM, PUBLISHED, requested=["1.2.0", "1.2.3"])
        self.assertEqual([e["version"] for e in entries], ["1.2.3"])

    def test_force_rebuilds_requested_versions(self):
        entries = dv.select_versions(UPSTREAM, PUBLISHED, requested=["2.0.0-alpha", "1.2.0"], force=True)
        self.assertEqual([e["version"] for e in entries], ["1.2.0", "2.0.0-alpha"])
        self.assertFalse(any(e["latest"] for e in entries))

    def test_requested_highest_version_is_latest(self):
        self.assertEqual(dv.select_versions(UPSTREAM, PUBLISHED, requested=["2.0.0-beta1"]),
                         [{"version": "2.0.0-beta1", "base_image": "ubuntu:26.04", "latest": True}])

    def test_requested_unknown_version_fails(self):
        with self.assertRaises(ValueError):
            dv.select_versions(UPSTREAM, PUBLISHED, requested=["9.9.9"])

    def test_force_without_requested_versions_fails(self):
        with self.assertRaises(ValueError):
            dv.select_versions(UPSTREAM, PUBLISHED, force=True)

    def test_validate_builds_highest_without_latest(self):
        self.assertEqual(dv.select_versions(UPSTREAM, set(UPSTREAM), validate=True),
                         [{"version": "2.0.0-beta1", "base_image": "ubuntu:26.04", "latest": False}])


class FetchTest(unittest.TestCase):
    def test_upstream_releases_are_paginated_and_filtered(self):
        pages = {
            1: [{"tag_name": "v2.0.0-beta1", "draft": False},
                {"tag_name": "v2.0.0-beta2", "draft": True},
                {"tag_name": "v1.1.0-alpha1a", "draft": False}],
            2: [{"tag_name": "v1.2.3", "draft": False}],
            3: [],
        }

        def fake_get(url, token=None):
            return pages[int(url.rsplit("page=", 1)[1])]

        self.assertEqual(dv.fetch_upstream_versions("owner/repo", get=fake_get), ["2.0.0-beta1", "1.2.3"])

    def test_docker_hub_tags_follow_next_links(self):
        first = "https://hub.docker.com/v2/repositories/user/image/tags?page_size=100"
        responses = {
            first: {"results": [{"name": "latest"}, {"name": "1.2.0"}], "next": "https://hub.example/page2"},
            "https://hub.example/page2": {"results": [{"name": "1.1.5"}], "next": None},
        }
        tags = dv.fetch_published_tags("user/image", get=lambda url, token=None: responses[url])
        self.assertEqual(tags, {"latest", "1.2.0", "1.1.5"})


class OutputTest(unittest.TestCase):
    def test_github_output_contains_matrix_and_count(self):
        entries = [{"version": "1.2.3", "base_image": "ubuntu:24.04", "latest": False}]
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "github_output")
            dv.write_github_output(entries, path)
            with open(path, encoding="utf-8") as f:
                lines = f.read().splitlines()
        self.assertEqual(json.loads(lines[0].split("=", 1)[1]), {"include": entries})
        self.assertEqual(lines[1], "count=1")


if __name__ == "__main__":
    unittest.main()
