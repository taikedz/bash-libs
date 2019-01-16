#%include std/test.sh
#%include std/log.sh

n2="[0-9]{2}"
datepattern="[0-9]{4}-$n2-$n2 $n2:$n2:$n2"

stdout() { "$@" 2>&1; }

log:level info
test:require test:output 2 echo "$LOG_LEVEL_INFO"

log:get_level --loglevel=warn

test:require test:output 1 echo "$LOG_LEVEL_WARN"
test:require test:output '' stdout log:debug "test"
test:require test:output-match "^$LOGENTITY $datepattern WARN: test" stdout log:warn "test"

test:report
