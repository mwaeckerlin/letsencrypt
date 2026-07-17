"""Shared fixtures for the letsencrypt e2e suite."""
import os
import time

import pytest

LE_DIR = os.environ.get("LE_DIR", "/etc/letsencrypt")
DOMAIN = os.environ.get("DOMAIN", "test.example.com")


def live_path(name: str) -> str:
    return os.path.join(LE_DIR, "live", DOMAIN, name)


def wait_for_file(path: str, timeout: int = 120) -> bool:
    deadline = time.time() + timeout
    while time.time() < deadline:
        if os.path.exists(path) and os.path.getsize(path) > 0:
            return True
        time.sleep(1)
    return False


@pytest.fixture(scope="session")
def fullchain() -> str:
    path = live_path("fullchain.pem")
    if not wait_for_file(path):
        raise TimeoutError(f"certificate {path} was not issued within the timeout")
    return path
