#include "lua_caesars_engine_auto.hpp"
#include "platform/Native.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"

int lua_caesars_engine_Native_getCPPVer(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Native",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_caesars_engine_Native_getCPPVer'", nullptr);
            return 0;
        }
        int ret = Native::getCPPVer();
        tolua_pushnumber(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Native:getCPPVer",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_caesars_engine_Native_getCPPVer'.",&tolua_err);
#endif
    return 0;
}
int lua_caesars_engine_Native_pickPhoto(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Native",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        // cocos2d::caesars::ScriptCallback* arg0;

        // ok &= luaval_to_object<cocos2d::caesars::ScriptCallback>(tolua_S, 2, "ScriptCallback",&arg0, "Native:pickPhoto");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_caesars_engine_Native_pickPhoto'", nullptr);
            return 0;
        }
        Native::pickPhoto();
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Native:pickPhoto",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_caesars_engine_Native_pickPhoto'.",&tolua_err);
#endif
    return 0;
}
int lua_caesars_engine_Native_takePhoto(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Native",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    // if (argc == 1)
    if (argc == 0)
    {
        // cocos2d::caesars::ScriptCallback* arg0;

        // ok &= luaval_to_object<cocos2d::caesars::ScriptCallback>(tolua_S, 2, "ScriptCallback",&arg0, "Native:takePhoto");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_caesars_engine_Native_takePhoto'", nullptr);
            return 0;
        }
        Native::takePhoto();
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Native:takePhoto",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_caesars_engine_Native_takePhoto'.",&tolua_err);
#endif
    return 0;
}
static int lua_caesars_engine_Native_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Native)");
    return 0;
}

int lua_register_caesars_engine_Native(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"Native");
    tolua_cclass(tolua_S,"Native","Native","",nullptr);

    tolua_beginmodule(tolua_S,"Native");
        tolua_function(tolua_S,"getCPPVer", lua_caesars_engine_Native_getCPPVer);
        tolua_function(tolua_S,"takePhoto", lua_caesars_engine_Native_takePhoto);
        tolua_function(tolua_S,"pickPhoto", lua_caesars_engine_Native_pickPhoto);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Native).name();
    g_luaType[typeName] = "Native";
    g_typeCast["Native"] = "Native";
    return 1;
}

TOLUA_API int register_all_caesars_engine(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,nullptr,0);
	tolua_beginmodule(tolua_S,nullptr);

	lua_register_caesars_engine_Native(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

