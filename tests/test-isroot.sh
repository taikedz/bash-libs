#%include std/test.sh
#%include std/isroot.sh
#%include std/out.sh

if [[ "$UID" = "0" ]]; then
    test:require isroot
else
    test:forbid isroot
fi

out:warn "You need to run this test both as root and not as root to cover all cases"

test:report
