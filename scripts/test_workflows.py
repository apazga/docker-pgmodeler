"""Checks on the GitHub Actions workflows that can be verified without running them."""
import fnmatch
import pathlib
import re
import unittest

WORKFLOWS = pathlib.Path(__file__).resolve().parent.parent / ".github" / "workflows"


def workflow(name):
    return (WORKFLOWS / name).read_text(encoding="utf-8")


def evaluate(expression, event, ref="refs/heads/master"):
    """Evaluate a simple GitHub Actions expression (==, &&, ||, format) for an event."""
    python = (expression.replace("github.event_name", "event").replace("github.ref", "ref")
              .replace("&&", " and ").replace("||", " or ").replace("format(", "_format("))
    return eval(python, {"_format": lambda text, *args: text.format(*args)}, {"event": event, "ref": ref})


class DigestArtifactsTest(unittest.TestCase):
    def test_versions_do_not_collect_digests_of_other_versions(self):
        text = workflow("build-image.yml")
        name = re.search(r"name: (digests-.*)$", text, re.M).group(1)
        pattern = re.search(r"pattern: (digests-.*)$", text, re.M).group(1)

        def render(template, version, arch="*"):
            return template.replace("${{ inputs.version }}", version).replace("${{ matrix.arch }}", arch)

        versions = ["2.1.0", "2.1.0-rc1", "2.1.0-beta2", "12.1.0"]
        artifacts = [render(name, v, arch) for v in versions for arch in ("amd64", "arm64")]
        for version in versions:
            with self.subTest(version=version):
                matched = [a for a in artifacts if fnmatch.fnmatchcase(a, render(pattern, version))]
                self.assertEqual(matched, [render(name, version, "amd64"), render(name, version, "arm64")])


class ConcurrencyTest(unittest.TestCase):
    def setUp(self):
        text = workflow("release.yml")
        block = re.search(r"^concurrency:\n((?:  .*\n)+)", text, re.M).group(1)
        self.group = re.search(r"group: \$\{\{ (.*) \}\}", block).group(1)
        self.cancel = re.search(r"cancel-in-progress: \$\{\{ (.*) \}\}", block).group(1)

    def test_publishing_runs_queue_in_the_release_group(self):
        for event in ("schedule", "workflow_dispatch"):
            with self.subTest(event=event):
                self.assertEqual(evaluate(self.group, event), "release")
                self.assertFalse(evaluate(self.cancel, event))

    def test_validation_runs_never_join_the_release_group(self):
        for event in ("pull_request", "push"):
            with self.subTest(event=event):
                self.assertNotEqual(evaluate(self.group, event), "release")
                self.assertTrue(evaluate(self.cancel, event))


if __name__ == "__main__":
    unittest.main()
