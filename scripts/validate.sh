#!/usr/bin/env bash
# Validates networking and storage of the running devops-lab-4 stack.
# Usage: ./scripts/validate.sh   (run from the lab-4 folder after `docker compose up -d --wait`)

cd "$(dirname "$0")/.." || exit 1
pass=0; fail=0

check() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "PASS  $name"; pass=$((pass + 1))
  else echo "FAIL  $name"; fail=$((fail + 1)); fi
}
not() { ! "$@"; }
dc() { docker compose "$@"; }

echo "== Networking"
check "web serves the page on host port 8080"        curl -sf localhost:8080/
check "web proxies /api to the api service"          curl -sf localhost:8080/api/health
check "api resolves db by service name"              dc exec -T api nslookup db
check "api resolves cache by service name"           dc exec -T api nslookup cache
check "api reaches cache on the backend network"     dc exec -T api ping -c1 -W2 cache
check "web cannot resolve db (not on backend)"       not dc exec -T web nslookup db
check "web cannot resolve cache (not on backend)"    not dc exec -T web nslookup cache
check "backend network is internal"                  test "$(docker network inspect devops-lab-4_backend -f '{{.Internal}}')" = true
check "cache has no route to the internet"           not dc exec -T cache ping -c1 -W2 8.8.8.8
check "db port is not published to the host"         test -z "$(docker inspect devops-lab-4-db-1 -f '{{range $p, $b := .HostConfig.PortBindings}}{{$p}}{{end}}')"

echo "== Storage"
note="validate-$(date +%s)"
check "named volume pgdata exists"                   docker volume inspect devops-lab-4_pgdata
check "named volume redisdata exists"                docker volume inspect devops-lab-4_redisdata
check "write a note through the api"                 curl -sf -XPOST localhost:8080/api/notes -H 'Content-Type: application/json' -d "{\"text\":\"$note\"}"
check "restart db and cache containers"              dc restart db cache
sleep 3
check "note survives the restart"                    bash -c "curl -sf localhost:8080/api/notes | grep -q $note"
check "redis append-only file is on the volume"      dc exec -T cache ls /data/appendonlydir
check "html bind mount is read-only in web"          not dc exec -T web touch /usr/share/nginx/html/x
check "db password is a mounted secret file"         dc exec -T db test -f /run/secrets/db_password
check "db password is not in the api environment"    not bash -c "docker compose exec -T api env | grep -q '^PGPASSWORD='"

echo "== $pass passed, $fail failed"
[ "$fail" -eq 0 ]
