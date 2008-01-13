/* $Author: ameziti $ */
/* $Date: 2008-01-13 13:22:53 $ */
/* $Source: /home/marcus/revision_ctrl_test/oc_cvs/cvs/r2000/r2000sc/bench/pli/mem/veriuser_XL.c,v $ */
/* $Revision: 1.1.1.1 $ */
/* $State: Exp $ */
/* $Locker:  $ */

/*
 * |-----------------------------------------------------------------------|
 * |                                                                       |
 * |   Copyright Cadence Design Systems, Inc. 1985, 1988.                  |
 * |     All Rights Reserved.       Licensed Software.                     |
 * |                                                                       |
 * |                                                                       |
 * | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF CADENCE DESIGN SYSTEMS |
 * | The copyright notice above does not evidence any actual or intended   |
 * | publication of such source code.                                      |
 * |                                                                       |
 * |-----------------------------------------------------------------------|
 */

/*
 * |-------------------------------------------------------------|
 * |                                                             |
 * | PROPRIETARY INFORMATION, PROPERTY OF CADENCE DESIGN SYSTEMS |
 * |                                                             |
 * |-------------------------------------------------------------|
 */
/*****************************************************************************
*   This is the `veriuser.c' file.  For more information about the contents
*   of this file, please see `veriuser.doc'.
*****************************************************************************/

#include "veriuser.h"
//#include "vxl_veriuser.h"

// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the PROC_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// PROC_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.
#define PROC_EXPORTS

#ifdef PROC_EXPORTS
#define PROC_API __declspec(dllexport)
#else
#define PROC_API __declspec(dllimport)
#endif

char *veriuser_version_str = "";

int (*endofcompile_routines[])() = 
{
    /*** my_eoc_routine, ***/
    0 /*** final entry must be 0 ***/
};

bool err_intercept(level,facility,code)
int level; char *facility; char *code;
{ return(true); }

/****************
s_tfcell veriusertfs[] =
{
    /*** Template for an entry:
    { usertask|userfunction, data,
      checktf(), sizetf(), calltf(), misctf(),
      "$tfname", forwref?, Vtool?, ErrMsg? },
    Example:
    { usertask, 0, my_check, 0, my_func, my_misctf, "$my_task" },
    ---/

    /*** add user entries here ---/
    {0} /*** final entry must be 0 ---/
};
****************/

//#include "veriusertfs_table.h"  /* Use the example veriusertfs table from the PLI book */

/* prototypes of the PLI application routines */
extern int PLIbook_WatchVar_checktf(),
           PLIbook_WatchVar_calltf(),
           PLIbook_WatchVar_misctf();
           
/* the veriusertfs table */
PROC_API s_tfcell veriusertfs[] =
{
    {usertask,                         /* type of PLI routine */
      0,                               /* user_data value */
      PLIbook_WatchVar_checktf,         /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_WatchVar_calltf,          /* calltf routine */
      PLIbook_WatchVar_misctf,          /* misctf routine */
      "$watch_data_hex",                 /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */

    /*** final entry must be 0 ***/
	{0}
};
