package main

/*
#include <stdlib.h>
*/
import "C"
import "unsafe"

//export KubenavCall
func KubenavCall(methodC, argsC *C.char) *C.char {
	return C.CString(Dispatch(C.GoString(methodC), C.GoString(argsC)))
}

//export KubenavFree
func KubenavFree(value *C.char) {
	if value != nil {
		C.free(unsafe.Pointer(value))
	}
}
