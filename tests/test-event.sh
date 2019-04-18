#%include std/test.sh
#%include std/event.sh

print_foo() {
    echo -n "foo:$1/$2|"
}

print_bar() {
    echo -n "bar:$1/$2|"
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

test:require event_has a print_foo
test:require event_has b print_foo
test:require event_has a print_bar

test:forbid  event:subscribe "bad function" b c
test:forbid event:subscribe print_foo "bad event"

test:require trigger_output a one two "foo:one/two|bar:one/two|"
test:require trigger_output b one two "foo:one/two|"
test:forbid  trigger_output "bad event"

test:report