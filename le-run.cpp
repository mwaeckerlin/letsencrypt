/**

  le-run -- headless launcher for the Let's Encrypt certificate client.

  Replaces the previous shell script + certbot (Python) + cron with a single
  compiled ACME client (lego) driven by a tiny C++ launcher. There is no shell,
  no Python and no cron in the image.

  It is a one-shot launcher, not a supervisor: it obtains (or renews) the
  certificates once and exits. Unattended renewal is done by restarting the
  container periodically (e.g. a swarm restart policy), which runs it again.

  Configuration (same environment as before):
    DOMAINS   space separated certificates; comma separated names share one cert
    PREFIXES  space separated prefixes prepended to every name (e.g. "www")
    EMAIL     ACME account e-mail
    MODE      "webroot" (default, writes the challenge into /acme) or "standalone"
    OPTIONS   extra lego flags, e.g. "--server https://acme/dir"

  lego stores its certificates under /etc/letsencrypt/certificates/<name>.{crt,key}.
  For compatibility with the reverse-proxy and the mail services, which all read
  the certbot layout, the certificates are also published as
  /etc/letsencrypt/live/<primary>/{fullchain,privkey}.pem.

 */

#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

using namespace std;
namespace fs = std::filesystem;

static const char *LE_PATH = "/etc/letsencrypt";
static const char *WEBROOT = "/acme";

static string env(const string &key, const string &def = "") {
  const char *v = getenv(key.c_str());
  return v ? string(v) : def;
}

static vector<string> split(const string &s, char sep) {
  vector<string> out;
  string tok;
  istringstream in(s);
  if (sep == ' ') {
    while (in >> tok)
      out.push_back(tok);
  } else {
    while (getline(in, tok, sep))
      if (!tok.empty())
        out.push_back(tok);
  }
  return out;
}

static int run(const vector<string> &args) {
  vector<char *> argv;
  for (const auto &a : args)
    argv.push_back(const_cast<char *>(a.c_str()));
  argv.push_back(nullptr);
  pid_t p = fork();
  if (p == -1)
    return -1;
  if (p == 0) {
    execv(argv[0], argv.data());
    perror("execv lego");
    _exit(127);
  }
  int status = 0;
  waitpid(p, &status, 0);
  return WIFEXITED(status) ? WEXITSTATUS(status) : -1;
}

// Publish lego's <primary>.{crt,key} as the certbot live/ layout that the
// reverse-proxy and the mail services consume.
static void publish(const string &primary) {
  const string crt = string(LE_PATH) + "/certificates/" + primary + ".crt";
  const string key = string(LE_PATH) + "/certificates/" + primary + ".key";
  if (!fs::exists(crt) || !fs::exists(key))
    return;
  const fs::path live = fs::path(LE_PATH) / "live" / primary;
  fs::create_directories(live);
  error_code ec;
  fs::copy_file(crt, live / "fullchain.pem",
                fs::copy_options::overwrite_existing, ec);
  fs::copy_file(key, live / "privkey.pem",
                fs::copy_options::overwrite_existing, ec);
}

int main() try {
  const string email = env("EMAIL");
  const string mode = env("MODE", "webroot");
  const vector<string> prefixes = split(env("PREFIXES"), ' ');
  const vector<string> options = split(env("OPTIONS"), ' ');

  int failures = 0;
  for (const string &group : split(env("DOMAINS"), ' ')) {
    const vector<string> names = split(group, ',');
    if (names.empty())
      continue;
    const string primary = names.front();

    // lego 5.x: the ACME flags belong to the "run" subcommand, and "run" both
    // obtains a new certificate and renews an existing one (respecting the
    // renewal threshold), so the same invocation works on every restart.
    vector<string> args = {"/usr/bin/lego", "run", "--accept-tos", "--path",
                           LE_PATH};
    if (!email.empty()) {
      args.push_back("--email");
      args.push_back(email);
    }
    for (const string &name : names) {
      args.push_back("--domains");
      args.push_back(name);
      for (const string &prefix : prefixes) {
        args.push_back("--domains");
        args.push_back(prefix + "." + name);
      }
    }
    args.push_back("--http");
    if (mode == "webroot") {
      args.push_back("--http.webroot");
      args.push_back(WEBROOT);
    }
    for (const string &opt : options)
      args.push_back(opt);

    cout << "---- lego run for " << primary << endl;
    if (run(args) != 0) {
      cerr << "**** ERROR: lego failed for " << primary << endl;
      ++failures;
      continue;
    }
    publish(primary);
  }
  return failures == 0 ? 0 : 1;
} catch (const exception &e) {
  cerr << "EXCEPTION: " << e.what() << endl;
  return 1;
}
