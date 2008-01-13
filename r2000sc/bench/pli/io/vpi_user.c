/**********************************************************************
 File Name:  vpi_user.c
 Description:  All Verilog User Defined System Task must be registered here.
 Student Name:  Andy Peng
 Semester:  Spring, 2004
 *********************************************************************/

#include "vpi_user.h"

/* prototypes of the PLI application routines */
extern void UserIO_register();
extern void ShowMemoryMap_register();
extern void ClearControlSignals_register();

void (*vlog_startup_routines[])() = 
{
    /*** add user entries here ***/
  UserIO_register,
  ShowMemoryMap_register,
  ClearControlSignals_register,
  0 /*** final entry must be 0 ***/
};
