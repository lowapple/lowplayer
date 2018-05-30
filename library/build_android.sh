#!/bin/bash -e

# build_android.sh

set -x

if [ "$ANDROID_NDK_HOME" = "" ]; then
	echo ANDROID_NDK_HOME variable not set, exiting
	echo "Use: export ANDROID_NDK_HOME=/your/path/to/android-ndk"
	exit 1
fi

# Get the newest arm-linux-androideabi version
if [ -z "$COMPILATOR_VERSION" ]; then
	DIRECTORIES=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-*
	for i in $DIRECTORIES; do
		PROPOSED_NAME=${i#*$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-}
		if [[ $PROPOSED_NAME =~ ^[0-9\.]+$ ]] ; then
			echo "Available compilator version: $PROPOSED_NAME"
			COMPILATOR_VERSION=$PROPOSED_NAME
		fi
	done
fi

if [ -z "$COMPILATOR_VERSION" ]; then
	echo "Could not find compilator"
	exit 1
fi

if [ ! -d $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION ]; then
	echo $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION does not exist
	exit 1
fi
echo "Using compilator version: $COMPILATOR_VERSION"

OS_ARCH=`basename $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/*`
echo "Using architecture: $OS_ARCH"


function setup_paths
{
	export PLATFORM=$ANDROID_NDK_HOME/platforms/$PLATFORM_VERSION/arch-$ARCH/
	if [ ! -d $PLATFORM ]; then
		echo $PLATFORM does not exist
		exit 1
	fi
	echo "Using platform: $PLATFORM"
	export PATH=${PATH}:$PREBUILT/bin/
	export CROSS_COMPILE=$PREBUILT/bin/$EABIARCH-
	export CFLAGS=$OPTIMIZE_CFLAGS
	export CPPFLAGS="$CFLAGS"
	export CFLAGS="$CFLAGS"
	export CXXFLAGS="$CFLAGS"
	export CXX="${CROSS_COMPILE}g++ --sysroot=$PLATFORM"
	export AS="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
	export CC="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
	export PKG_CONFIG="${CROSS_COMPILE}pkg-config"
	export LD="${CROSS_COMPILE}ld"
	export NM="${CROSS_COMPILE}nm"
	export STRIP="${CROSS_COMPILE}strip"
	export RANLIB="${CROSS_COMPILE}ranlib"
	export AR="${CROSS_COMPILE}ar"
	export LDFLAGS="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog"
	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig/
	export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/

	if [ ! -f "${CROSS_COMPILE}gcc" ]; then
		echo "Gcc does not exists in path: ${CROSS_COMPILE}gcc"
		exit 1;
	fi

	if [ ! -f "${PKG_CONFIG}" ]; then
		echo "Pkg config does not exists in path: ${PKG_CONFIG} - Probably BUG in NDK but..."
		set +e
		SYS_PKG_CONFIG=$(which pkg-config)
		if [ "$?" -ne 0 ]; then
			echo "This system does not contain system pkg-config, so we can do anything"
			exit 1
		fi
		set -e
		cat > $PKG_CONFIG << EOF
#!/bin/bash
pkg-config \$*
EOF
		chmod u+x $PKG_CONFIG
		echo "Because we have local pkg-config we will create it in ${PKG_CONFIG} directory using ${SYS_PKG_CONFIG}"
	fi
}

function build_ffmpeg
{
	echo "Starting build ffmpeg for $ARCH"
	cd ffmpeg
    ./configure \
 		--target-os=linux \
	    --prefix=$PREFIX \
	    --enable-cross-compile \
	    --extra-libs="-lgcc" \
	    --arch=$ARCH \
	    --cc=$CC \
	    --cross-prefix=$CROSS_COMPILE \
	    --nm=$NM \
	    --sysroot=$PLATFORM \
	    --extra-cflags=" -O3 -fpic -DANDROID -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums  -fno-strict-aliasing -finline-limit=300 $OPTIMIZE_CFLAGS " \
	    --disable-shared \
	    --enable-static \
	    --enable-runtime-cpudetect \
	    --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib  -nostdlib -lc -lm -ldl -llog -L$PREFIX/lib" \
	    --extra-cflags="-I$PREFIX/include" \
	    --disable-everything \
	    --enable-pthreads \
	    --enable-decoders \
	    --enable-encoders \
	    --enable-parsers \
	    --enable-hwaccels \
	    --enable-muxers \
	    --enable-avformat \
	    --enable-avcodec \
	    --enable-avresample \
	    --disable-doc \
	    --disable-ffplay \
	    --disable-ffmpeg \
	    --disable-ffplay \
	    --disable-ffprobe \
	    --disable-avfilter \
	    --disable-avdevice \
	    $ADDITIONAL_CONFIGURE_FLAG
	make clean
	make -j4 install
	make clean

	cd ..
	echo "FINISHED ffmpeg for $ARCH"
}

function build_one {
	echo "Starting build one for $ARCH"
	cd ffmpeg
	${LD} -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -L$PREFIX/lib  -soname $SONAME -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o $OUT_LIBRARY -lavcodec -lavformat -lavresample -lavutil -lswresample -lswscale -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker -zmuldefs $PREBUILT/lib/gcc/$EABIARCH/$COMPILATOR_VERSION/libgcc.a
	cd ..
	echo "FINISHED one for $ARCH"
}

#arm v7 + neon (neon also include vfpv3-32)
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8 -mthumb -D__thumb__ "
PREFIX=$(pwd)/ffmpeg-build/armeabi-v7a-neon
OUT_LIBRARY=../ffmpeg-build/armeabi-v7a/libffmpeg-neon.so
ADDITIONAL_CONFIGURE_FLAG=--enable-neon
SONAME=libffmpeg-neon.so
PREBUILT=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
PLATFORM_VERSION=android-9
setup_paths
build_ffmpeg
build_one


echo "BUILD SUCCESS"
