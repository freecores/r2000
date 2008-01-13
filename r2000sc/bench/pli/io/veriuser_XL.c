/* $Author: ameziti $ */
/* $Date: 2008-01-13 13:22:52 $ */
/* $Source: /home/marcus/revision_ctrl_test/oc_cvs/cvs/r2000/r2000sc/bench/pli/io/veriuser_XL.c,v $ */
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
extern int PLIbook_DumpMem_checktf(),
           PLIbook_DumpMem_calltf(),
           PLIbook_DumpMem_misctf();
extern int PLIbook_FillMem_checktf(),
           PLIbook_FillMem_calltf(),
           PLIbook_FillMem_misctf();
           
/* the veriusertfs table */
s_tfcell veriusertfs[] =
{
    {usertask,                         /* type of PLI routine */
      0,                               /* user_data value */
      PLIbook_DumpMem_checktf,         /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_DumpMem_calltf,          /* calltf routine */
      PLIbook_DumpMem_misctf,          /* misctf routine */
      "$dump_mem_hex",                 /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */

    {usertask,                         /* type of PLI routine */
      1,                               /* user_data value */
      PLIbook_DumpMem_checktf,         /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_DumpMem_calltf,          /* calltf routine */
      PLIbook_DumpMem_misctf,          /* misctf routine */
      "$dump_mem_bin",                 /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */

    {usertask,                         /* type of PLI routine */
      2,                               /* user_data value */
      PLIbook_DumpMem_checktf,         /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_DumpMem_calltf,          /* calltf routine */
      PLIbook_DumpMem_misctf,          /* misctf routine */
      "$dump_mem_ascii",               /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */

    {usertask,                         /* type of PLI routine */
      0,                               /* user_data value */
      PLIbook_FillMem_checktf,         /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_FillMem_calltf,          /* calltf routine */
      PLIbook_FillMem_misctf,          /* misctf routine */
      "$fill_mem",                     /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */
    {0} /*** final entry must be 0 ***/
};
