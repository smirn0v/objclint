#!/usr/bin/python2.7

#######################
# Author: Alexander Smirnov
# Email: alexander@smirn0v.ru
#######################

import sys
import os
import string
from subprocess import call,check_output

def main():

    objclint_fake_cc="-objclint-fake-cc"
    objclint_fake_cxx="-objclint-fake-cxx"

    try:
        input_file = sys.argv[sys.argv.index("-c")+1]
    except:
        if "--print-diagnostic-categories" in sys.argv:
            try:
                sys.argv[0]="clang"
                call(sys.argv,stdout=sys.stdout,stderr=sys.stderr)
            except: pass
        sys.exit(0) # linker call should just succeed
    
    dependencies_file = None
    try:
        dependencies_file = sys.argv[sys.argv.index("-MF")+1]
    except: pass

    sys.argv[0] = os.path.dirname(os.path.realpath(__file__))+"/objclint-pseudo-compiler"

    if input_file == "/dev/null": 
        sys.argv[0] = "clang"
        if objclint_fake_cxx in sys.argv:
            sys.argv[0] = "clang++"
        try:
            sys.argv.remove(objclint_fake_cc)
            sys.argv.remove(objclint_fake_cxx)
        except: pass

    ret_value = call(sys.argv,stdout=sys.stdout,stderr=sys.stderr)

    if dependencies_file is not None:
        command = 'DEP="%s";DEP_DIR=`dirname "${DEP}"`;mkdir -p "${DEP_DIR}";echo ":" > "${DEP}"'%(dependencies_file)
        try:
            call(command, shell=True)
        except: pass

    sys.exit(ret_value)

if __name__ == "__main__":
    main()
