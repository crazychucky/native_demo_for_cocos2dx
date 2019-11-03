#include "../Native.h"
#include "platform/CCApplication.h"
#include "base/CCDirector.h"
#include "base/CCEventDispatcher.h"
#include "base/CCEventCustom.h"
#include "base/ccUTF8.h"

#include "../ImagePicker.h"

void Native::pickPhoto() {
    ImagePicker::getInstance()->callImagePickerWithPhotoAndCamera([=](std::string path)
    {
		CCLOG("%s", path.c_str());
    });
}

void Native::takePhoto() {
}
