#!/bin/ash

DEBUG=1

. /etc/rc.d/f4puppy5

[ "$CRYPT" ]  || CRYPT=aes        #crypt avail: aes|anubis|blowfish|twofish|camellia|serpent
[ "$SIZE" ]   || SIZE=32          # MB
[ "$WDIR" ]   || WDIR='/tmpP'      # working dir
[ "$FILE" ]   || FILE=test_cryptaes  # file basename
[ "$FSTYPE" ] || FSTYPE=ext2      # f.s. type to be created
[ "$PASSW" ]  || PASSW=password   # password
#[ "$PASSW" ]  || PASSW=word            # keysize test
#[ "$PASSW" ]  || PASSW=passwordpasswo  # dito
#[ "$PASSW" ]  || PASSW=""

echo -n "$PASSW ":
echo "$PASSW" | wc -L  #DEBUG for key size

Q= #DEBUG or -q option for grep

cd "$WDIR" || _exit 2 "Unable to cd into '$WDIR'"

_mk_file(){
_check_if_file_exists || return 1
dd if=/dev/zero of="$FILE" bs=1024 count=$((SIZE*1024))
}

_loop_setup(){
echo FINDING FREE LOOP
_mk_free_loop
DEVLOOP=`losetup-FULL -f 2>>$ERR` || return 4
test "$DEVLOOP"           || return 3
test -b "$DEVLOOP"        || return 3
echo "IS FILE SETUP ALREADY?"
_check_if_file_setup && return 2
echo "IS LOOP SETUP ALREADY?"
_check_if_loop_setup && return 1
VERB=-v
echo "setting up .. $L_OP $DEVLOOP"
echo "$PASSW" | losetup-FULL $VERB -p 0 $L_OP $DEVLOOP "$FILE"
#echo "$PASSW" | /usr/local/sbin/losetup $VERB -p 0 $L_OP $DEVLOOP "$FILE"

#echo "$PASSW" | /sbin/losetup $VERB $VERB -p 0 $L_OP $DEVLOOP "$FILE"
# -N | --nohashpass        Do not hash the given password (Debian hashes)
# -k | --keybits <num>     specify number of bits in the hashed key given
#                          to the cipher.  Some ciphers support several key
#                          sizes and might be more efficient with a smaller
#                          key size.  Key sizes < 128 are generally not
#                          recommended
#strace -o /tmp/losetup.strace losetup-FULL $VERB $L_OP $DEVLOOP "$FILE"

}

_mk_fs(){
case $FSTYPE in
ext[2-4])
mkfs.$FSTYPE $Q -m 0 "$DEVLOOP" # -y FILE
;;
*) return 1;;
esac
}

_mnt_file(){
MNTDIR=/mnt/${FILE##*/}
_check_if_file_mounted && return 1
_check_if_loop_mounted && return 2
mkdir -p "$MNTDIR"
/bin/mount -t $FSTYPE $DEVLOOP "$MNTDIR"
}

_main(){
_mk_file    || _exit 3 "Failure @_mk_file"
_loop_setup || { [ -b "$DEVLOOP" ] && losetup $VERB -d $DEVLOOP 2>>$ERR; rm $VERB -f "$FILE"; _exit 4 "Failure @_loop_setup"; }
#_loop_setup || _exit 4 "Failure @_loop_setup"
_mk_fs      || _exit 5 "Failure @_mk_fs"
#_mnt_file   || _exit 6 "Failure @_mnt_file"
[ -b "$DEVLOOP" ] && losetup $VERB -d $DEVLOOP 2>>$ERR
}

_check_if_file_exists(){
    FILE="$WDIR"/"$FILE"
    rFILE=`realpath "$FILE"` 2>>$ERR || return 0;
    FILE="$rFILE"
    echo "$FILE"
    if test -e "$FILE"; then false
    else true; fi
    }

_check_if_file_mounted(){
    echo -e "`cut -f2 -d' ' /proc/mounts`" | grep $Q "^${MNTDIR}$"; }

_check_if_file_setup(){
    echo "$FILE"
    losetup -a | grep $Q -w "$FILE"; }

_check_if_loop_mounted(){
    echo -e "`cut -f1 -d' ' /proc/mounts`" | grep $Q "^${DEVLOOP}$"; }

_check_if_loop_setup(){
    losetup -a | grep $Q -w "$DEVLOOP"; }

_check_if_crypt_driver_available(){
grep $Q "${CRYPT}"      /proc/crypto && return 0
grep $Q "${CRYPT//-/_}" /proc/crypto && return 0
grep $Q "${CRYPT//_/-}" /proc/crypto && return 0
modprobe -l | grep $Q -E "${CRYPT}|${CRYPT//-/_}|${CRYPT//_/-}"
 }

_check_if_crypt_driver_loaded(){ :; }


case $CRYPT in
cloop )
_check_if_crypt_driver_available && modprobe -v cryptoloop
L_OP='-E 1'
FILE=${FILE}_E1.$FSTYPE
;;

des)
_exit 4 "$CRYPT not supported"
#static struct crypto_alg des_algs[2] = { {
#   .cra_name       =   "des",

#MODULE_ALIAS("des3_ede");

#/*
# * Encryption key expansion
# *
# * RFC2451: Weak key checks SHOULD be performed.
# *
# * FIPS 74:
# *
# *   Keys having duals are keys which produce all zeros, all ones, or
# *   alternating zero-one patterns in the C and D registers after Permuted
# *   Choice 1 has operated on the key.
# *
#*/
#/*
# * Decryption key expansion
# *
# * No weak key checking is performed, as this is only used by triple DES
# *
#*/

_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e des3_ede" #does not work to setup
#L_OP="-e des3" #does not work to setup
#L_OP="-e des" #does not work to setup
#L_OP='-E 2'   #does not work to setup
FILE=${FILE}_des.$FSTYPE
;;

#The CAST5 encryption algorithm (synonymous with CAST-128) is described in RFC2144.
cast*128|cast*5)
_exit 4 "$CRYPT not supported"
CRYPT=cast5
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP='-E 5'     #does not work to setup
L_OP="-e cast5" #does not work to setup
FILE=${FILE}_cast128.$FSTYPE
;;

cast*256|cast*6)
CRYPT=cast6
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e cast6"
FILE=${FILE}_cast256.$FSTYPE
;;

aes|anubis|blowfish|twofish|camellia|serpent)
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
FILE=${FILE}_$CRYPT.$FSTYPE
;;

arc4) #does not mount
_exit 4 "$CRYPT does not mount"
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
FILE=${FILE}_$CRYPT.$FSTYPE
;;

'')
_exit 1 "CRYPT variable unset."
;;

*)
#_exit 1 "Unsupported or unknown encryption '$CRYPT'"
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
FILE=${FILE}_$CRYPT.$FSTYPE
;;

esac

_main
echo $?
