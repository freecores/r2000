/**********************************************************************
 File Name:  UserIO_vpi.c
 System Task Name:  $UserIO
 Description:  $UserIO detects the control signals and takes appropriate
               actions:
                              
               MEM[0..3] = Input Enable Control Signal
               MEM[4..7] = Output Enable Control Signal
               MEM[8..11] =  Input Word Data
               MEM[12..15] = Output Word Data
 
               If MEM[3] is detected to be '1', the user is prompted to
               save Word data into MEM[8..11].
               
               If MEM[7] is detected to be '1', the content of MEM[12..15] 
               is printed to the screen.
 
 Student Name:  Andy Peng
 Semester:      Spring, 2004
 *********************************************************************/

#include <stdlib.h>    /* ANSI C standard library */
#include <stdio.h>     /* ANSI C standard input/output library */
#include <string.h>
#include <vpi_user.h>  /* IEEE 1364 PLI VPI routine library  */

/* Prototypes of PLI application routine names */
PLI_INT32 UserIO_calltf(PLI_BYTE8 *user_data),
          UserIO_compiletf(PLI_BYTE8 *user_data);

/* Registration Function */
void UserIO_register()
{
  s_vpi_systf_data tf_data;

  tf_data.type        = vpiSysTask;
  tf_data.tfname      = "$UserIO";
  tf_data.calltf      = UserIO_calltf;
  tf_data.compiletf   = UserIO_compiletf;
  tf_data.sizetf      = NULL;
  vpi_register_systf(&tf_data);
}

/* compiletf routine */
PLI_INT32 UserIO_compiletf(PLI_BYTE8 *user_data)
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
  
} // end UserIO_compiletf

/* calltf routine  */
PLI_INT32 UserIO_calltf(PLI_BYTE8 *user_data)
{ 
  // vpiHandle Type defined in vpi_user.h	
  vpiHandle   systf_handle, arg_itr, arg_handle, module_handle, memItr, mem_handle, memByteItr, 
              memByteHandle[16];        // vpiHandle Type
  s_vpi_value valueMemByte[16];         // s_vpi_value Type  
  s_vpi_time  time_s;                   // vpi structure type
  char InputValue[2];
  int  i=0;
  
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
  for (i=0; i<12; i=i+1)
      valueMemByte[i].format = vpiHexStrVal;
      
  time_s.type = vpiScaledRealTime;

  // parse through MEM[..] within VeSPA module
  if (!memItr)  {
     vpi_printf("No Memory Registers Found in the Module (%s) !\n",vpi_get_str(vpiFullName,module_handle));
     return -1;
  } else {	   
    
    mem_handle = vpi_scan(memItr);     // First element is MEM[..]

    if (strcmp(vpi_get_str(vpiName,mem_handle),"MEM") == 0)  {    // Ensure it is the handle for MEM[..]
      memByteItr = vpi_iterate(vpiMemoryWord,mem_handle);    // Memory Byte Iterator

      // Prompt for User Input if Input Control Enable Signal is '1'
      for (i=0; i<4; i=i+1)      
          memByteHandle[i] = vpi_scan(memByteItr);           // skips vpi handle from MEM[0] to MEM[2]

      vpi_get_value(memByteHandle[3],&valueMemByte[3]);      // Get Input Control Enable Byte from MEM[3]

      if (strcmp(valueMemByte[3].value.str,"01") == 0)  {    // Input Control Flag is Detected
         for (i=4; i<8; i=i+1)
             memByteHandle[i] = vpi_scan(memByteItr);        // skips vpi handle from MEM[4] to MEM[7]   
             
         vpi_printf("----------------- $UserIO: Begin of Input Value ------------------\n");  
         for (i=8; i<12; i=i+1)  {
             memByteHandle[i] = vpi_scan(memByteItr);        // vpi handle for MEM[8] to MEM[11] (Input Word Data)        
             vpi_printf("Please Enter 2 HEX Decimal for %s <MSB to LSB> = ",vpi_get_str(vpiName,memByteHandle[i]));
             scanf("%s",&InputValue);
             valueMemByte[i].value.str = InputValue;         
             vpi_put_value(memByteHandle[i], &valueMemByte[i], &time_s, vpiNoDelay);
         }  // end for loop
         
         vpi_printf("--------------------- End of Input Value -------------------------\n");

       } else {   // Prints Output Data if Output Control Enable Signal is '1'

       for (i=4; i<8; i=i+1) 
         memByteHandle[i] = vpi_scan(memByteItr);           // skips vpi handle from MEM[4] to MEM[6]

         vpi_get_value(memByteHandle[7],&valueMemByte[7]);  // Get Output Control Enable Byte from MEM[7]       

            if (strcmp(valueMemByte[7].value.str,"01") == 0)  { // Only true if output control signal is '1'

            for (i=8; i<12; i=i+1)
                memByteHandle[i] = vpi_scan(memByteItr);        // skips vpi handle for MEM[8] to MEM[11]
           
            vpi_printf("\nOutput Value = ");
            for (i=12; i<16; i=i+1)   {
                memByteHandle[i] = vpi_scan(memByteItr);        // vpi handle for MEM[12] to MEM[15] (Output Word Data)
                vpi_get_value(memByteHandle[i],&valueMemByte[i]);                
                // vpi_printf("\nOutput Value %s = %s ",vpi_get_str(vpiName,memByteHandle[i]),valueMemByte[i].value.str);                
                vpi_printf("%s",valueMemByte[i].value.str);
            }  // end for loop
            vpi_printf("\n");

            } // end if

       vpi_free_object(memByteItr);   // free up memory
       fflush(stdin);  // clear keyboard input 
       
       } // end if

    vpi_free_object(memItr);   // free up memory

    } // end if

  } // end if

  return(0);

}  // end UserIO_callt
