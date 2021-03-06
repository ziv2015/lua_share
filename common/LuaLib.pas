(******************************************************************************
* Original copyright for the lua source and headers:
*  1994-2004 Tecgraf, PUC-Rio.
*  www.lua.org.
*
* Copyright for the Delphi adaptation:
*  2005 Rolf Meyerhoff
*  www.matrix44.de
*
* Copyright for the Lua 5.1 adaptation:
*  2007 Marco Antonio Abreu
*  www.marcoabreu.eti.br
*
*  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************)

unit LuaLib;

interface

uses windows;

const
  LUA_VERSION   = 'Lua 5.1';
  LUA_RELEASE   = 'Lua 5.1.2';
  LUA_COPYRIGHT = 'Copyright (C) 1994-2004 Tecgraf, PUC-Rio';
  LUA_AUTHORS   = 'R. Ierusalimschy, L. H. de Figueiredo & W. Celes';

  LUA_PASCAL_51_AUTHOR = 'Marco Antonio Abreu';
  LUA_PASCAL_51_COPYRIGHT = 'Copyright (C) 2007 Marco Antonio Abreu';

  (* mark for precompiled code (`<esc>Lua') *)
  LUA_SIGNATURE = #27'Lua';

  (* option for multiple returns in `lua_pcall' and `lua_call' *)
  LUA_MULTRET   = -1;

  (*
  ** pseudo-indices
  *)
  LUA_REGISTRYINDEX = -10000;
  LUA_ENVIRONINDEX  = -10001;
  LUA_GLOBALSINDEX  = -10002;

  (* thread status; 0 is OK *)
  LUA_TRD_YIELD = 1;
  LUA_ERRRUN    = 2;
  LUA_ERRSYNTAX = 3;
  LUA_ERRMEM    = 4;
  LUA_ERRERR    = 5;

  (* extra error code for `luaL_load' *)
  LUA_ERRFILE   = LUA_ERRERR + 1;

  (*
  ** basic types
  *)
  LUA_TNONE	         = -1;
  LUA_TNIL           = 0;
  LUA_TBOOLEAN       = 1;
  LUA_TLIGHTUSERDATA = 2;
  LUA_TNUMBER        = 3;
  LUA_TSTRING        = 4;
  LUA_TTABLE         = 5;
  LUA_TFUNCTION      = 6;
  LUA_TUSERDATA	     = 7;
  LUA_TTHREAD        = 8;

  (* minimum Lua stack available to a C function *)
  LUA_MINSTACK       = 20;

  (*
  ** garbage-collection function and options
  *)
  LUA_GCSTOP        = 0;
  LUA_GCRESTART     = 1;
  LUA_GCCOLLECT     = 2;
  LUA_GCCOUNT       = 3;
  LUA_GCCOUNTB      = 4;
  LUA_GCSTEP        = 5;
  LUA_GCSETPAUSE    = 6;
  LUA_GCSETSTEPMUL  = 7;

  (*
  ** {======================================================================
  ** Debug API
  ** =======================================================================
  *)

  (*
  ** Event codes
  *)
  LUA_HOOKCALL    = 0;
  LUA_HOOKRET     = 1;
  LUA_HOOKLINE    = 2;
  LUA_HOOKCOUNT	  = 3;
  LUA_HOOKTAILRET = 4;

  (*
  ** Event masks
  *)
  LUA_MASKCALL 	= (1 shl LUA_HOOKCALL);
  LUA_MASKRET  	= (1 shl LUA_HOOKRET);
  LUA_MASKLINE  = (1 shl LUA_HOOKLINE);
  LUA_MASKCOUNT	= (1 shl LUA_HOOKCOUNT);

  (*
  ** {======================================================================
  ** useful definitions for Lua kernel and libraries
  ** =======================================================================
  *)

  (*
  @@ LUA_NUMBER_SCAN is the format for reading numbers.
  @@ LUA_NUMBER_FMT is the format for writing numbers.
  @@ lua_number2str converts a number to a string.
  @@ LUAI_MAXNUMBER2STR is maximum size of previous conversion.
  @@ lua_str2number converts a string to a number.
  *)
  LUA_NUMBER_SCAN	=	'%lf';
  LUA_NUMBER_FMT	 =	'%.14g';
  LUAI_MAXNUMBER2STR =	32;  (* 16 digits, sign, point, and \0 *)

  (* pre-defined references *)
  LUA_NOREF  = -2;
  LUA_REFNIL = -1;

  LUA_IDSIZE = 60;

  (*
  ** package names
  *)
  LUA_COLIBNAME   = 'coroutine';
  LUA_TABLIBNAME  = 'table';
  LUA_IOLIBNAME   = 'io';
  LUA_OSLIBNAME   = 'os';
  LUA_STRLIBNAME  = 'string';
  LUA_MATHLIBNAME = 'math';
  LUA_DBLIBNAME   = 'debug';
  LUA_LOADLIBNAME = 'package';

  (*
  ** {======================================================
  ** Generic Buffer manipulation
  ** =======================================================
  *)

  BUFSIZ = 512; (* From stdio.h *)
  LUAL_BUFFERSIZE = BUFSIZ;

type
  lua_State = type Pointer;

  lua_CFunction = function(L: lua_State): Integer; cdecl;

  (*
  ** functions that read/write blocks when loading/dumping Lua chunks
  *)
  lua_Reader = function(L: lua_State; data: Pointer; var size: Cardinal): PAnsiChar; cdecl;
  lua_Writer = function(L: lua_State; p: Pointer; sz: Cardinal; ud: Pointer): Integer; cdecl;

  (*
  ** prototype for memory-allocation functions
  *)
  lua_Alloc = function(ud, ptr: Pointer; osize, nsize: Cardinal): Pointer; cdecl;

  (* type of numbers in Lua *)
  lua_Number  = type double;
  (* type for integer functions *)
  lua_Integer = type integer;

  lua_Debug = packed record
    event: Integer;
    name: PAnsiChar; (* (n) *)
    namewhat: PAnsiChar; (* (n) `global', `local', `field', `method' *)
    what: PAnsiChar; (* (S) `Lua', `C', `main', `tail' *)
    source: PAnsiChar; (* (S) *)
    currentline: Integer; (* (l) *)
    nups: Integer;  (* (u) number of upvalues *)
    linedefined: Integer; (* (S) *)
    lastlinedefine: Integer;	(* (S) *)
    short_src: array[0..LUA_IDSIZE - 1] of AnsiChar; (* (S) *)
    (* private part *)
    i_ci: Integer; (* active function *)
  end;

  (* Functions to be called by the debuger in specific events *)
  lua_Hook = procedure(L: lua_State; var ar: lua_Debug); cdecl;

  (* Lua Record *)
  PluaL_reg = ^luaL_reg;
  luaL_reg = packed record
    name: PAnsiChar;
    func: lua_CFunction;
  end;

  (*
  ** {======================================================
  ** Generic Buffer manipulation
  ** =======================================================
  *)

  luaL_Buffer = packed record
    p: PAnsiChar; (* current position in buffer *)
    lvl: Integer;  (* number of strings in the stack (level) *)
    L: lua_State;
    buffer: array[0..LUAL_BUFFERSIZE - 1] of AnsiChar;
  end;

var
  (*
  ** state manipulation
  *)
  lua_newstate:  function(f: lua_Alloc; ud: Pointer): lua_State; cdecl;
  lua_close:     procedure(L: lua_State); cdecl;
  lua_newthread: function(L: lua_State): lua_State; cdecl;
  lua_atpanic:   function(L: lua_State; panicf: lua_CFunction): lua_CFunction; cdecl;

  (*
  ** basic stack manipulation
  *)
  lua_gettop:     function(L: lua_State): Integer; cdecl;
  lua_settop:     procedure(L: lua_State; idx: Integer); cdecl;
  lua_pushvalue:  procedure(L: lua_State; idx: Integer); cdecl;
  lua_remove:     procedure(L: lua_State; idx: Integer); cdecl;
  lua_insert:     procedure(L: lua_State; idx: Integer); cdecl;
  lua_replace:    procedure(L: lua_State; idx: Integer); cdecl;
  lua_checkstack: function(L: lua_State; extra: Integer): LongBool; cdecl;
  lua_xmove:      procedure(from, dest: lua_State; n: Integer); cdecl;

  (*
  ** access functions (stack -> C/Pascal)
  *)

  lua_isnumber:    function(L: lua_State; idx: Integer): LongBool; cdecl;
  lua_isstring:    function(L: lua_State; idx: Integer): LongBool; cdecl;
  lua_iscfunction: function(L: lua_State; idx: Integer): LongBool; cdecl;
  lua_isuserdata:  function(L: lua_State; idx: Integer): LongBool; cdecl;
  lua_type:        function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_typename:    function(L: lua_State; tp: Integer): PAnsiChar; cdecl;

  lua_equal:       function(L: lua_State; idx1, idx2: Integer): LongBool; cdecl;
  lua_rawequal:    function(L: lua_State; idx1, idx2: Integer): LongBool; cdecl;
  lua_lessthan:    function(L: lua_State; idx1, idx2: Integer): LongBool; cdecl;

  lua_tonumber:    function(L: lua_State; idx: Integer): lua_Number; cdecl;
  lua_tointeger:   function(L: lua_State; idx: Integer): lua_Integer; cdecl;
  lua_toboolean:   function(L: lua_State; idx: Integer): LongBool; cdecl;
  lua_tolstring:   function(L: lua_State; idx: Integer; var len: Cardinal): PAnsiChar; cdecl;
  lua_objlen:      function(L: lua_State; idx: Integer): Cardinal; cdecl;
  lua_tocfunction: function(L: lua_State; idx: Integer): lua_CFunction; cdecl;
  lua_touserdata:  function(L: lua_State; idx: Integer): Pointer; cdecl;
  lua_tothread:    function(L: lua_State; idx: Integer): lua_State; cdecl;
  lua_topointer:   function(L: lua_State; idx: Integer): Pointer; cdecl;

  (*
  ** push functions (C/Pascal -> stack)
  *)
  lua_pushnil:      procedure(L: lua_State); cdecl;
  lua_pushnumber:   procedure(L: lua_State; n: lua_Number); cdecl;
  lua_pushinteger:  procedure(L: lua_State; n: lua_Integer); cdecl;
  lua_pushlstring:  procedure(L: lua_State; s: PAnsiChar; len: Cardinal); cdecl;
  lua_pushstring:   procedure(L: lua_State; s: PAnsiChar); cdecl;
  lua_pushvfstring: function(L: lua_State; fmt, argp: PAnsiChar): PAnsiChar; cdecl;

  lua_pushfstring:  function(L: lua_State; fmt: PAnsiChar; args: array of const): PAnsiChar; cdecl;
  lua_pushcclosure: procedure(L: lua_State; fn: lua_CFunction; n: Integer); cdecl;
  lua_pushboolean:  procedure(L: lua_State; b: LongBool); cdecl;
  lua_pushlightuserdata: procedure(L: lua_State; p: Pointer); cdecl;
  lua_pushthread:   function(L: lua_State): Integer; cdecl;

  (*
  ** get functions (Lua -> stack)
  *)
  lua_gettable:     procedure(L: lua_State; idx: Integer); cdecl;
  lua_getfield:     procedure(L: lua_State; idx: Integer; k: PAnsiChar); cdecl;
  lua_rawget:       procedure(L: lua_State; idx: Integer); cdecl;
  lua_rawgeti:      procedure(L: lua_State; idx, n: Integer); cdecl;
  lua_createtable:  procedure(L: lua_State; narr, nrec: Integer); cdecl;
  lua_newuserdata:  function(L: lua_State; size: Cardinal): Pointer; cdecl;
  lua_getmetatable: function(L: lua_State; idx: Integer): LongBool; cdecl;
  lua_getfenv:      procedure(L: lua_State; idx: Integer); cdecl;

  (*
  ** set functions (stack -> Lua)
  *)
  lua_settable:     procedure(L: lua_State; idx: Integer); cdecl;
  lua_setfield:     procedure(L: lua_State; idx: Integer; k: PAnsiChar ); cdecl;
  lua_rawset:       procedure(L: lua_State; idx: Integer); cdecl;
  lua_rawseti:      procedure(L: lua_State; idx, n: Integer); cdecl;
  lua_setmetatable: function(L: lua_State; idx: Integer): LongBool; cdecl;
  lua_setfenv:      function(L: lua_State; idx: Integer): LongBool; cdecl;

  (*
  ** `load' and `call' functions (load and run Lua code)
  *)
  lua_call:   procedure(L: lua_State; nargs, nresults: Integer); cdecl;
  lua_pcall:  function(L: lua_State; nargs, nresults, errfunc: Integer): Integer; cdecl;
  lua_cpcall: function(L: lua_State; func: lua_CFunction; ud: Pointer): Integer; cdecl;
  lua_load:   function(L: lua_State; reader: lua_Reader; data: Pointer; chunkname: PAnsiChar): Integer; cdecl;
  lua_dump:   function(L: lua_State; writer: lua_Writer; data: Pointer): Integer; cdecl;

  (*
  ** coroutine functions
  *)
  lua_yield:  function(L: lua_State; nresults: Integer): Integer; cdecl;
  lua_resume: function(L: lua_State; narg: Integer): Integer; cdecl;
  lua_status: function(L: lua_State): Integer; cdecl;

  (*
  ** garbage-collection functions
  *)
  lua_gc: function(L: lua_State; what, data: Integer): Integer; cdecl;

  (*
  ** miscellaneous functions
  *)

  lua_error:  function(L: lua_State): Integer; cdecl;
  lua_next:   function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_concat: procedure(L: lua_State; n: Integer); cdecl;

  lua_getallocf: function(L: lua_State; ud: Pointer): lua_Alloc; cdecl;
  lua_setallocf: procedure(L: lua_State; f: lua_Alloc; ud: Pointer); cdecl;

  (*
  ** {======================================================================
  ** Debug API
  ** =======================================================================
  *)

  lua_getstack:   function(L: lua_State; level: Integer; var ar: lua_Debug): Integer; cdecl;
  lua_getinfo:    function(L: lua_State; what: PAnsiChar; var ar: lua_Debug): Integer; cdecl;
  lua_getlocal:   function(L: lua_State; var ar: lua_Debug; n: Integer): PAnsiChar; cdecl;
  lua_setlocal:   function(L: lua_State; var ar: lua_Debug; n: Integer): PAnsiChar; cdecl;
  lua_getupvalue: function(L: lua_State; funcindex, n: Integer): PAnsiChar; cdecl;
  lua_setupvalue: function(L: lua_State; funcindex, n: Integer): PAnsiChar; cdecl;

  lua_sethook:      function(L: lua_State; func: lua_Hook; mask, count: Integer): Integer; cdecl;
  lua_gethook:      function(L: lua_State): lua_Hook; cdecl;
  lua_gethookmask:  function(L: lua_State): Integer; cdecl;
  lua_gethookcount: function(L: lua_State): Integer; cdecl;

  (* lua libraries *)
  luaopen_base:    function(L: lua_State): Integer; cdecl;
  luaopen_debug:   function(L: lua_State): Integer; cdecl;
  luaopen_io:      function(L: lua_State): Integer; cdecl;
  luaopen_math:    function(L: lua_State): Integer; cdecl;
  luaopen_os:      function(L: lua_State): Integer; cdecl;
  luaopen_package: function(L: lua_State): Integer; cdecl;
  luaopen_string:  function(L: lua_State): Integer; cdecl;
  luaopen_table:   function(L: lua_State): Integer; cdecl;
  (* open all previous libraries *)
  luaL_openlibs:   procedure(L: lua_State); cdecl;

  luaL_register:     procedure(L: lua_State; libname: PAnsiChar; lr: PluaL_reg); cdecl;
  luaL_getmetafield: function(L: lua_State; obj: Integer; e: PAnsiChar): Integer; cdecl;
  luaL_callmeta:     function(L: lua_State; obj: Integer; e: PAnsiChar): Integer; cdecl;
  luaL_typerror:     function(L: lua_State; narg: Integer; tname: PAnsiChar): Integer; cdecl;
  luaL_argerror:     function(L: lua_State; narg: Integer; extramsg: PAnsiChar): Integer; cdecl;
  luaL_checklstring: function(L: lua_State; narg: Integer; var len: Cardinal): PAnsiChar; cdecl;
  luaL_optlstring:   function(L: lua_State; narg: Integer; d: PAnsiChar; var len: Cardinal): PAnsiChar; cdecl;
  luaL_checknumber:  function(L: lua_State; narg: Integer): lua_Number; cdecl;
  luaL_optnumber:    function(L: lua_State; narg: Integer; d: lua_Number): lua_Number; cdecl;

  luaL_checkinteger: function(L: lua_State; narg: Integer): lua_Integer; cdecl;
  luaL_optinteger:   function(L: lua_State; narg: Integer; d: lua_Integer): lua_Integer; cdecl;

  luaL_checkstack: procedure(L: lua_State; sz: Integer; msg: PAnsiChar); cdecl;
  luaL_checktype:  procedure(L: lua_State; narg, t: Integer); cdecl;
  luaL_checkany:   procedure(L: lua_State; narg: Integer); cdecl;

  luaL_newmetatable: function(L: lua_State; tname: PAnsiChar): Integer; cdecl;
  luaL_checkudata:   function(L: lua_State; narg: Integer; tname: PAnsiChar): Pointer; cdecl;

  luaL_checkoption: function(L: lua_State; narg: Integer; def: PAnsiChar; lst: array of PAnsiChar): Integer; cdecl;

  luaL_where: procedure(L: lua_State; lvl: Integer); cdecl;
  luaL_error: function(L: lua_State; fmt: PAnsiChar; args: array of const): Integer; cdecl;

  luaL_ref:   function(L: lua_State; t: Integer): Integer; cdecl;
  luaL_unref: procedure(L: lua_State; t, ref: Integer); cdecl;

{$ifdef LUA_COMPAT_GETN}
  luaL_getn: function(L: lua_State; t: Integer): Integer; cdecl;
  luaL_setn: procedure(L: lua_State; t, n: Integer); cdecl;
{$endif}

  luaL_loadfile:   function(L: lua_State; filename: PAnsiChar): Integer; cdecl;
  luaL_loadbuffer: function(L: lua_State; buff: PAnsiChar; sz: Cardinal; name: PAnsiChar): Integer; cdecl;
  luaL_loadstring: function(L: lua_State; s: PAnsiChar): Integer; cdecl;

  luaL_newstate:  function(): lua_State; cdecl;
  luaL_gsub:      function(L: lua_State; s, p, r: PAnsiChar): PAnsiChar; cdecl;
  luaL_findtable: function(L: lua_State; idx: Integer; fname: PAnsiChar; szhint: Integer): PAnsiChar; cdecl;

  luaL_buffinit:   procedure(L: lua_State; var B: luaL_Buffer); cdecl;
  luaL_prepbuffer: function(var B: luaL_Buffer): PAnsiChar; cdecl;
  luaL_addlstring: procedure(var B: luaL_Buffer; s: PAnsiChar; l: Cardinal); cdecl;
  luaL_addstring:  procedure(var B: luaL_Buffer; s: PAnsiChar); cdecl;
  luaL_addvalue:   procedure(var B: luaL_Buffer); cdecl;
  luaL_pushresult: procedure(var B: luaL_Buffer); cdecl;

  (*
  ** ===============================================================
  ** some useful macros
  ** ===============================================================
  *)

{$ifndef LUA_COMPAT_GETN}
  function  luaL_getn(L: lua_State; t: Integer): Integer;
  procedure luaL_setn(L: lua_State; t, n: Integer);
{$endif}

  (* pseudo-indices *)
  function lua_upvalueindex(i: Integer): Integer;

  (* to help testing the libraries *)
  procedure lua_assert(c: Boolean);

  function lua_number2str(s: Lua_Number; n: Integer): ansistring;
  function lua_str2number(s: ansistring; p: integer): Lua_Number;

  (* argument and parameters checks *)
  function luaL_argcheck(L: lua_State; cond: Boolean; narg: Integer; extramsg: PAnsiChar): Integer;
  function luaL_checkstring(L: lua_State; narg: Integer): PAnsiChar;
  function luaL_optstring(L: lua_State; narg: Integer; d: PAnsiChar): PAnsiChar;
  function luaL_checkint(L: lua_State; narg: Integer): Integer;
  function luaL_optint(L: lua_State; narg, d: Integer): Integer;
  function luaL_checklong(L: lua_State; narg: Integer): LongInt;
  function luaL_optlong(L: lua_State; narg: Integer; d: LongInt): LongInt;

  function luaL_typename(L: lua_State; idx: Integer): PAnsiChar;
  function luaL_dofile(L: lua_State; filename: PAnsiChar): Integer;
  function luaL_dostring(L: lua_State; str: PAnsiChar): Integer;

  procedure luaL_getmetatable(L: lua_State; tname: PAnsiChar);

  (* Generic Buffer manipulation *)
  procedure luaL_addchar(var B: luaL_Buffer; c: AnsiChar);
  procedure luaL_putchar(var B: luaL_Buffer; c: AnsiChar);
  procedure luaL_addsize(var B: luaL_Buffer; n: Cardinal);

  function luaL_check_lstr(L: lua_State; numArg: Integer; var ls: Cardinal): PAnsiChar;
  function luaL_opt_lstr(L: lua_State; numArg: Integer; def: PAnsiChar; var ls: Cardinal): PAnsiChar;
  function luaL_check_number(L: lua_State; numArg: Integer): lua_Number;
  function luaL_opt_number(L: lua_State; nArg: Integer; def: lua_Number): lua_Number;
  function luaL_arg_check(L: lua_State; cond: Boolean; numarg: Integer; extramsg: PAnsiChar): Integer;
  function luaL_check_string(L: lua_State; n: Integer): PAnsiChar;
  function luaL_opt_string(L: lua_State; n: Integer; d: PAnsiChar): PAnsiChar;
  function luaL_check_int(L: lua_State; n: Integer): Integer;
  function luaL_check_long(L: lua_State; n: LongInt): LongInt;
  function luaL_opt_int(L: lua_State; n, d: Integer): Integer;
  function luaL_opt_long(L: lua_State; n: Integer; d: LongInt): LongInt;

  procedure lua_pop(L: lua_State; n: Integer);
  procedure lua_newtable(L: lua_State);
  procedure lua_register(L: lua_state; name: PAnsiChar; f: lua_CFunction);
  procedure lua_pushcfunction(L: lua_State; f: lua_CFunction);
  function  lua_strlen(L: lua_State; i: Integer): Cardinal;

  function lua_isfunction(L: lua_State; idx: Integer): Boolean;
  function lua_istable(L: lua_State; idx: Integer): Boolean;
  function lua_islightuserdata(L: lua_State; idx: Integer): Boolean;
  function lua_isnil(L: lua_State; idx: Integer): Boolean;
  function lua_isboolean(L: lua_State; idx: Integer): Boolean;
  function lua_isthread(L: lua_State; idx: Integer): Boolean;
  function lua_isnone(L: lua_State; idx: Integer): Boolean;
  function lua_isnoneornil(L: lua_State; idx: Integer): Boolean;

  procedure lua_pushliteral(L: lua_State; s: PAnsiChar);
  procedure lua_setglobal(L: lua_State; name: PAnsiChar);
  procedure lua_getglobal(L: lua_State; name: PAnsiChar);
  function  lua_tostring(L: lua_State; idx: Integer): PAnsiChar;

  (*
  ** compatibility macros and functions
  *)

  function  lua_open(): lua_State;
  procedure lua_getregistry(L: lua_State);
  function  lua_getgccount(L: lua_State): Integer;

  (* compatibility with ref system *)
  function  lua_ref(L: lua_State; lock: Boolean): Integer;
  procedure lua_unref(L: lua_State; ref: Integer);
  procedure lua_getref(L: lua_State; ref: Integer);

  (*
  ** Dynamic library manipulation
  *)
  function  GetProcAddr(fHandle: THandle; const methodName: ansistring; bErrorIfNotExists: Boolean = True ): Pointer;
  procedure SetLuaLibFileName( newLuaLibFileName: ansistring);
  function  GetLuaLibFileName(): ansistring;
  function  LoadLuaLib(newLuaLibFileName: ansistring = ''): HMODULE;
  function  InitializeLuaLib(ALibHandle: HMODULE): HMODULE;
  procedure FreeLuaLib();
  function  LuaLibLoaded: Boolean;

implementation

uses
  SysUtils, Math;

var
  fLibHandle: HMODULE = 0;
  fLibLoaded: boolean = false;
  fLuaLibFileName: ansistring = 'Lua5.1.dll';

(*
** Dynamic library manipulation
*)

function GetProcAddr( fHandle: THandle; const methodName: ansistring; bErrorIfNotExists: Boolean = True ): Pointer;
begin
  Result := GetProcAddress(fHandle, PAnsiChar(methodName));
  if bErrorIfNotExists and ( Result = nil ) then
     Raise Exception.CreateFmt('Cannot load method "%s" from dynamic library.', [methodName]);
end;

procedure SetLuaLibFileName(newLuaLibFileName: ansistring);
begin
  fLuaLibFileName := newLuaLibFileName;
end;

function GetLuaLibFileName(): ansistring;
begin
  Result := fLuaLibFileName;
end;

function LuaLibLoaded: Boolean;
begin
   Result := fLibHandle <> 0;
end;

function  InitializeLuaLib(ALibHandle: HMODULE): HMODULE;
begin
  lua_newstate       := GetProcAddr(ALibHandle, 'lua_newstate' );
  lua_close          := GetProcAddr(ALibHandle, 'lua_close' );
  lua_newthread      := GetProcAddr(ALibHandle, 'lua_newthread' );
  lua_atpanic        := GetProcAddr(ALibHandle, 'lua_atpanic' );
  lua_gettop         := GetProcAddr(ALibHandle, 'lua_gettop' );
  lua_settop         := GetProcAddr(ALibHandle, 'lua_settop' );
  lua_pushvalue      := GetProcAddr(ALibHandle, 'lua_pushvalue' );
  lua_remove         := GetProcAddr(ALibHandle, 'lua_remove' );
  lua_insert         := GetProcAddr(ALibHandle, 'lua_insert' );
  lua_replace        := GetProcAddr(ALibHandle, 'lua_replace' );
  lua_checkstack     := GetProcAddr(ALibHandle, 'lua_checkstack' );
  lua_xmove          := GetProcAddr(ALibHandle, 'lua_xmove' );
  lua_isnumber       := GetProcAddr(ALibHandle, 'lua_isnumber' );
  lua_isstring       := GetProcAddr(ALibHandle, 'lua_isstring' );
  lua_iscfunction    := GetProcAddr(ALibHandle, 'lua_iscfunction' );
  lua_isuserdata     := GetProcAddr(ALibHandle, 'lua_isuserdata' );
  lua_type           := GetProcAddr(ALibHandle, 'lua_type' );
  lua_typename       := GetProcAddr(ALibHandle, 'lua_typename' );
  lua_equal          := GetProcAddr(ALibHandle, 'lua_equal' );
  lua_rawequal       := GetProcAddr(ALibHandle, 'lua_rawequal' );
  lua_lessthan       := GetProcAddr(ALibHandle, 'lua_lessthan' );
  lua_tonumber       := GetProcAddr(ALibHandle, 'lua_tonumber' );
  lua_tointeger      := GetProcAddr(ALibHandle, 'lua_tointeger' );
  lua_toboolean      := GetProcAddr(ALibHandle, 'lua_toboolean' );
  lua_tolstring      := GetProcAddr(ALibHandle, 'lua_tolstring' );
  lua_objlen         := GetProcAddr(ALibHandle, 'lua_objlen' );
  lua_tocfunction    := GetProcAddr(ALibHandle, 'lua_tocfunction' );
  lua_touserdata     := GetProcAddr(ALibHandle, 'lua_touserdata' );
  lua_tothread       := GetProcAddr(ALibHandle, 'lua_tothread' );
  lua_topointer      := GetProcAddr(ALibHandle, 'lua_topointer' );
  lua_pushnil        := GetProcAddr(ALibHandle, 'lua_pushnil' );
  lua_pushnumber     := GetProcAddr(ALibHandle, 'lua_pushnumber' );
  lua_pushinteger    := GetProcAddr(ALibHandle, 'lua_pushinteger' );
  lua_pushlstring    := GetProcAddr(ALibHandle, 'lua_pushlstring' );
  lua_pushstring     := GetProcAddr(ALibHandle, 'lua_pushstring' );
  lua_pushvfstring   := GetProcAddr(ALibHandle, 'lua_pushvfstring' );
  lua_pushfstring    := GetProcAddr(ALibHandle, 'lua_pushfstring' );
  lua_pushcclosure   := GetProcAddr(ALibHandle, 'lua_pushcclosure' );
  lua_pushboolean    := GetProcAddr(ALibHandle, 'lua_pushboolean' );
  lua_pushlightuserdata := GetProcAddr(ALibHandle, 'lua_pushlightuserdata' );
  lua_pushthread     := GetProcAddr(ALibHandle, 'lua_pushthread' );
  lua_gettable       := GetProcAddr(ALibHandle, 'lua_gettable' );
  lua_getfield       := GetProcAddr(ALibHandle, 'lua_getfield' );
  lua_rawget         := GetProcAddr(ALibHandle, 'lua_rawget' );
  lua_rawgeti        := GetProcAddr(ALibHandle, 'lua_rawgeti' );
  lua_createtable    := GetProcAddr(ALibHandle, 'lua_createtable' );
  lua_newuserdata    := GetProcAddr(ALibHandle, 'lua_newuserdata' );
  lua_getmetatable   := GetProcAddr(ALibHandle, 'lua_getmetatable' );
  lua_getfenv        := GetProcAddr(ALibHandle, 'lua_getfenv' );
  lua_settable       := GetProcAddr(ALibHandle, 'lua_settable' );
  lua_setfield       := GetProcAddr(ALibHandle, 'lua_setfield' );
  lua_rawset         := GetProcAddr(ALibHandle, 'lua_rawset' );
  lua_rawseti        := GetProcAddr(ALibHandle, 'lua_rawseti' );
  lua_setmetatable   := GetProcAddr(ALibHandle, 'lua_setmetatable' );
  lua_setfenv        := GetProcAddr(ALibHandle, 'lua_setfenv' );
  lua_call           := GetProcAddr(ALibHandle, 'lua_call' );
  lua_pcall          := GetProcAddr(ALibHandle, 'lua_pcall' );
  lua_cpcall         := GetProcAddr(ALibHandle, 'lua_cpcall' );
  lua_load           := GetProcAddr(ALibHandle, 'lua_load' );
  lua_dump           := GetProcAddr(ALibHandle, 'lua_dump' );
  lua_yield          := GetProcAddr(ALibHandle, 'lua_yield' );
  lua_resume         := GetProcAddr(ALibHandle, 'lua_resume' );
  lua_status         := GetProcAddr(ALibHandle, 'lua_status' );
  lua_gc             := GetProcAddr(ALibHandle, 'lua_gc' );
  lua_error          := GetProcAddr(ALibHandle, 'lua_error' );
  lua_next           := GetProcAddr(ALibHandle, 'lua_next' );
  lua_concat         := GetProcAddr(ALibHandle, 'lua_concat' );
  lua_getallocf      := GetProcAddr(ALibHandle, 'lua_getallocf' );
  lua_setallocf      := GetProcAddr(ALibHandle, 'lua_setallocf' );
  lua_getstack       := GetProcAddr(ALibHandle, 'lua_getstack' );
  lua_getinfo        := GetProcAddr(ALibHandle, 'lua_getinfo' );
  lua_getlocal       := GetProcAddr(ALibHandle, 'lua_getlocal' );
  lua_setlocal       := GetProcAddr(ALibHandle, 'lua_setlocal' );
  lua_getupvalue     := GetProcAddr(ALibHandle, 'lua_getupvalue' );
  lua_setupvalue     := GetProcAddr(ALibHandle, 'lua_setupvalue' );
  lua_sethook        := GetProcAddr(ALibHandle, 'lua_sethook' );
  lua_gethook        := GetProcAddr(ALibHandle, 'lua_gethook' );
  lua_gethookmask    := GetProcAddr(ALibHandle, 'lua_gethookmask' );
  lua_gethookcount   := GetProcAddr(ALibHandle, 'lua_gethookcount' );
  luaopen_base       := GetProcAddr(ALibHandle, 'luaopen_base' );
  luaopen_table      := GetProcAddr(ALibHandle, 'luaopen_table' );
  luaopen_io         := GetProcAddr(ALibHandle, 'luaopen_io' );
  luaopen_os         := GetProcAddr(ALibHandle, 'luaopen_os' );
  luaopen_string     := GetProcAddr(ALibHandle, 'luaopen_string' );
  luaopen_math       := GetProcAddr(ALibHandle, 'luaopen_math' );
  luaopen_debug      := GetProcAddr(ALibHandle, 'luaopen_debug' );
  luaopen_package    := GetProcAddr(ALibHandle, 'luaopen_package' );
  luaL_openlibs      := GetProcAddr(ALibHandle, 'luaL_openlibs' );
  luaL_register      := GetProcAddr(ALibHandle, 'luaL_register' );
  luaL_getmetafield  := GetProcAddr(ALibHandle, 'luaL_getmetafield' );
  luaL_callmeta      := GetProcAddr(ALibHandle, 'luaL_callmeta' );
  luaL_typerror      := GetProcAddr(ALibHandle, 'luaL_typerror' );
  luaL_argerror      := GetProcAddr(ALibHandle, 'luaL_argerror' );
  luaL_checklstring  := GetProcAddr(ALibHandle, 'luaL_checklstring' );
  luaL_optlstring    := GetProcAddr(ALibHandle, 'luaL_optlstring' );
  luaL_checknumber   := GetProcAddr(ALibHandle, 'luaL_checknumber' );
  luaL_optnumber     := GetProcAddr(ALibHandle, 'luaL_optnumber' );
  luaL_checkinteger  := GetProcAddr(ALibHandle, 'luaL_checkinteger' );
  luaL_optinteger    := GetProcAddr(ALibHandle, 'luaL_optinteger' );
  luaL_checkstack    := GetProcAddr(ALibHandle, 'luaL_checkstack' );
  luaL_checktype     := GetProcAddr(ALibHandle, 'luaL_checktype' );
  luaL_checkany      := GetProcAddr(ALibHandle, 'luaL_checkany' );
  luaL_newmetatable  := GetProcAddr(ALibHandle, 'luaL_newmetatable' );
  luaL_checkudata    := GetProcAddr(ALibHandle, 'luaL_checkudata' );
  luaL_where         := GetProcAddr(ALibHandle, 'luaL_where' );
  luaL_error         := GetProcAddr(ALibHandle, 'luaL_error' );
  luaL_checkoption   := GetProcAddr(ALibHandle, 'luaL_checkoption' );
  luaL_ref           := GetProcAddr(ALibHandle, 'luaL_ref' );
  luaL_unref         := GetProcAddr(ALibHandle, 'luaL_unref' );
{$ifdef LUA_COMPAT_GETN}
  luaL_getn          := GetProcAddr(ALibHandle, 'luaL_getn' );
  luaL_setn          := GetProcAddr(ALibHandle, 'luaL_setn' );
{$endif}
  luaL_loadfile      := GetProcAddr(ALibHandle, 'luaL_loadfile' );
  luaL_loadbuffer    := GetProcAddr(ALibHandle, 'luaL_loadbuffer' );
  luaL_loadstring    := GetProcAddr(ALibHandle, 'luaL_loadstring' );
  luaL_newstate      := GetProcAddr(ALibHandle, 'luaL_newstate' );
  luaL_gsub          := GetProcAddr(ALibHandle, 'luaL_gsub' );
  luaL_findtable     := GetProcAddr(ALibHandle, 'luaL_findtable' );
  luaL_buffinit      := GetProcAddr(ALibHandle, 'luaL_buffinit' );
  luaL_prepbuffer    := GetProcAddr(ALibHandle, 'luaL_prepbuffer' );
  luaL_addlstring    := GetProcAddr(ALibHandle, 'luaL_addlstring' );
  luaL_addstring     := GetProcAddr(ALibHandle, 'luaL_addstring' );
  luaL_addvalue      := GetProcAddr(ALibHandle, 'luaL_addvalue' );
  luaL_pushresult    := GetProcAddr(ALibHandle, 'luaL_pushresult' );

  fLibHandle:= ALibHandle;
  result:= ALibHandle;
end;

function LoadLuaLib(newLuaLibFileName: ansistring): HMODULE;
var hlib: HMODULE;
begin
  FreeLuaLib();

  if newLuaLibFileName <> '' then
     SetLuaLibFileName( newLuaLibFileName );

  if not FileExists( GetLuaLibFileName() ) then begin
     Result := 0;
     exit;
  end;

  hlib := LoadLibrary( PChar(GetLuaLibFileName()));

  if (hlib = 0) then begin
     Result := 0;
     exit;
  end else fLibLoaded:= true;

  Result := InitializeLuaLib(hlib);
end;

procedure FreeLuaLib();
begin
  lua_newstate       := nil;
  lua_close          := nil;
  lua_newthread      := nil;
  lua_atpanic        := nil;
  lua_gettop         := nil;
  lua_settop         := nil;
  lua_pushvalue      := nil;
  lua_remove         := nil;
  lua_insert         := nil;
  lua_replace        := nil;
  lua_checkstack     := nil;
  lua_xmove          := nil;
  lua_isnumber       := nil;
  lua_isstring       := nil;
  lua_iscfunction    := nil;
  lua_isuserdata     := nil;
  lua_type           := nil;
  lua_typename       := nil;
  lua_equal          := nil;
  lua_rawequal       := nil;
  lua_lessthan       := nil;
  lua_tonumber       := nil;
  lua_tointeger      := nil;
  lua_toboolean      := nil;
  lua_tolstring      := nil;
  lua_objlen         := nil;
  lua_tocfunction    := nil;
  lua_touserdata     := nil;
  lua_tothread       := nil;
  lua_topointer      := nil;
  lua_pushnil        := nil;
  lua_pushnumber     := nil;
  lua_pushinteger    := nil;
  lua_pushlstring    := nil;
  lua_pushstring     := nil;
  lua_pushvfstring   := nil;
  lua_pushfstring    := nil;
  lua_pushcclosure   := nil;
  lua_pushboolean    := nil;
  lua_pushlightuserdata := nil;
  lua_pushthread     := nil;
  lua_gettable       := nil;
  lua_getfield       := nil;
  lua_rawget         := nil;
  lua_rawgeti        := nil;
  lua_createtable    := nil;
  lua_newuserdata    := nil;
  lua_getmetatable   := nil;
  lua_getfenv        := nil;
  lua_settable       := nil;
  lua_setfield       := nil;
  lua_rawset         := nil;
  lua_rawseti        := nil;
  lua_setmetatable   := nil;
  lua_setfenv        := nil;
  lua_call           := nil;
  lua_pcall          := nil;
  lua_cpcall         := nil;
  lua_load           := nil;
  lua_dump           := nil;
  lua_yield          := nil;
  lua_resume         := nil;
  lua_status         := nil;
  lua_gc             := nil;
  lua_error          := nil;
  lua_next           := nil;
  lua_concat         := nil;
  lua_getallocf      := nil;
  lua_setallocf      := nil;
  lua_getstack       := nil;
  lua_getinfo        := nil;
  lua_getlocal       := nil;
  lua_setlocal       := nil;
  lua_getupvalue     := nil;
  lua_setupvalue     := nil;
  lua_sethook        := nil;
  lua_gethook        := nil;
  lua_gethookmask    := nil;
  lua_gethookcount   := nil;
  luaopen_base       := nil;
  luaopen_table      := nil;
  luaopen_io         := nil;
  luaopen_os         := nil;
  luaopen_string     := nil;
  luaopen_math       := nil;
  luaopen_debug      := nil;
  luaopen_package    := nil;
  luaL_openlibs      := nil;
  luaL_register      := nil;
  luaL_getmetafield  := nil;
  luaL_callmeta      := nil;
  luaL_typerror      := nil;
  luaL_argerror      := nil;
  luaL_checklstring  := nil;
  luaL_optlstring    := nil;
  luaL_checknumber   := nil;
  luaL_optnumber     := nil;
  luaL_checkinteger  := nil;
  luaL_optinteger    := nil;
  luaL_checkstack    := nil;
  luaL_checktype     := nil;
  luaL_checkany      := nil;
  luaL_newmetatable  := nil;
  luaL_checkudata    := nil;
  luaL_where         := nil;
  luaL_error         := nil;
  luaL_checkoption   := nil;
  luaL_ref           := nil;
  luaL_unref         := nil;
{$ifdef LUA_COMPAT_GETN}
  luaL_getn          := nil;
  luaL_setn          := nil;
{$endif}
  luaL_loadfile      := nil;
  luaL_loadbuffer    := nil;
  luaL_loadstring    := nil;
  luaL_newstate      := nil;
  luaL_gsub          := nil;
  luaL_findtable     := nil;
  luaL_buffinit      := nil;
  luaL_prepbuffer    := nil;
  luaL_addlstring    := nil;
  luaL_addstring     := nil;
  luaL_addvalue      := nil;
  luaL_pushresult    := nil;

  if fLibLoaded and (fLibHandle <> 0) then FreeLibrary(fLibHandle);

  fLibHandle := 0;
  fLibLoaded := false;
end;

{$ifndef LUA_COMPAT_GETN}
function luaL_getn(L: lua_State; t: Integer): Integer;
begin
  Result := lua_objlen(L, t);
end;

procedure luaL_setn(L: lua_State; t, n: Integer);
begin
end;
{$endif}

function lua_upvalueindex(i: Integer): Integer;
begin
  Result := LUA_GLOBALSINDEX - i;
end;

procedure lua_pop(L: lua_State; n: Integer);
begin
  lua_settop(L, -(n) - 1);
end;

procedure lua_newtable(L: lua_State);
begin
  lua_createtable(L, 0, 0);
end;

function lua_strlen(L: lua_State; i: Integer): Cardinal;
begin
  result := lua_objlen(L, i);
end;

procedure lua_register(L: lua_state; name: PAnsiChar; f: lua_CFunction);
begin
  lua_pushcfunction(L, f);
  lua_setglobal(L, name);
end;

procedure lua_pushcfunction(L: lua_State; f: lua_CFunction);
begin
  lua_pushcclosure(L, f, 0);
end;

function lua_isfunction(L: lua_State; idx: Integer): Boolean;
begin
  Result := lua_type(L, idx) = LUA_TFUNCTION;
end;

function lua_istable(L: lua_State; idx: Integer): Boolean;
begin
  Result := lua_type(L, idx) = LUA_TTABLE;
end;

function lua_islightuserdata(L: lua_State; idx: Integer): Boolean;
begin
  Result := lua_type(L, idx) = LUA_TLIGHTUSERDATA;
end;

function lua_isnil(L: lua_State; idx: Integer): Boolean;
begin
  Result := lua_type(L, idx) = LUA_TNIL;
end;

function lua_isboolean(L: lua_State; idx: Integer): Boolean;
begin
  Result := lua_type(L, idx) = LUA_TBOOLEAN;
end;

function lua_isthread(L: lua_State; idx: Integer): Boolean;
begin
  Result := lua_type(L, idx) = LUA_TTHREAD;
end;

function lua_isnone(L: lua_State; idx: Integer): Boolean;
begin
  Result := lua_type(L, idx) = LUA_TNONE;
end;

function lua_isnoneornil(L: lua_State; idx: Integer): Boolean;
begin
  Result := lua_type(L, idx) <= 0;
end;

procedure lua_pushliteral(L: lua_State; s: PAnsiChar);
begin
  lua_pushlstring(L, s, StrLen(s));
end;

procedure lua_setglobal(L: lua_State; name: PAnsiChar);
begin
  lua_setfield(L, LUA_GLOBALSINDEX, name);
end;

procedure lua_getglobal(L: lua_State; name: PAnsiChar);
begin
  lua_getfield(L, LUA_GLOBALSINDEX, name);
end;

function lua_tostring(L: lua_State; idx: Integer): PAnsiChar;
var
  len: Cardinal;
begin
  Result := lua_tolstring(L, idx, len);
end;

function lua_getgccount(L: lua_State): Integer;
begin
  Result := lua_gc(L, LUA_GCCOUNT, 0);
end;

function lua_open(): lua_State;
begin
  Result := luaL_newstate();
end;

procedure lua_getregistry(L: lua_State);
begin
  lua_pushvalue(L, LUA_REGISTRYINDEX);
end;

function lua_ref(L: lua_State; lock: Boolean): Integer;
begin
  if lock then
     Result := luaL_ref(L, LUA_REGISTRYINDEX)
  else begin
     lua_pushstring(L, 'unlocked references are obsolete');
     Result := lua_error(L);
  end;
end;

procedure lua_unref(L: lua_State; ref: Integer);
begin
  luaL_unref(L, LUA_REGISTRYINDEX, ref);
end;

procedure lua_getref(L: lua_State; ref: Integer);
begin
  lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
end;

procedure lua_assert(c: Boolean);
begin
end;

function lua_number2str(s: Lua_Number; n: Integer): ansistring;
begin
  Result := FloatToStrF(s, ffFixed, 15, n);
end;

function lua_str2number(s: ansistring; p: integer): Lua_Number;
begin
  Result := StrToFloat(s);
end;

function luaL_argcheck(L: lua_State; cond: Boolean; narg: Integer; extramsg: PAnsiChar): Integer;
begin
  if cond then
     Result := 0
  else
     Result := luaL_argerror(L, narg, extramsg);
end;

function luaL_checkstring(L: lua_State; narg: Integer): PAnsiChar;
var
  ls: Cardinal;
begin
  Result := luaL_checklstring(L, narg, ls);
end;

function luaL_optstring(L: lua_State; narg: Integer; d: PAnsiChar): PAnsiChar;
var
  ls: Cardinal;
begin
  Result := luaL_optlstring(L, narg, d, ls);
end;

function luaL_checkint(L: lua_State; narg: Integer): Integer;
begin
  Result := Trunc(luaL_checkinteger(L, narg));
end;

function luaL_optint(L: lua_State; narg, d: Integer): Integer;
begin
  Result := Trunc(luaL_optinteger(L, narg, d));
end;

function luaL_checklong(L: lua_State; narg: Integer): LongInt;
begin
  Result := Trunc(luaL_checkinteger(L, narg));
end;

function luaL_optlong(L: lua_State; narg: Integer; d: LongInt): LongInt;
begin
  Result := Trunc(luaL_optinteger(L, narg, d));
end;

function luaL_typename(L: lua_State; idx: Integer): PAnsiChar;
begin
  Result := lua_typename(L, lua_type(L, idx));
end;

function luaL_dofile(L: lua_State; filename: PAnsiChar): Integer;
begin
  Result := luaL_loadfile(L, filename);

  If Result = 0 Then
     Result := lua_pcall(L, 0, LUA_MULTRET, 0);
end;

function luaL_dostring(L: lua_State; str: PAnsiChar): Integer;
begin
  Result := luaL_loadstring(L, str);

  If Result = 0 Then
     Result := lua_pcall(L, 0, LUA_MULTRET, 0);
end;

procedure luaL_getmetatable(L: lua_State; tname: PAnsiChar);
begin
   lua_getfield(L, LUA_REGISTRYINDEX, tname);
end;

procedure luaL_addchar(var B: luaL_Buffer; c: AnsiChar);
begin
  if pAnsiChar(B.p) < pAnsiChar(B.buffer + LUAL_BUFFERSIZE) then
     luaL_prepbuffer(B);

  B.p^ := c;
  Inc(B.p);
{  // original C code
#define luaL_addchar(B,c) \
  ((void)((B)->p < ((B)->buffer+LUAL_BUFFERSIZE) || luaL_prepbuffer(B)), \
   (*(B)->p++ = (char)(c)))
}
end;

procedure luaL_putchar(var B: luaL_Buffer; c: AnsiChar);
begin
  luaL_addchar(B, c);
end;

procedure luaL_addsize(var B: luaL_Buffer; n: Cardinal);
begin
  Inc(B.p, n);
end;

function luaL_check_lstr(L: lua_State; numArg: Integer; var ls: Cardinal): PAnsiChar;
begin
  Result := luaL_checklstring(L, numArg, ls);
end;

function luaL_opt_lstr(L: lua_State; numArg: Integer; def: PAnsiChar; var ls: Cardinal): PAnsiChar;
begin
  Result := luaL_optlstring(L, numArg, def, ls);
end;

function luaL_check_number(L: lua_State; numArg: Integer): lua_Number;
begin
  Result := luaL_checknumber(L, numArg);
end;

function luaL_opt_number(L: lua_State; nArg: Integer; def: lua_Number): lua_Number;
begin
  Result := luaL_optnumber(L, nArg, def);
end;

function luaL_arg_check(L: lua_State; cond: Boolean; numarg: Integer; extramsg: PAnsiChar): Integer;
begin
  Result := luaL_argcheck(L, cond, numarg, extramsg);
end;

function luaL_check_string(L: lua_State; n: Integer): PAnsiChar;
begin
  Result := luaL_checkstring(L, n);
end;

function luaL_opt_string(L: lua_State; n: Integer; d: PAnsiChar): PAnsiChar;
begin
  Result := luaL_optstring(L, n, d);
end;

function luaL_check_int(L: lua_State; n: Integer): Integer;
begin
  Result := luaL_checkint(L, n);
end;

function luaL_check_long(L: lua_State; n: LongInt): LongInt;
begin
  Result := luaL_checklong(L, n);
end;

function luaL_opt_int(L: lua_State; n, d: Integer): Integer;
begin
  Result := luaL_optint(L, n, d);
end;

function luaL_opt_long(L: lua_State; n: Integer; d: LongInt): LongInt;
begin
  Result := luaL_optlong(L, n, d);
end;

end.

