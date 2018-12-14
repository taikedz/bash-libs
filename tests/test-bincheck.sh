#%include std/test.sh
#%include std/bincheck.sh

test:require bincheck:get bash
test:forbid bincheck:get "does not exist"

test:require bincheck:has bash
test:forbid bincheck:has "does not exit"

test:report
