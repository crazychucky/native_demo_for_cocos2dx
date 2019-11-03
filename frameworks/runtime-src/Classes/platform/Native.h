#ifndef __CAESARS_PLATFORM_NATIVE_H_
#define __CAESARS_PLATFORM_NATIVE_H_

#define _CPP_VER_ 7   //cpp code base version

class Native
{
public:
    static int getCPPVer() {
        return _CPP_VER_;
    };
    static void pickPhoto();
    static void takePhoto();
private:
    Native(void){};
};

#endif // __CAESARS_PLATFORM_NATIVE_H_
