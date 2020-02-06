#!/bin/bash

set -e

echo "--- dependencies"
. .expeditor/buildkite/cache_support.sh
install_cache_deps sudo

echo "--- pull bundle cache"
pull_bundle

echo "--- bundle"
bundle config git.allow_insecure true
bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3 --without tools maintenance deploy

echo "--- push bundle cache"
push_bundle

IN=$(bundle info --path inspec 2>/dev/null)
GEM="$PWD/Gemfile"

echo "+++ bundle exec rake ${RAKE_TASK:-test:unit}"

(
    cd "$IN"
    export SLOW=1
    export NO_AWS=1
    export CHEF_LICENSE=accept-no-persist

    # shellcheck disable=SC2086
    bundle exec --gemfile="$GEM" rake ${RAKE_TASK:-test:unit}
)
