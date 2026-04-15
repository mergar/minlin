mkdir -p my-unikernel
cc a.c -oapp -static
cp ./app my-unikernel/app
