.PHONY: bindings-android
bindings-android:
	mkdir -p android/app/src/libs
	go tool gomobile bind -ldflags="-extldflags=-Wl,-z,max-page-size=16384" -o android/app/src/libs/kubenav.aar -target=android -androidapi=24 github.com/kubenav/kubenav/cmd/kubenav

.PHONY: bindings-ios
bindings-ios:
	mkdir -p ios/Runner/libs
	go tool gomobile bind -o ios/Runner/libs/Kubenav.xcframework -target=ios github.com/kubenav/kubenav/cmd/kubenav

# HarmonyOS shared library. Uses the OpenHarmony LLVM from DevEco Studio and
# does not touch the Android or iOS gomobile bindings.
OHOS_NATIVE ?= /Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native

# GOOS=android stores the goroutine pointer in a pthread TLS slot. GOOS=linux uses
# initial-exec TLS, which HarmonyOS musl rejects when the library is dlopen'd.
.PHONY: bindings-ohos
bindings-ohos:
	mkdir -p ohos/entry/libs/arm64-v8a ohos/entry/src/main/cpp/prebuilt/arm64-v8a ohos/.build
	printf '%s\n' 'void kubenav_liblog_stub(void) {}' > ohos/.build/logstub.c
	"$(OHOS_NATIVE)/llvm/bin/aarch64-unknown-linux-ohos-clang" --target=aarch64-linux-ohos --sysroot="$(OHOS_NATIVE)/sysroot" -c ohos/.build/logstub.c -o ohos/.build/logstub.o
	"$(OHOS_NATIVE)/llvm/bin/llvm-ar" rcs ohos/.build/liblog.a ohos/.build/logstub.o
	CC="$(OHOS_NATIVE)/llvm/bin/aarch64-unknown-linux-ohos-clang" \
	CXX="$(OHOS_NATIVE)/llvm/bin/aarch64-unknown-linux-ohos-clang++" \
	AR="$(OHOS_NATIVE)/llvm/bin/llvm-ar" \
	GOOS=android GOARCH=arm64 CGO_ENABLED=1 \
	CGO_CFLAGS="--target=aarch64-linux-ohos --sysroot=$(OHOS_NATIVE)/sysroot" \
	CGO_LDFLAGS="--target=aarch64-linux-ohos --sysroot=$(OHOS_NATIVE)/sysroot -fuse-ld=lld -L$(CURDIR)/ohos/.build" \
	go build -tags netgo,osusergo -ldflags "-s -w" -buildmode=c-shared -o ohos/entry/libs/arm64-v8a/libkubenav.so ./cmd/kubenavohos
	cp ohos/entry/libs/arm64-v8a/libkubenav.so ohos/entry/src/main/cpp/prebuilt/arm64-v8a/libkubenav.so
	rm -f ohos/entry/libs/arm64-v8a/libkubenav.h ohos/entry/src/main/cpp/prebuilt/arm64-v8a/libkubenav.h
