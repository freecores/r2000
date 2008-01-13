/**********************************************************************
 File Name:  UserIO_vpi.c
 System Task Name:  $UserIO
 Description:  $UserIO detects the control signals and takes appropriate
               actions:
               
               MEM[0] = Input Enable Control Signal
               MEM[1] = Not Specified
               MEM[2] = Output Enable Control Signal
               MEM[3] = Not Specified
               
               MEM[4..7] = Input Word Data
               MEM[8..11] = Output Word Data
 
               If MEM[0] is detected to be '1', the user is prompted to
               save Word data into MEM[4..7].
               
               If MEM[2] is detected to be '1', the content of MEM[8..11] 
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
              memByteHandle0, memByteHandle1, memByteHandle2, memByteHandle3, memByteHandle4,   
              memByteHandle5, memByteHandle6, memByteHandle7, memByteHandle8, memByteHandle9,
              memByteHandle10, memByteHandle11;       // vpiHandle Type
  s_vpi_value valueMemByte0, valueMemByte1, valueMemByte2, valueMemByte3, valueMemByte4,
              valueMemByte5, valueMemByte6, valueMemByte7, valueMemByte8, valueMemByte9,
              valueMemByte10, valueMemByte11;         // s_vpi_value Type  
  s_vpi_time  time_s;              // vpi structure type
  char InputValue[2];
  
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
  valueMemByte0.format = vpiHexStrVal;
  valueMemByte1.format = vpiHexStrVal;
  valueMemByte2.format = vpiHexStrVal;
  valueMemByte3.format = vpiHexStrVal;
  valueMemByte4.format = vpiHexStrVal;
  valueMemByte5.format = vpiHexStrVal;
  valueMemByte6.format = vpiHexStrVal;
  valueMemByte7.format = vpiHexStrVal;
  valueMemByte8.format = vpiHexStrVal;
  valueMemByte9.format = vpiHexStrVal;
  valueMemByte10.format = vpiHexStrVal;
  valueMemByte11.format = vpiHexStrVal;  
      
  time_s.type = vpiScaledRealTime;

  // parse through MEM[..] within VeSPA module
  if (!memItr)  {
     vpi_printf("No Memory Registers Found in the Module (%s) !\n",vpi_get_str(vpiFullName,module_handle));
     return -1;
  } else {	   
    
    mem_handle = vpi_scan(memItr);     // First element is MEM[..]
    if (strcmp(vpi_get_str(vpiName,mem_handle),"MEM") == 0)  {    // Ensure it is the handle for MEM[..]

      memByteItr = vpi_iterate(vpiMemoryWord,mem_handle);  // Memory Byte Iterator

      // Take User Input if Input Control Signal is '1'
      memByteHandle0 = vpi_scan(memByteItr);              // vpi handle for MEM[0]
      vpi_get_value(memByteHandle0,&valueMemByte0);   

      if (strcmp(valueMemByte0.value.str,"01") == 0)  {    // Only true if input control signal is '1'
         memByteHandle1 = vpi_scan(memByteItr);            // vpi handle for MEM[1]
         memByteHandle2 = vpi_scan(memByteItr);            // vpi handle for MEM[2]
         memByteHandle3 = vpi_scan(memByteItr);            // vpi handle for MEM[3]
         memByteHandle4 = vpi_scan(memByteItr);            // vpi handle for MEM[4]
         
         vpi_printf("\nPlease Enter 2 HEX Decimal for %s <MSB to LSB> = ",vpi_get_str(vpiName,memByteHandle4));
         scanf("%s",&InputValue);
         valueMemByte4.value.str = InputValue;         
         vpi_put_value(memByteHandle4, &valueMemByte4, &time_s, vpiNoDelay);
         
         memByteHandle5 = vpi_scan(memByteItr);            // vpi handle for MEM[5]
         vpi_printf("\nPlease Enter 2 HEX Decimal for %s <MSB to LSB> = ",vpi_get_str(vpiName,memByteHandle5));
         scanf("%s",&InputValue);
         valueMemByte5.value.str = InputValue;         
         vpi_put_value(memByteHandle5, &valueMemByte5, &time_s, vpiNoDelay);

         memByteHandle6 = vpi_scan(memByteItr);            // vpi handle for MEM[6]
         vpi_printf("\nPlease Enter 2 HEX Decimal for %s <MSB to LSB> = ",vpi_get_str(vpiName,memByteHandle6));
         scanf("%s",&InputValue);
         valueMemByte6.value.str = InputValue;         
         vpi_put_value(memByteHandle6, &valueMemByte6, &time_s, vpiNoDelay);

         memByteHandle7 = vpi_scan(memByteItr);            // vpi handle for MEM[7]
         vpi_printf("\nPlease Enter 2 HEX Decimal for %s <MSB to LSB> = ",vpi_get_str(vpiName,memByteHandle7));
         scanf("%s",&InputValue);
         valueMemByte7.value.str = InputValue;         
         vpi_put_value(memByteHandle7, &valueMemByte4, &time_s, vpiNoDelay);

       } else {   // Prints Output if Output Control Signal is '1'

         memByteHandle1 = vpi_scan(memByteItr);           // vpi handle for MEM[1]
         memByteHandle2 = vpi_scan(memByteItr);           // vpi handle for MEM[2]
//      vpi_printf("\n Memory Location = %s ",vpi_get_str(vpiName,memByteHandle2));      // for verification purpose     
         vpi_get_value(memByteHandle2,&valueMemByte2);         

         if (strcmp(valueMemByte2.value.str,"01") == 0)  { // Only true if output control signal is '1'

            memByteHandle3 = vpi_scan(memByteItr);        // vpi handle for MEM[3]
            memByteHandle4 = vpi_scan(memByteItr);        // vpi handle for MEM[4]
            memByteHandle5 = vpi_scan(memByteItr);        // vpi handle for MEM[5]
            memByteHandle6 = vpi_scan(memByteItr);        // vpi handle for MEM[6]
            memByteHandle7 = vpi_scan(memByteItr);        // vpi handle for MEM[7]

            memByteHandle8 = vpi_scan(memByteItr);        // vpi handle for MEM[8]
            vpi_get_value(memByteHandle8,&valueMemByte8);
            vpi_printf("\n Output Value %s = %s \n",vpi_get_str(vpiName,memByteHandle8),valueMemByte8.value.str);
            
            memByteHandle9 = vpi_scan(memByteItr);        // vpi handle for MEM[9]
            vpi_get_value(memByteHandle9,&valueMemByte9);
            vpi_printf("\n Output Value %s = %s \n",vpi_get_str(vpiName,memByteHandle9),valueMemByte9.value.str);
            
            memByteHandle10 = vpi_scan(memByteItr);        // vpi handle for MEM[10]
            vpi_get_value(memByteHandle10,&valueMemByte10);
            vpi_printf("\n Output Value %s = %s \n",vpi_get_str(vpiName,memByteHandle10),valueMemByte10.value.str);
            
            memByteHandle11 = vpi_scan(memByteItr);        // vpi handle for MEM[10]
            vpi_get_value(memByteHandle11,&valueMemByte11);
            vpi_printf("\n Output Value %s = %s \n",vpi_get_str(vpiName,memByteHandle11),valueMemByte11.value.str);

         } // end if

       } // end if

    } // end if
  
  // free up memory

  vpi_free_object(memItr);
  vpi_free_object(memByteItr);

  } // end if

//  fflush(stdin);  // clear keyboard input 

  return(0);

}  // end UserIO_callt
