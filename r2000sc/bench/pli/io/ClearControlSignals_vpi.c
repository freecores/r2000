/**********************************************************************
 File Name:  ClearControlSignals_vpi.c
 System Task Name:  $ClearControlSignals
 Description:  $ClearControlSignals system task clear the control signals 
               in the memory contents of MEM[3] and MEM[7]

 Student Name:  Andy Peng
 Semester:   Spring, 2004
 *********************************************************************/

#include <stdlib.h>    /* ANSI C standard library */
#include <stdio.h>     /* ANSI C standard input/output library */
#include <string.h>
#include <vpi_user.h>  /* IEEE 1364 PLI VPI routine library  */

/* Prototypes of PLI application routine names */
PLI_INT32 ClearControlSignals_calltf(PLI_BYTE8 *user_data),
          ClearControlSignals_compiletf(PLI_BYTE8 *user_data);

/* Registration Function */
void ClearControlSignals_register()
{
  s_vpi_systf_data tf_data;

  tf_data.type        = vpiSysTask;
  tf_data.tfname      = "$ClearControlSignals";
  tf_data.calltf      = ClearControlSignals_calltf;
  tf_data.compiletf   = ClearControlSignals_compiletf;
  tf_data.sizetf      = NULL;
  vpi_register_systf(&tf_data);
}

/* compiletf routine */
PLI_INT32 ClearControlSignals_compiletf(PLI_BYTE8 *user_data)
{
  vpiHandle systf_handle, arg_itr, arg_handle;
  PLI_INT32 tfarg_type;

  /* obtain a handle to the system task instance */
  systf_handle = vpi_handle(vpiSysTfCall,NULL);
  
  /* obtain handles to system task arguments */
  arg_itr = vpi_iterate(vpiArgument,systf_handle);
  
  if (arg_itr == NULL) {
     vpi_printf("ERROR: $UserIO requires an argument ! \n");
     vpi_control(vpiFinish,1);  // simulation aborted
  }
  else {
  // check the type of object in system task arguments	
  arg_handle = vpi_scan(arg_itr);
  tfarg_type = vpi_get(vpiType, arg_handle);
     if (tfarg_type != vpiModule) {
        vpi_printf("ERROR: $UserIO argument must be module instance ! \n");
        vpi_free_object(arg_itr);  // free iterator memory
        vpi_control(vpiFinish,1);  // simulation aborted	
     } else {  // check that there is only 1 system arguments
        arg_handle = vpi_scan(arg_itr);
        if (arg_handle != NULL) {
           vpi_printf("ERROR: $UserIO can only have 1 argument ! \n");
           vpi_free_object(arg_itr);  // free iterator memory
           vpi_control(vpiFinish,1);  // simulation aborted	        
        } // end if

      } // end if
	
   } // end if
  
  return(0);
  
} // end ClearControlSignals_compiletf

/* calltf routine  */
PLI_INT32 ClearControlSignals_calltf(PLI_BYTE8 *user_data)
{ 
  vpiHandle   systf_handle, arg_itr, arg_handle, module_handle, memItr, mem_handle, 
              memByteItr, memByteHandle[8];     // vpi handle type
  s_vpi_value valueMemByte[8];
  s_vpi_time  time_s;              // vpi structure type
  int i=0;
  
  // obtain a handle to the system task instance
  systf_handle = vpi_handle(vpiSysTfCall, NULL);

  // obtain handle to system task argument
  arg_itr = vpi_iterate(vpiArgument, systf_handle);
  if (arg_itr == NULL)  {
     vpi_printf("ERROR: $UserIO failed to obtain systf arg handles \n");
     return(0);	
  } // end if
  module_handle = vpi_scan(arg_itr);

  // memItr is the iterator handle to MEM[..] and R[..] inside VeSPA module.
  memItr = vpi_iterate(vpiMemory, module_handle);

  // set the format flag in s_vpi_value structure to Hexdecimal
  for (i=0;i<8; i=i+1)
      valueMemByte[i].format = vpiHexStrVal;
  
  time_s.type = vpiScaledRealTime;

  // parse through MEM[..] within VeSPA module
  if (!memItr)  {
     vpi_printf("No Memory Registers Found in the Module (%s) !\n",vpi_get_str(vpiFullName,module_handle));
     return(-1);
  } else {	   
    
    mem_handle = vpi_scan(memItr);     // First element is MEM[..]
    if (strcmp(vpi_get_str(vpiName,mem_handle),"MEM") == 0)  {    // Ensure it is the handle for MEM[..]

      memByteItr = vpi_iterate(vpiMemoryWord,mem_handle);   // Memory MEM[..] Iterator

      // Clear Memory Bytes from MEM[0] to MEM[7]
      for (i=0;i<8; i=i+1)  {
          memByteHandle[i] = vpi_scan(memByteItr);
          vpi_get_value(memByteHandle[i],&valueMemByte[i]);                          	         
          valueMemByte[i].value.str = "00";
          vpi_put_value(memByteHandle[i], &valueMemByte[i], &time_s, vpiNoDelay);
      }  // end for loop

      vpi_free_object(memByteItr);   // free up memory

    } // end if

    vpi_free_object(memItr);   // free up memory
  
  } // end if

  return(0);

}  // end ClearControlSignals_callt
