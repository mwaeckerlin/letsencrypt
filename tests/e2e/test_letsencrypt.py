"""certbot obtains a real certificate from the local Pebble ACME test server.

The whole ACME exchange (account, order, finalize, download) and the X.509
issuance are real; only Pebble's domain-control challenge is short-circuited via
PEBBLE_VA_ALWAYS_VALID.
"""
from conftest import DOMAIN, live_path

from cryptography import x509
from cryptography.x509.oid import ExtensionOID, NameOID


def _load(path: str) -> x509.Certificate:
    with open(path, "rb") as f:
        return x509.load_pem_x509_certificate(f.read())


def test_certificate_and_key_exist(fullchain):
    with open(live_path("privkey.pem")) as f:
        assert "PRIVATE KEY" in f.read()
    with open(fullchain) as f:
        assert "BEGIN CERTIFICATE" in f.read()


def test_certificate_covers_requested_domain(fullchain):
    cert = _load(fullchain)
    san = cert.extensions.get_extension_for_oid(
        ExtensionOID.SUBJECT_ALTERNATIVE_NAME
    ).value.get_values_for_type(x509.DNSName)
    assert DOMAIN in san


def test_certificate_issued_by_acme_ca_not_self_signed(fullchain):
    cert = _load(fullchain)
    issuer = cert.issuer.rfc4514_string()
    subject = cert.subject.rfc4514_string()
    # A real ACME issuance is signed by the CA, not by the leaf itself.
    assert issuer != subject
    issuer_cn = cert.issuer.get_attributes_for_oid(NameOID.COMMON_NAME)
    assert issuer_cn and "Pebble" in issuer_cn[0].value


def test_certificate_currently_valid(fullchain):
    import datetime

    cert = _load(fullchain)
    now = datetime.datetime.now(datetime.timezone.utc)
    assert cert.not_valid_before_utc <= now < cert.not_valid_after_utc


def test_certificate_covers_www_prefix(fullchain):
    # PREFIXES=www must expand the certificate to also cover www.<domain>.
    cert = _load(fullchain)
    san = cert.extensions.get_extension_for_oid(
        ExtensionOID.SUBJECT_ALTERNATIVE_NAME
    ).value.get_values_for_type(x509.DNSName)
    assert "www." + DOMAIN in san


def test_second_certificate_group_with_combined_names(fullchain):
    # A second, space separated certificate whose two comma separated names plus
    # their www prefixes share one certificate.
    import os
    from conftest import LE_DIR

    path = os.path.join(LE_DIR, "live", "second.example.com", "fullchain.pem")
    assert os.path.exists(path)
    cert = _load(path)
    san = cert.extensions.get_extension_for_oid(
        ExtensionOID.SUBJECT_ALTERNATIVE_NAME
    ).value.get_values_for_type(x509.DNSName)
    for name in ("second.example.com", "alt.example.com",
                 "www.second.example.com", "www.alt.example.com"):
        assert name in san


def test_certificate_resource_persisted_for_renewal(fullchain):
    # lego stores the ACME account and the certificate resource, so restarting
    # the container runs an unattended `renew` (skips while not due).
    import os
    from conftest import LE_DIR

    assert os.path.exists(os.path.join(LE_DIR, "certificates", DOMAIN + ".json"))
    assert os.path.isdir(os.path.join(LE_DIR, "accounts"))
