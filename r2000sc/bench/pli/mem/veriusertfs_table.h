/**********************************************************************
 * Example veriusertfs table that is used by many Verilog simulators
 * to register PLI applications that use the TF and ACC libraries of
 * the IEEE 1364 PLI.
 *
 * For the book, "The Verilog PLI Handbook" by Stuart Sutherland
 *  Book copyright 1999, Kluwer Academic Publishers, Norwell, MA, USA
 *   Contact: www.wkap.il
 *  Example copyright 1998, Sutherland HDL Inc, Portland, Oregon, USA
 *   Contact: www.sutherland.com or (503) 692-0898
 *********************************************************************/

/* prototypes of the PLI application routines */
extern int PLIbook_realpow_checktf(),
           PLIbook_realpow_calltf();
extern int PLIbook_exprinfoTest_checktf(),
           PLIbook_exprinfoTest_calltf();
extern int PLIbook_Read4stateValue_checktf(),
           PLIbook_Read4stateValue_misctf(),
           PLIbook_Read4stateValue_calltf();
extern int PLIbook_propagatepTest_checktf(),
           PLIbook_propagatepTest_calltf(),
           PLIbook_propagatepTest_misctf();
extern int PLIbook_nodeinfoTest_checktf(),
           PLIbook_nodeinfoTest_calltf();
extern int PLIbook_DumpMem_checktf(),
           PLIbook_DumpMem_calltf(),
           PLIbook_DumpMem_misctf();
extern int PLIbook_FillMem_checktf(),
           PLIbook_FillMem_calltf(),
           PLIbook_FillMem_misctf();

/* the veriusertfs table */
s_tfcell veriusertfs[] =
{
    {userrealfunction,                 /* type of PLI routine */
      0,                               /* user_data value */
      PLIbook_realpow_checktf,         /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_realpow_calltf,          /* calltf routine */
      0,                               /* misctf routine */
      "$realpow",                      /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */

    {usertask,                         /* type of PLI routine */
      0,                               /* user_data value */
      PLIbook_exprinfoTest_checktf,    /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_exprinfoTest_calltf,     /* calltf routine */
      0,                               /* misctf routine */
      "$exprinfo_test",                /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */

    {usertask,                         /* type of PLI routine */
      0,                               /* user_data value */
      PLIbook_Read4stateValue_checktf, /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_Read4stateValue_calltf,  /* calltf routine */
      PLIbook_Read4stateValue_misctf,  /* misctf routine */
      "$read_4state_value",            /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */

    {usertask,                         /* type of PLI routine */
      0,                               /* user_data value */
      PLIbook_propagatepTest_checktf,  /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_propagatepTest_calltf,   /* calltf routine */
      PLIbook_propagatepTest_misctf,   /* misctf routine */
      "$propagatep_test",              /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */

    {usertask,                         /* type of PLI routine */
      0,                               /* user_data value */
      PLIbook_nodeinfoTest_checktf,    /* checktf routine */
      0,                               /* sizetf routine */
      PLIbook_nodeinfoTest_calltf,     /* calltf routine */
      0,                               /* misctf routine */
      "$nodeinfo_test",                /* system task/function name */
      1                                /* forward reference = true */
    },                                 /* */

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

