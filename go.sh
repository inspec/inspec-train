#!/bin/bash

set -e

if [ -n "${UPDATE:-}" -o \! -d vendor/bundle ]; then
    bundle config --local path $PWD/vendor/bundle
    bundle install --jobs 7 --retry 3
fi

IN=$(bundle info --path inspec)
GEM=$PWD/Gemfile

(
    cd $IN
    export SLOW=1
    export NO_AWS=1
    export CHEF_LICENSE=accept-no-persist

    bundle exec --gemfile=$GEM rake ${RAKE_TASK:-test:unit}
)
