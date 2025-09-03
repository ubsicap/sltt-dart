
# test if in context of `source offline_export_pub_cache.sh`
# if so, set the vendored cache path (repo root) else echo instructions how to call using source
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    export PUB_CACHE="$PWD/vendor/pub-cache"
    echo "Using vendored pub cache: $PUB_CACHE"
    echo ""
else
    echo "Please run this script using 'source ${0}' to set the PUB_CACHE environment variable in your current shell."
    echo "Example: source ${0}"
    echo ""
    exit 1
fi
