# set the vendored cache path (repo root)
export PUB_CACHE="$PWD/vendor/pub-cache"

# offline pub get for sltt_core and save log
cd packages/sltt_core
PUB_CACHE="$PUB_CACHE" dart pub get --offline 2>&1 | tee ../../pubget-sltt_core-offline.log

# run build_runner using the vendored cache and save log
PUB_CACHE="$PUB_CACHE" dart run build_runner build --delete-conflicting-outputs 2>&1 | tee ../../build-sltt_core-offline.log

# optional: run the project's test setup (this script sets up Isar native libs)
# run this from repo root (not inside packages/sltt_core)
# cd "$PWD/.." # back to repo root
# PUB_CACHE="$PUB_CACHE" ./test.sh packages/sltt_core 2>&1 | # tee test-sltt_core-offline.log
