#%include std/test.sh
#%include std/event.sh

print_foo() {
    echo -n "foo@$1:$2/$3|"
}

print_bar() {
    echo -n "bar@$1:$2/$3|"
}

event_has() {
    local funcs="${STD_EVENT_LIB_EVENTS[$1]}"
    echo "$funcs"
    [[ "$funcs" =~ "$2" ]]
}

trigger_output() {
    local got res
    res=0
    got="$(event:trigger "$1" "$2" "$3")" || res="$?"
    echo "$got"

    if [[ ! "$res" = 0 ]]; then
        return "$res"
    else
        [[ "$got" = "$4" ]]
    fi
}

event:subscribe print_foo a b
event:subscribe print_bar a c

# Duplicate should be ignored
event:subscribe print_bar c

test:require event_has a print_foo
test:require event_has b print_foo
test:require event_has a print_bar

test:forbid  event:subscribe "bad function" b c
test:forbid event:subscribe print_foo "bad event"

# Specifically foo before bar
test:require trigger_output a one two "foo@a:one/two|bar@a:one/two|"
test:require trigger_output b one two "foo@b:one/two|"
test:require trigger_output c one two "bar@c:one/two|"
test:forbid  trigger_output "bad event"

test:report
