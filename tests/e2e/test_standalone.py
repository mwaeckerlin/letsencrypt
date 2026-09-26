"""MODE=standalone: lego answers the challenge itself, without a webroot.

The service letsencrypt-standalone requests standalone.example.com without
prefixes; its /etc/letsencrypt is mounted at /standalone in the test runner.
"""
import os

from cryptography import x509
from cryptography.x509.oid import ExtensionOID

from conftest import wait_for_file

FULLCHAIN = "/standalone/live/standalone.example.com/fullchain.pem"


def test_standalone_mode_issues_the_certificate():
    assert wait_for_file(FULLCHAIN), f"{FULLCHAIN} was not issued"
    assert os.path.getsize("/standalone/live/standalone.example.com/privkey.pem") > 0


def test_standalone_without_prefixes_requests_only_the_name():
    assert wait_for_file(FULLCHAIN)
    with open(FULLCHAIN, "rb") as f:
        cert = x509.load_pem_x509_certificate(f.read())
    names = cert.extensions.get_extension_for_oid(ExtensionOID.SUBJECT_ALTERNATIVE_NAME).value.get_values_for_type(x509.DNSName)
    assert names == ["standalone.example.com"]
