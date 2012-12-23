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
#    sys.stdout = open('log', 'a')
#    sys.stderr = sys.stdout

    objclint_fake_cc="-objclint-fake-cc"
    objclint_fake_cxx="-objclint-fake-cxx"

    try:
        input_file = sys.argv[sys.argv.index("-c")+1]
    except:
        sys.exit(0) # linker call should just succeed
    
    dependencies_file = None
    try:
        dependencies_file = sys.argv[sys.argv.index("-MF")+1]
    except: pass

    new_argvs = sys.argv
    new_argvs[0] = "/opt/local/bin/objclint-fake-compiler"

    if input_file == "/dev/null":
        new_argvs[0] = "clang"
        if objclint_fake_cxx in new_argvs:
            new_argvs[0] = "clang++"
        try:
            new_argvs.remove(objclint_fake_cc)
            new_argvs.remove(objclint_fake_cxx)
        except: pass

    ret_value = call(new_argvs,stdout=sys.stdout,stderr=sys.stderr)

    if dependencies_file is not None:
        command = 'DEP="%s";DEP_DIR=`dirname "${DEP}"`;mkdir -p "${DEP_DIR}";echo ":" > "${DEP}"'%(dependencies_file)
        try:
            call(command, shell=True)
        except: pass

    sys.exit(ret_value)

if __name__ == "__main__":
    main()
