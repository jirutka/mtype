#include <lua.h>
#include <lauxlib.h>
#include <stddef.h>
#include <string.h>


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

// Copied from lua-compat-5.1.
void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup) {
    luaL_checkstack(L, nup+1, "too many upvalues");

    for (; l->name != NULL; l++) {
        int i;
        lua_pushstring(L, l->name);
        for (i = 0; i < nup; i++)  {
            lua_pushvalue(L, -(nup + 1));
        }
        lua_pushcclosure(L, l->func, nup);
        lua_settable(L, -(nup + 3));
    }
    lua_pop(L, nup);
}

// Copied from lua-compat-5.1.
#define luaL_newlib(L, l) \
    (lua_newtable((L)),luaL_setfuncs((L), (l), 0))

#endif  // Lua 5.1


/**
 * Pushes onto the stack type (string) of the value at the top of the stack.
 */
static int type(lua_State *L) {
    luaL_checkany(L, -1);
    luaL_checkstack(L, 2, "not enough stack slots");
    // stack: [..., arg1]

    int t = lua_type(L, -1);

    if ((t == LUA_TTABLE || t == LUA_TUSERDATA)
        // If the value has metatable with field __type, then it pushes its value
        // on top of the stack and returns true. Otherwise returns false.
        && luaL_getmetafield(L, -1, "__type")) {
        // stack: [..., arg1, __type]

        if (lua_isfunction(L, -1)) {
            lua_insert(L, -2);  // stack: [..., __type, arg1]
            lua_call(L, 1, 1);  // stack: [..., metatype]

            // If the func returned nil, fallback to raw type.
            if (lua_isnil(L, -1)) {
                lua_pushstring(L, lua_typename(L, t));
            }
        }
    } else if (t == LUA_TUSERDATA && luaL_testudata(L, -1, LUA_FILEHANDLE)) {
        lua_getglobal(L, "io");       // stack: [..., arg1, io]
        lua_getfield(L, -1, "type");  // stack: [..., arg1, io, io.type]
        lua_remove(L, -2);            // stack: [..., arg1, io.type]
        lua_insert(L, -2);            // stack: [..., io.type, arg1]
        lua_call(L, 1, 1);            // stack: [..., metatype]
    } else {
        lua_pushstring(L, lua_typename(L, t));
    }

    return 1;  // number of result values
}

// forward declaration
static int istype_closure(lua_State *L);

/**
 * This functions checks if the value given as 2nd argument is of the type
 * specified by the 1st argument.
 *
 * If the first value on the stack is not a string, then it raises an error.
 *
 * If the stack contains only one item, then it pushes closure with
 * `istype_closure` and one upvalue onto the stack. This is partial application
 * of this function.
 *
 * If the stack contains at least two items, then it checks if the value at the
 * 2nd position on the stack is of type specified by the string on the 1st
 * position, and pushes true, or false onto the stack.
 */
static int istype(lua_State *L) {
    luaL_checktype(L, 1, LUA_TSTRING);

    if (lua_gettop(L) == 1) {
        // Return partially applied function.
        lua_pushcclosure(L, &istype_closure, 1);
        return 1;
    }

    int t = lua_type(L, 2);

    if ((t == LUA_TTABLE || t == LUA_TUSERDATA)
        // If the value has metatable with field __istype, then it pushes its
        // value on top of the stack and returns true. Otherwise returns false.
        && luaL_getmetafield(L, 2, "__istype")) {
        // stack: [arg1, arg2, __istype]

        lua_insert(L, 1);  // stack: [__istype, arg1, arg2]
        lua_insert(L, 2);  // stack: [__istype, arg2, arg1]

        switch (lua_type(L, 1)) {
            case LUA_TFUNCTION:
                lua_call(L, 2, 1);  // stack: [result]
                break;
            case LUA_TTABLE:
                lua_gettable(L, 1);  // stack: [__istype, arg2, result]
                if (! lua_isboolean(L, -1)) {
                    lua_pushboolean(L, !lua_isnil(L, -1));
                }
                break;
            default:
                return luaL_error(L,
                    "invalid metafield __istype (function or table expected, got %s)",
                    luaL_typename(L, -1));
        }
    } else {
        const char* req_type = lua_tostring(L, 1);

        if ((t == LUA_TTABLE && strcmp(req_type, "table") == 0)
            || (t == LUA_TUSERDATA && strcmp(req_type, "userdata") == 0)) {
            lua_pushboolean(L, 1);
        } else {
            (void) type(L);
            lua_pushboolean(L, lua_rawequal(L, 1, -1));
        }
    }

    return 1;  // number of result values
}

static int istype_closure(lua_State *L) {
    // Discard any extra arguments, keep just the first.
    lua_settop(L, 1);
    // Push "partially applied" argument to the stack.
    lua_pushvalue(L, lua_upvalueindex(1));
    // Swap arguments.
    lua_insert(L, -2);

    return istype(L);
}


static const struct luaL_Reg mtype_funcs[] = {
    { "type"  , type   },
    { "istype", istype },
    { NULL    , NULL   },
};

int luaopen_mtype_native(lua_State *L) {
    luaL_newlib(L, mtype_funcs);

    return 1;  // number of result values
}
