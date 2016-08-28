#!/bin/bash

DEBUG=1

. /etc/rc.d/f4puppy5

[ "$CRYPT" ]  || CRYPT=aes
[ "$SIZE" ]   || SIZE=32       #MB
[ "$WDIR" ]   || WDIR='/tmp'
[ "$FILE" ]   || FILE=test_crypt
[ "$FSTYPE" ] || FSTYPE=ext2
#[ "$PASSW" ]  || PASSW=password
#[ "$PASSW" ]  || PASSW=word
#[ "$PASSW" ]  || PASSW=passwordpasswo
[ "$PASSW" ]  || PASSW=""
echo -n "$PASSW ":
echo "$PASSW" | wc -L

Q=

cd "$WDIR" || _exit 2 "Unable to cd into '$WDIR'"

_mk_file(){
_check_if_file_exists || return 1
dd if=/dev/zero of="$FILE" bs=1024 count=$((SIZE*1024))
}

_loop_setup(){
echo FINDING FREE LOOP
DEVLOOP=`losetup-FULL -f`
echo "IS FILE SETUP ALREADY?"
_check_if_file_setup && return 2
echo "IS LOOP SETUP ALREADY?"
_check_if_loop_setup && return 1
VERB=-v
echo "setting up .. $L_OP $DEVLOOP"
#echo "$PASSW" | losetup-FULL $VERB -p 0 $L_OP $DEVLOOP "$FILE"
#echo "$PASSW" | /usr/local/sbin/losetup $VERB -p 0 $L_OP $DEVLOOP "$FILE"

echo "$PASSW" | /sbin/losetup -v -v -p 0 $L_OP $DEVLOOP "$FILE"
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
mkfs.$FSTYPE -m 0 "$DEVLOOP" # -y FILE
;;
*) ;;
esac
}

_mnt_file(){
MNTDIR=/mnt/${FILE##*/}
_check_if_file_mounted && return 1
_check_if_loop_mounted && return 2
mkdir -p $MNTDIR
mount -t $FSTYPE $DEVLOOP $MNTDIR
}

_main(){
_mk_file    || _exit 3 "Failure @_mk_file"
_loop_setup || { losetup $VERB -d $DEVLOOP 2>>$ERR; rm $VERB -f "$FILE"; _exit 4 "Failure @_loop_setup"; }
#_loop_setup || _exit 4 "Failure @_loop_setup"
_mk_fs      || _exit 5 "Failure @_mk_fs"
_mnt_file   || _exit 6 "Failure @_mnt_file"
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
#static struct crypto_alg des_algs[2] = { {
#	.cra_name		=	"des",

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

cast128)
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP='-E 5' #does not work to setup
FILE=${FILE}_cast.$FSTYPE
;;
#The CAST5 encryption algorithm (synonymous with CAST-128) is described in RFC2144.
cast5)
_check_if_crypt_driver_available && modprobe -v $CRYPT
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/cast5.ko
modprobe -v $CRYPT
L_OP="-e cast5" #does not work to setup
FILE=${FILE}_cast5.$FSTYPE
;;

cast6)
_check_if_crypt_driver_available && modprobe -v $CRYPT
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/cast6.ko
modprobe -v $CRYPT
L_OP="-e cast6"
FILE=${FILE}_cast6.$FSTYPE
;;

idea)
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP='-E 6' #does not work to setup
FILE=${FILE}_idea.$FSTYPE
;;

dummy)
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP='-E 9' #does not work to setup
FILE=${FILE}_dummy.$FSTYPE
;;

skipjack)
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP='-E 10' #does not work to setup
FILE=${FILE}_skip.$FSTYPE
;;

aes)
_check_if_crypt_driver_available && modprobe -v $CRYPT
#modprobe -v aes_generic
#modprobe -v crypto_blkcipher #v407 blkcipher name change.
#modprobe -v cbc
L_OP="-e aes"
FILE=${FILE}_aes.$FSTYPE
;;

anubis)
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
FILE=${FILE}_anu.$FSTYPE
;;

arc4) #does not mount
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
FILE=${FILE}_arc.$FSTYPE
;;

blowfish)
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/blowfish_common.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/blowfish_generic.ko

_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
#L_OP='-E 4'  #does not work to setup
FILE=${FILE}_bf.$FSTYPE
;;

twofish)
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/twofish_common.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/arch/x86/crypto/twofish-i586.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/twofish_generic.ko

_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
#L_OP='-E 3' #does not work to setup
FILE=${FILE}_tf.$FSTYPE
;;

camellia)
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
FILE=${FILE}_cam.$FSTYPE
;;

ecrypt)
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/security/keys/trusted.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/security/keys/encrypted-keys/encrypted-keys.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/fs/ecryptfs/ecryptfs.ko

_check_if_crypt_driver_available && modprobe -v ${CRYPT}fs
L_OP="-e $CRYPT"  #does not work to setup
FILE=${FILE}_ecrypt.$FSTYPE
;;

fcrypt)
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/fcrypt.ko
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"  #does not work to setup
FILE=${FILE}_fcrypt.$FSTYPE
;;

khazad)
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"  #does not work to setup
FILE=${FILE}_khaz.$FSTYPE
;;

salsa)
#FATAL: Module salsa not found.
#_check_if_crypt_driver_available && modprobe -v $CRYPT
modprobe -v salsa20-i586
modprobe -v salsa20_generic
#L_OP="-e $CRYPT"  #does not work to setup
L_OP="-e salsa20"  #does not work to setup
FILE=${FILE}_salsa20.$FSTYPE
;;

serpent)
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/gf128mul.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/xts.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/serpent_generic.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/lrw.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/cryptd.ko
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/arch/x86/crypto/serpent-sse2-i586.ko
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
FILE=${FILE}_ser.$FSTYPE
;;

tcrypt)   #Quick & dirty crypto testing module
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/tcrypt.ko
#FATAL: Error inserting tcrypt (/lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/tcrypt.ko): Resource #temporarily unavailable
# Need slab memory for testing (size in number of pages).
static char *check[] = {
#	"des", "md5", "des3_ede", "rot13", "sha1", "sha224", "sha256",
#	"blowfish", "twofish", "serpent", "sha384", "sha512", "md4", "aes",
#	"cast6", "arc4", "michael_mic", "deflate", "crc32c", "tea", "xtea",
#	"khazad", "wp512", "wp384", "wp256", "tnepres", "xeta",  "fcrypt",
#	"camellia", "seed", "salsa20", "rmd128", "rmd160", "rmd256", "rmd320",
#	"lzo", "cts", "zlib", NULL
#};

_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT" #does not work to setup
FILE=${FILE}_tcrypt.$FSTYPE
;;

tea)
#insmod /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz/kernel/crypto/tea.ko
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"  #does not work to setup
#L_OP='-e xtea'    #does not work to setup
#L_OP='-e xeta'    #does not work to setup
#L_OP='-e xeta -N -k 8' #does not work to setup
#L_OP="-e xor"
FILE=${FILE}_tea.$FSTYPE
;;

'')
_exit 1 "CRYPT variable unset."
;;

*)
_check_if_crypt_driver_available && modprobe -v $CRYPT
L_OP="-e $CRYPT"
FILE=${FILE}_$CRYPT.$FSTYPE
#_exit 1 "Unsupported or unknown encryption '$CRYPT'"
;;

esac

_main
echo $?
