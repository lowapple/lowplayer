LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE    := sample_ffmpeg
LOCAL_SRC_FILES := sample_ffmpeg.c
LOCAL_LDLIBS := -llog
LOCAL_SHARED_LIBRARIES := libavformat libavcodec libswscale libavutil libswresample libavfilter
include $(BUILD_SHARED_LIBRARY)
$(call import-module, ffmpeg-3.2.10/android/arm)
