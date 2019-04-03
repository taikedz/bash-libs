#%include std/test.sh
#%include std/out.sh

out:warn "guiout.sh test | We can only really test that it builds properly..."

test:require bbuild libs/std/guiout.sh ./thing
rm ./thing

test:report
