"""Checks firestore.rules in both directions for the contact form.

The rules must *reject* malformed documents and *accept* exactly what the four
surfaces send (the abidnasim.com Flutter app plus nasim.pk / nasim.us / nasim.ae).
Only one of those directions is visible in day-to-day testing, and a rule that is
too strict fails silently: every submission returns 403 and nothing appears in the
collection. So both directions are exercised here.

    # Against the emulator — the place to edit rules (needs Java 21+):
    firebase emulators:start --only firestore --project demo-nasim
    python3 scripts/check_firestore_rules.py \
        "http://127.0.0.1:8080/v1/projects/demo-nasim/databases/(default)/documents"

    # Against the live project using the values in .env. This really writes:
    # the rules allow creates and deny deletes, so remove the test documents in
    # the Firebase console afterwards.
    python3 scripts/check_firestore_rules.py

Exits non-zero if any check fails.
"""

import json
import sys
import urllib.error
import urllib.request

if len(sys.argv) > 1:
    DOCS_BASE = sys.argv[1]
    KEY = "emulator-ignores-this"
else:
    env = {}
    with open("/Volumes/Dev/src/abidnasim/.env", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                name, value = line.split("=", 1)
                env[name] = value
    DOCS_BASE = (
        "https://firestore.googleapis.com/v1/projects/"
        f"{env['PUBLIC_FIREBASE_PROJECT_ID']}/databases/(default)/documents"
    )
    KEY = env["PUBLIC_FIREBASE_API_KEY"]

COLLECTION_URL = f"{DOCS_BASE}/contacts?key={KEY}"

CREATED = []
FAILURES = []


def submission(**overrides):
    fields = {
        "name": "Cline rules check",
        "email": "me@abidnasim.com",
        "message": "Rules verification submission — safe to delete.",
        "source": "nasim.us",
        "locale": "en",
        "pageUrl": "https://nasim.us/contact/",
        "createdAt": "2026-09-29T15:23:32.183Z",
    }
    fields.update(overrides)
    return {"fields": {k: {"stringValue": v} for k, v in fields.items()}}


def mutate(body, field, value):
    changed = json.loads(json.dumps(body))
    if value is None:
        del changed["fields"][field]
    else:
        changed["fields"][field] = {"stringValue": value}
    return changed


def with_extra_field(body):
    changed = json.loads(json.dumps(body))
    changed["fields"]["extra"] = {"stringValue": "x"}
    return changed


def request(method, url, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(
        url, data=data, headers={"Content-Type": "application/json"}, method=method
    )
    try:
        with urllib.request.urlopen(req, timeout=25) as response:
            return response.status, response.read().decode()
    except urllib.error.HTTPError as error:
        return error.code, error.read().decode()


def expect(status, expected, label):
    global last_body
    ok = "PASS" if status == expected else "FAIL"
    if ok == "FAIL":
        FAILURES.append(label)
    print(f"  [{ok}] {status} (expected {expected})  {label}")

    if status == 200:
        created = json.loads(last_body).get("name", "")
        if created:
            CREATED.append(created.rsplit("/", 1)[-1])


last_body = ""

print(f"Target: {DOCS_BASE}\n")
print("Requests that must be BLOCKED")
for body, label in [
    ({"fields": {"name": {"stringValue": "x"}}}, "body with only one field (the old hole)"),
    (mutate(submission(), "message", None), "missing field: message"),
    (mutate(submission(), "createdAt", None), "missing field: createdAt"),
    (with_extra_field(submission()), "extra field"),
    (mutate(submission(), "source", "nasim.xx"), "unknown source"),
    (mutate(submission(), "locale", "fr"), "unknown locale"),
    (mutate(submission(), "name", "n" * 81), "name 81 chars"),
    (mutate(submission(), "message", "m" * 2001), "message 2001 chars"),
    (mutate(submission(), "email", "not-an-email"), "malformed email"),
    (mutate(submission(), "createdAt", "yesterday"), "malformed createdAt"),
    (mutate(submission(), "createdAt", "2026-09-29T15:23:32.183"), "createdAt without Z"),
    (mutate(submission(), "pageUrl", "p" * 501), "pageUrl 501 chars"),
]:
    status, last_body = request("POST", COLLECTION_URL, body)
    expect(status, 403, label)

print("\nRequests that must be ALLOWED (one per surface)")
for body, label in [
    (submission(), "nasim.us  (nasim.us, en, JS toISOString)"),
    (
        submission(
            source="nasim.pk",
            locale="ur",
            pageUrl="https://nasim.pk/contact/",
            message="قواعد کی جانچ — حذف کرنا محفوظ ہے۔",
        ),
        "nasim.pk  (nasim.pk, ur)",
    ),
    (
        submission(
            source="nasim.ae",
            locale="ar",
            pageUrl="https://nasim.ae/contact/",
            message="تحقق من القواعد — آمن للحذف.",
        ),
        "nasim.ae  (nasim.ae, ar)",
    ),
    (
        submission(
            source="abidnasim-com-app",
            locale="en",
            pageUrl="https://abidnasim.com/",
            createdAt="2026-09-29T15:23:32.183456Z",
        ),
        "Flutter app (abidnasim-com-app, Dart toIso8601String with microseconds)",
    ),
    (
        submission(pageUrl="", createdAt="2026-09-29T15:23:32Z"),
        "edge: empty pageUrl, seconds-only timestamp",
    ),
]:
    status, last_body = request("POST", COLLECTION_URL, body)
    expect(status, 200, label)

print("\nClient reads/deletes must be BLOCKED")
for method, url, label in [
    ("GET", COLLECTION_URL, "list the collection"),
    ("GET", f"{DOCS_BASE}/contacts/anything?key={KEY}", "read one document"),
    ("DELETE", f"{DOCS_BASE}/contacts/anything?key={KEY}", "delete a document"),
    ("PATCH", f"{DOCS_BASE}/contacts/anything?key={KEY}", "update a document"),
]:
    status, last_body = request(method, url, {} if method == "PATCH" else None)
    expect(status, 403, label)

print()
if FAILURES:
    print(f"{len(FAILURES)} FAILURE(S):")
    for label in FAILURES:
        print(f"  - {label}")
else:
    print("All checks passed.")
if CREATED:
    print("\nDocuments created by this run:")
    for doc_id in CREATED:
        print(f"  contacts/{doc_id}")

# Non-zero on failure, so this can gate a deploy step.
sys.exit(1 if FAILURES else 0)
