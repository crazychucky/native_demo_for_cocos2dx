#ifndef _IMAGEPICKER_H_
#define _IMAGEPICKER_H_

#include "cocos2d.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#endif	// CC_PLATFORM_ANDROID

class ImagePicker
{
public:
    static ImagePicker* getInstance();

    static void destoryInstance();
public:
    void callImagePickerWithPhotoAndCamera(const std::function<void(std::string)>& callback);
    
    void setListener(const std::function<void(std::string)>& callback);
    
    void removeListener();
    
    void openPhoto();
    
    void openCamera();
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    void setViewController(void* viewController);
#endif // CC_PLATFORM_IOS

protected:
    bool init();
    
    ImagePicker();
    
protected:
    std::function<void(std::string)> m_callback;
    static ImagePicker* s_instance;
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    void* m_viewController;
#endif // CC_PLATFORM_IOS
    
};

#endif // _IMAGEPICKER_H_
