#ifndef PHOTORESIZE_HPP
#define PHOTORESIZE_HPP


#ifdef SWIG

/* Tcl 9 compatibility - CONST macro was removed in Tcl 9 */
%begin %{
#ifndef CONST
#define CONST const
#endif

/* Override SWIG's default stubs version (8.4) to support Tcl 8.6+ and 9.x */
#define SWIG_TCL_STUBS_VERSION "8.6-"
%}

%init{
  #ifdef USE_TK_STUBS
  if (Tk_InitStubs(interp, (char*)"8.6-", 0) == NULL) {
    return TCL_ERROR;
  }
  #endif  

  //Tcl_PkgRequire(interp, "Tk", "", false);
}
%include exception.i
%include typemaps.i
%include std_string.i
%{
#include "photoresize.hpp"
%}
%typemap(in) Tk_PhotoHandle {
  $1 = Tk_FindPhoto (interp, Tcl_GetString($input));
  if ($1==NULL) {
    SWIG_exception(SWIG_RuntimeError, "Photo not found");
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) Tk_PhotoHandle {
  $1 = Tk_FindPhoto (interp, Tcl_GetString($input))!=NULL;
}  

%exception {
  try {
    $action
  } catch (const std::string &msg) {
    SWIG_exception(SWIG_RuntimeError, const_cast<char*>(msg.c_str()));
  } catch (...) {
    SWIG_exception(SWIG_RuntimeError, "Some C++-Error");
  }
}

/* Tcl 9 lowercase init function aliases for package loading
 * These aliases allow 'package require photoresize' to work in Tcl 9
 * which expects lowercase init functions. The aliases are placed
 * at the very end of the generated file after SafeInit is defined.
 */
%insert("runtime") %{
/* Forward declarations for init functions */
#define SWIG_PHOTORESIZE_INIT_ALIASES
%}
%insert("init") %{
  return TCL_OK;
}
/* Tcl 9 lowercase init function aliases */
#ifdef SWIG_PHOTORESIZE_INIT_ALIASES
#ifdef __cplusplus
extern "C" {
#endif
SWIGEXPORT int Photoresize_SafeInit(Tcl_Interp *interp);
SWIGEXPORT int photoresize_Init(Tcl_Interp *interp) { return SWIG_init(interp); }
SWIGEXPORT int photoresize_SafeInit(Tcl_Interp *interp) { return Photoresize_SafeInit(interp); }
#ifdef __cplusplus
}
#endif
#endif
/* Dummy function to absorb any trailing code from SWIG init section */
static inline int _swig_photoresize_init_end(Tcl_Interp *SWIGUNUSED interp) {
%}

#else
 // C-preprocessor
#include <tcl.h>
#include <tk.h>
#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <cstring>
#include <cassert>
//#include <malloc.h>
#include <string>
#include <sstream>
#include <vector>
#include <algorithm>

#define STHROW(msg) { \
	 std::ostringstream err;\
	 err<<msg; \
	 throw err.str(); }



#endif //!SWIG

std::string resizephoto(Tcl_Interp *interp, Tk_PhotoHandle source, Tk_PhotoHandle target, int xsize, int ysize);
std::string resizephoto(Tcl_Interp *interp, Tk_PhotoHandle source, Tk_PhotoHandle target, int x0, int y0, int x1, int y1, int xsize, int ysize);
#endif
