#!bin/bash
#
# Copyright 2019, Najahiiii <najahiii@outlook.co.id>
# Copyright 2019, alanndz <alanmahmud0@gmail.com>
# Copyright 2020, Dicky Herlambang "Nicklas373" <herlambangdicky5@gmail.com>
# Copyright 2016-2020, HANA-CI Build Project
#
# Clarity Kernel Builder Script || For Continous Integration
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

# Let's make some option here
#
# Kernel Name Release
# 0 = CAF || 1 = Clarity || 2 = Fusion (Co-operate with @alanndz)
#
# Kernel Type
# 0 = HMP || 1 = EAS
#
# Kernel Branch Relase
# 0 = BETA || 1 = Stable
#
# Kernel Android Version
# 0 = Pie || 1 = 10 || 2 = 9 - 10
#
# Kernel Codename
# 0 = Mido || 1 = Lavender
#
# Kernel Extend Defconfig
# 0 = Dev-Mido || 1 = Dev-Lave || 2 = Null
#
# Kernel Compiler
# 1 = Proton Clang 10.0.0
#
# CI Init
# 0 = Circle-CI || 1 = Drone-CI || 2 = Semaphore-CI
#
KERNEL_NAME_RELEASE="1"
KERNEL_TYPE="1"
KERNEL_BRANCH_RELEASE="0"
KERNEL_ANDROID_VERSION="1"
KERNEL_CODENAME="0"
KERNEL_EXTEND="0"
KERNEL_CI="1"

# Compiling For Mido // If mido was selected
if [ "$KERNEL_CODENAME" == "0" ];
	then
		# Create Temporary Folder
		mkdir TEMP

		if [ "$KERNEL_NAME_RELEASE" == "0" ];
			then
				# Clone kernel & other repositories earlier
				git clone --depth=1 -b pie https://github.com/Nicklas373/kernel_xiaomi_msm8953-3.18-2 kernel
				git clone --depth=1 -b caf/mido https://github.com/Nicklas373/AnyKernel3

				# Define Kernel Scheduler
				KERNEL_SCHED="HMP"
				KERNEL_BRANCH="pie"

		elif [ "$KERNEL_NAME_RELEASE" == "1" ];
			then
				# Clone kernel & other repositories earlier
				git clone --depth=1 -b dev/kasumi https://github.com/Nicklas373/kernel_xiaomi_msm8953-3.18-2 kernel

				# Define Kernel Scheduler
				KERNEL_SCHED="EAS"
				KERNEL_BRANCH="dev/kasumi"

				# Detect Android Version earlier and clone AnyKernel depend on android version
				if [ "$KERNEL_ANDROID_VERSION" == "0" ];
					then
						git clone --depth=1 -b mido https://github.com/Nicklas373/AnyKernel3
				else
						git clone --depth=1 -b mido-10 https://github.com/Nicklas373/AnyKernel3
				fi
		fi
# Compiling Repository For Lavender // If lavender was selected
elif [ "$KERNEL_CODENAME" == "1" ];
	then

		# Cloning Kernel Repository // If compiled by Drone CI or Semaphore CI
		if [ "$KERNEL_CI" == "1" ] || [ "$KERNEL_CI" == "2" ];
			then
				git clone --depth=1 -b fusion-eas-side https://Nicklas373:$token@github.com/Nicklas373/kernel_xiaomi_lavender-4.4 kernel
		fi

		# Cloning AnyKernel Repository
		git clone --depth=1 -b fusion https://github.com/alanndz/AnyKernel3

		# Create Temporary Folder
		mkdir TEMP

		# Define Kernel Scheduler
		KERNEL_SCHED="EAS"
		KERNEL_BRANCH="fusion-eas-side"
fi

# Kernel Enviroment
export ARCH=arm64
if [ "$KERNEL_CI" == "0" ];
	then
		KERNEL_BOT="Circle-CI"
elif [ "$KERNEL_CI" == "1" ];
	then
		KERNEL_BOT="Drone-CI"
elif [ "$KERNEL_CI" == "2" ];
	then
		KERNEL_BOT="Semaphore-CI"
fi

# Clang environment
export CLANG_PATH=/root/proton-10/bin
export PATH=${CLANG_PATH}:${PATH}
export LD_LIBRARY_PATH="/root/proton-10/bin/../lib:$PATH"

# Kernel host environment
if [ "$KERNEL_NAME_RELEASE" == "2" ];
	then
		export KBUILD_BUILD_USER=alanndz-nicklas373
		export KBUILD_BUILD_HOST=fusion_lavender-Dev
else
	export KBUILD_BUILD_USER=Kasumi
	export KBUILD_BUILD_HOST=${KERNEL_BOT}
fi

# Kernel directory environment
if [ "$KERNEL_CODENAME" == "0" ];
	then
		IMAGE="$(pwd)/kernel/out/arch/arm64/boot/Image.gz-dtb"
		KERNEL="$(pwd)/kernel"
		KERNEL_TEMP="$(pwd)/TEMP"
		CODENAME="mido"
		KERNEL_CODE="Mido"
		TELEGRAM_DEVICE="Xiaomi Redmi Note 4x"
elif [ "$KERNEL_CODENAME" == "1" ];
	then
	if [ "$KERNEL_CI" == "0" ];
		then
			KERNEL="$(pwd)"
			IMAGE="$(pwd)/out/arch/arm64/boot/Image.gz-dtb"
	else
		KERNEL="$(pwd)/kernel"
		IMAGE="$(pwd)/kernel/out/arch/arm64/boot/Image.gz-dtb"
	fi
	KERNEL_TEMP="$(pwd)/TEMP"
	CODENAME="lavender"
	KERNEL_CODE="Lavender"
	TELEGRAM_DEVICE="Xiaomi Redmi Note 7"
fi

# Kernel version environment
if [ "$KERNEL_NAME_RELEASE" == "0" ];
	then
		KERNEL_REV="r11"
		KERNEL_NAME="CAF"
elif [ "$KERNEL_NAME_RELEASE" == "1" ];
	then
		KERNEL_REV="r18"
		KERNEL_NAME="Clarity"
elif [ "$KERNEL_NAME_RELEASE" == "2" ];
	then
		KERNEL_REV="r2"
		KERNEL_NAME="Fusion"
fi
KERNEL_SUFFIX="Kernel"
KERNEL_DATE="$(date +%Y%m%d-%H%M)"
if [ "$KERNEL_ANDROID_VERSION" == "0" ];
	then
		KERNEL_ANDROID_VER="9"
		KERNEL_TAG="P"
elif [ "$KERNEL_ANDROID_VERSION" == "1" ];
	then
		KERNEL_ANDROID_VER="10"
		KERNEL_TAG="Q"
elif [ "$KERNEL_ANDROID_VERSION" == "2" ];
	then
		KERNEL_ANDROID_VER="9-10"
		KERNEL_TAG="P-Q"
fi
if [ "$KERNEL_BRANCH_RELEASE" == "1" ];
	then
		KERNEL_RELEASE="Stable"

		if [ "$KERNEL_NAME_RELEASE" == "2" ];
			then
				FUSION_CODENAME="Summer_Dream"
				KERNEL_VERSION="r2"
				KVERSION="${FUSION_CODENAME}-${KERNEL_VERSION}"
				ZIP_NAME="${KERNEL_NAME}-${KVERSION}-${CODENAME}-$(date "+%H%M-%d%m%Y").zip"
		fi
elif [ "$KERNEL_BRANCH_RELEASE" == "0" ];
	then
		KERNEL_RELEASE="BETA"

		if [ "$KERNEL_NAME_RELEASE" == "2" ];
			then
				FUSION_CODENAME="Summer_Dream"
				KERNEL_VERSION="r2"
				KVERSION="${FUSION_CODENAME}-$(git log --pretty=format:'%h' -1)-$(date "+%H%M")"
				ZIP_NAME="${KERNEL_NAME}-${FUSION_CODENAME}-${CODENAME}-$(git log --pretty=format:'%h' -1)-$(date "+%H%M").zip"
		fi
fi

# Telegram channel aliases
if [ "$KERNEL_CI" == "1" ];
	then
		TELEGRAM_BOT_ID=${tg_bot_id}
                if [ "$KERNEL_BRANCH_RELEASE" == "1" ];
			then
				TELEGRAM_GROUP_ID=${tg_channel_id}
                elif [ "$KERNEL_BRANCH_RELEASE" == "0" ];
                        then
                                TELEGRAM_GROUP_ID=${tg_group_id}
                fi
else
	TELEGRAM_BOT_ID=${telegram_bot_id}
	if [ "$KERNEL_BRANCH_RELEASE" == "1" ];
		then
			TELEGRAM_GROUP_ID=${telegram_group_official_id}
	elif [ "$KERNEL_BRANCH_RELEASE" == "0" ];
		then
			TELEGRAM_GROUP_ID=${telegram_group_dev_id}
                fi
fi
TELEGRAM_FILENAME="${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_SCHED}-${KERNEL_TAG}-${KERNEL_DATE}.zip"
export TELEGRAM_SUCCESS="CAADAgADDSMAAuCjggeXsvhpxp-R4xYE"
export TELEGRAM_FAIL="CAADAgADAiMAAuCjggeCh9mRFWEJ9RYE"

# Import telegram bot environment
function bot_env() {
TELEGRAM_KERNEL_VER=$(cat ${KERNEL}/out/.config | grep Linux/arm64 | cut -d " " -f3)
TELEGRAM_UTS_VER=$(cat ${KERNEL}/out/include/generated/compile.h | grep UTS_VERSION | cut -d '"' -f2)
TELEGRAM_COMPILER_NAME=$(cat ${KERNEL}/out/include/generated/compile.h | grep LINUX_COMPILE_BY | cut -d '"' -f2)
TELEGRAM_COMPILER_HOST=$(cat ${KERNEL}/out/include/generated/compile.h | grep LINUX_COMPILE_HOST | cut -d '"' -f2)
TELEGRAM_TOOLCHAIN_VER=$(cat ${KERNEL}/out/include/generated/compile.h | grep LINUX_COMPILER | cut -d '"' -f2)
}

# Telegram Bot Service || Compiling Notification
function bot_template() {
curl -s -X POST https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendMessage -d chat_id=${TELEGRAM_GROUP_ID} -d "parse_mode=HTML" -d text="$(
            for POST in "${@}"; do
                echo "${POST}"
            done
          )"
}

# Telegram bot message || first notification
function bot_first_compile() {
bot_template  "<b>|| ${KERNEL_BOT} Build Bot ||</b>" \
              "" \
	      "<b>${KERNEL_NAME} Kernel build Start!</b>" \
	      "" \
 	      "<b>Build Status :</b><code> ${KERNEL_RELEASE} </code>" \
              "<b>Device :</b><code> ${TELEGRAM_DEVICE} </code>" \
	      "<b>Android Version :</b><code> ${KERNEL_ANDROID_VER} </code>" \
	      "" \
	      "<b>Kernel Scheduler :</b><code> ${KERNEL_SCHED} </code>" \
	      "<b>Kernel Branch :</b><code> ${KERNEL_BRANCH} </code>" \
              "<b>Latest commit :</b><code> $(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1) </code>"
}

if [ "$KERNEL_NAME_RELEASE" == "0" ] || [ "$KERNEL_NAME_RELEASE" == "1" ];
	then

		# Telegram bot message || complete compile notification
		function bot_complete_compile() {
		bot_env
		bot_template  "<b>|| ${KERNEL_BOT} Build Bot ||</b>" \
    		"" \
    		"<b>New ${KERNEL_NAME} Kernel Build Is Available!</b>" \
    		"" \
    		"<b>Build Status :</b><code> ${KERNEL_RELEASE} </code>" \
    		"<b>Device :</b><code> ${TELEGRAM_DEVICE} </code>" \
    		"<b>Android Version :</b><code> ${KERNEL_ANDROID_VER} </code>" \
    		"<b>Filename :</b><code> ${TELEGRAM_FILENAME}</code>" \
     		"" \
    		"<b>Kernel Scheduler :</b><code> ${KERNEL_SCHED} </code>" \
    		"<b>Kernel Version:</b><code> Linux ${TELEGRAM_KERNEL_VER}</code>" \
    		"<b>Kernel Host:</b><code> ${TELEGRAM_COMPILER_NAME}@${TELEGRAM_COMPILER_HOST}</code>" \
    		"<b>Kernel Toolchain :</b><code> ${TELEGRAM_TOOLCHAIN_VER}</code>" \
    		"<b>UTS Version :</b><code> ${TELEGRAM_UTS_VER}</code>" \
    		"" \
    		"<b>Latest commit :</b><code> $(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1)</code>" \
    		"<b>Compile Time :</b><code> $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)</code>" \
    		"" \
    		"<b>                         HANA-CI Build Project | 2016-2020                            </b>"
		}
elif [ "$KERNEL_NAME_RELEASE" == "2" ];
	then
		function bot_complete_compile() {
		bot_env
		bot_template "<b>---- ${KERNEL_NAME} New Kernel ----</b>" \
    		"<b>Device:</b> ${CODENAME} or ${TELEGRAM_DEVICE}" \
    		"<b>Name:</b> <code>${KERNEL_NAME}-${KVERSION}</code>" \
    		"<b>Kernel Version:</b> <code>${TELEGRAM_KERNEL_VER}</code>" \
    		"<b>Type:</b> <code>${KERNEL_SCHED}</code>" \
    		"<b>Commit:</b> <code>$(git log --pretty=format:'%h : %s' -1)</code>" \
    		"<b>Started on:</b> <code>$(hostname)</code>" \
    		"<b>Compiler:</b> <code>${TELEGRAM_TOOLCHAIN_VER}</code>" \
    		"<b>Started at</b> <code>${KERNEL_DATE}</code>"
		}
fi
# Telegram bot message || success notification
function bot_build_success() {
bot_template  "<b>|| ${KERNEL_BOT} Build Bot ||</b>" \
              "" \
	      "<b>${KERNEL_NAME} Kernel build Success!</b>"
}

# Telegram bot message || failed notification
function bot_build_failed() {
bot_template "<b>|| ${KERNEL_BOT} Build Bot ||</b>" \
              "" \
	      "<b>${KERNEL_NAME} Kernel build Failed!</b>" \
              "" \
              "<b>Compile Time :</b><code> $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)</code>"
}

# Telegram sticker message
function sendStick() {
	curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_ID/sendSticker -d sticker="${1}" -d chat_id=$TELEGRAM_GROUP_ID &>/dev/null
}

# Compile Begin
function compile() {
	if [ "$KERNEL_CODENAME" == "0" ];
		then
			cd ${KERNEL}
			bot_first_compile
			cd ..
			if [ "$KERNEL_EXTEND" == "0" ];
				then
					sed -i -e 's/-友希那-Kernel-r18-LA.UM.8.6.r1-03400-89xx.0/-戸山-Kernel-r18-LA.UM.8.6.r1-03400-89xx.0/g'  ${KERNEL}/arch/arm64/configs/mido_defconfig
			fi
			START=$(date +"%s")
			make -s -C ${KERNEL} ${CODENAME}_defconfig O=out
			PATH="/root/proton-10/bin/:${PATH}" \
        		make -C ${KERNEL} -j$(nproc --all) -> ${KERNEL_TEMP}/compile.log O=out \
						CC=clang \
						CLANG_TRIPLE=aarch64-linux-gnu- \
		        			CROSS_COMPILE=aarch64-linux-gnu- \
						CROSS_COMPILE_ARM32=arm-linux-gnueabi-
			if ! [ -a $IMAGE ];
				then
                			echo "kernel not found"
                			END=$(date +"%s")
                			DIFF=$(($END - $START))
					cd ${KERNEL}
                			bot_build_failed
					cd ..
					sendStick "${TELEGRAM_FAIL}"
					curl -F chat_id=${TELEGRAM_GROUP_ID} -F document="@${KERNEL_TEMP}/compile.log"  https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendDocument
                			exit 1
        		fi
        		END=$(date +"%s")
        		DIFF=$(($END - $START))
			cd ${KERNEL}
			bot_build_success
			cd ..
			sendStick "${TELEGRAM_SUCCESS}"
			cp ${IMAGE} AnyKernel3
			anykernel
			kernel_upload
	elif [ "$KERNEL_CODENAME" == "1" ];
			then
				cd ${KERNEL}
				bot_first_compile
				cd ..
				START=$(date +"%s")
				make -s -C ${KERNEL} ${CODENAME}_defconfig O=out
				PATH="/root/clang-2/bin/:${PATH}" \
				make -C ${KERNEL} -j$(nproc --all) -> ${KERNEL_TEMP}/compile.log O=out \
							CC=clang \
							CLANG_TRIPLE=aarch64-linux-gnu- \
							CROSS_COMPILE=aarch64-linux-gnu- \
							CROSS_COMPILE_ARM32=arm-linux-gnueabi-
				if ! [ -a $IMAGE ];
					then
                				echo "kernel not found"
                				END=$(date +"%s")
                				DIFF=$(($END - $START))
                				bot_build_failed
						sendStick "${TELEGRAM_FAIL}"
						curl -F chat_id=${TELEGRAM_GROUP_ID} -F document="@${KERNEL_TEMP}/compile.log"  https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendDocument
               					exit 1
        			fi
       				END=$(date +"%s")
        			DIFF=$(($END - $START))
				bot_build_success
				sendStick "${TELEGRAM_SUCCESS}"
				if [ "$KERNEL_CI" == "1" ];
					then
						echo ""
				else
					cd ${KERNEL}
				fi
        			cp ${IMAGE} AnyKernel3
				anykernel
				kernel_upload
	fi
}

# AnyKernel
function anykernel() {
	cd AnyKernel3
	make -j4
	if [ "$KERNEL_NAME_RELEASE" == "2" ];
		then
			mv *.zip ${KERNEL_TEMP}/$ZIP_NAME
	else
		mv Clarity-Kernel-${KERNEL_CODE}-signed.zip  ${KERNEL_TEMP}/${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_SCHED}-${KERNEL_TAG}-${KERNEL_DATE}.zip
	fi
}

# Upload Kernel
function kernel_upload(){
	cd ${KERNEL}
	bot_complete_compile
	if [ "$KERNEL_NAME_RELEASE" == "2" ];
		then
			curl -F chat_id=${TELEGRAM_GROUP_ID} -F document="@${KERNEL_TEMP}/$ZIP_NAME" https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendDocument
	else
		curl -F chat_id=${TELEGRAM_GROUP_ID} -F document="@${KERNEL_TEMP}/${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_SCHED}-${KERNEL_TAG}-${KERNEL_DATE}.zip"  https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendDocument
	fi
	if [ "$KERNEL_BRANCH_RELEASE" == "0" ];
		then
			curl -F chat_id=${TELEGRAM_GROUP_ID} -F document="@${KERNEL_TEMP}/compile.log"  https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendDocument
	fi
}

# Running
compile
