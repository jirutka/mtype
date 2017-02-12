#include <lua.h>
#include <lauxlib.h>
#include <stddef.h>


#if !defined(LUA_VERSION_NUM) || LUA_VERSION_NUM == 501  // Lua 5.1

#define LUA_FILEHANDLE "FILE*"

// Copied from lua-compat-5.1.
void *luaL_testudata (lua_State *L, int i, const char *tname) {
    void *p = lua_touserdata(L, i);
    luaL_checkstack(L, 2, "not enough stack slots");

    if (p == NULL || !lua_getmetatable(L, i)) {
        return NULL;
    } else {
        int res = 0;
        luaL_getmetatable(L, tname);
        res = lua_rawequal(L, -1, -2);
        lua_pop(L, 2);
        if (!res) {
            p = NULL;
        }
    }
    return p;
}
#endif


static int mtype(lua_State *L) {
    luaL_checkany(L, 1);
    luaL_checkstack(L, 2, "not enough stack slots");

    int t = lua_type(L, 1);

    if ((t == LUA_TTABLE || t == LUA_TUSERDATA)
        // If the value has metatable with field __type, then it pushes its value
        // on top of the stack and returns true. Otherwise returns false.
        && luaL_getmetafield(L, 1, "__type")) {

        if (lua_isfunction(L, 2)) {
            lua_insert(L, -2);  // swap func and value on stack
            lua_call(L, 1, 1);

            // If the func returned nil, fallback to raw type.
            if (lua_isnil(L, -1)) {
                lua_pushstring(L, lua_typename(L, t));
            }
        }
    } else if (t == LUA_TUSERDATA && luaL_testudata(L, 1, LUA_FILEHANDLE)) {
        lua_getglobal(L, "io");
        lua_getfield(L, 2, "type");
        lua_remove(L, 2);  // remove io
        lua_insert(L, -2);  // swap func and value on stack
        lua_call(L, 1, 1);
    } else {
        lua_pushstring(L, lua_typename(L, t));
    }

    return 1;  // number of results
}

int luaopen_mtype_native(lua_State *L) {
    lua_pushcfunction(L, mtype);

    return 1;  // number of results
}
