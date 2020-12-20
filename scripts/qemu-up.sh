#!/usr/bin/env bash

SMP=
MEM=
DISTRO=

say() {
    [ -t 2 ] && [ -n "$TERM" ] \
        && echo "$(tput setaf 7)$*$(tput sgr0)" \
        || echo "$*"
}

info() {
    [ -t 2 ] && [ -n "$TERM" ] \
        && echo "$(tput setaf 2)$*$(tput sgr0)" \
        || echo "$*"
}

err() {
    [ -t 2 ] && [ -n "$TERM" ] \
        && echo "$(tput setaf 1)$*$(tput sgr0)" \
        || echo "$*"
}

warn() {
    [ -t 2 ] && [ -n "$TERM" ] \
        && echo "$(tput setaf 3)$*$(tput sgr0)" \
        || echo "$*"
}

qemu_up() {
    if [[ -z $SMP ]]; then
        SMP=4
    fi

    if [[ -z $MEM ]]; then
        MEM=4G
    fi

    if [[ -z $distro ]]; then
        DISTRO="buster"
    fi

    echo "$SMP | $MEM | $DISTRO"

    # Assume x86 architecture
    if ! [[ -f "$PWD/arch/x86/boot/bzImage" ]]; then
        pushd ..
    fi

    echo "$PWD"

    qemu-system-x86_64 \
        -m $MEM \
        -smp $SMP \
        -kernel $PWD/arch/x86/boot/bzImage \
        -append "console=ttyS0 root=/dev/sda earlyprintk=serial" \
        -drive file=$HOME/$DISTRO.img,format=raw \
        -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
        -net nic,model=e1000 \
        -enable-kvm \
        -nographic
}

main() {
    while [ $# -gt 0 ]; do
        case $1 in
            -smp)
                if [[ -z $SMP ]]; then
                    shift
                    SMP=$1
                fi
                ;;
            -m)
                if [[ -z $MEM ]]; then
                    shift
                    MEM=$1
                fi
                ;;
            -d)
                if [[ -z $DISTRO ]]; then
                    shift
                    DISTRO=$1
                fi
                ;;
            *)
                warn "Unknown arguments"
        esac
        shift
    done

    qemu_up
}

main "$@"
