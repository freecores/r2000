/**********************************************************************
 File Name:  UserIO_vpi.c
 Student Name:  Andy Peng
 Semester:   Spring, 2004
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
  vpiHandle   systf_handle, arg_itr, arg_handle, module_handle, memItr, mem_handle, memByteItr, 
              memByte0_handle, memByte1_handle, memByte2_handle, memByte3_handle;     // vpi handle type
  s_vpi_value valueMemByte0, valueMemByte1, valueMemByte2, valueMemByte3;
  s_vpi_time  time_s;              // vpi structure type
  
  // declaration to save the contents of memory location
  char BufMemByte0[2], BufMemByte1[2], BufMemByte2[2], BufMemByte3[2];
  PLI_BYTE8 *BufMemByte0_p, *BufMemByte1_p,*BufMemByte2_p, *BufMemByte3_p;
  char *BufMemByte0_keep, *BufMemByte1_keep, *BufMemByte2_keep, *BufMemByte3_keep;

  PLI_BYTE8 *string_p;
  char *string_keep;
  char string[2];
  
  // obtain a handle to the system task instance
  systf_handle = vpi_handle(vpiSysTfCall, NULL);

  // obtain handle to system task argument
  arg_itr = vpi_iterate(vpiArgument, systf_handle);
  if (arg_itr == NULL)  {
     vpi_printf("ERROR: $UserIO failed to obtain systf arg handles \n");
     return(0);	
  } 
  module_handle = vpi_scan(arg_itr);

  // memItr is the iterator handle to MEM[..] and R[..] inside VeSPA module.
  memItr = vpi_iterate(vpiMemory, module_handle);

  // set the format flag in s_vpi_value structure to Hexdecimal
  valueMemByte0.format = vpiHexStrVal;
  valueMemByte1.format = vpiHexStrVal;      
  valueMemByte2.format = vpiHexStrVal;   
  valueMemByte3.format = vpiHexStrVal;   
  time_s.type = vpiScaledRealTime;

  // parse through MEM[..] within VeSPA module
  if (!memItr)  {
     vpi_printf("No Memory Registers Found in the Module (%s) !\n",vpi_get_str(vpiFullName,module_handle));
     return -1;
  } else {	   
    
    while(mem_handle = vpi_scan(memItr)) {   
      // Get handle for top 4 memory array:  MEM[0],MEM[1],MEM[2],MEM[3]
      if (strcmp(vpi_get_str(vpiName,mem_handle),"MEM") == 0)  {
      memByteItr = vpi_iterate(vpiMemoryWord,mem_handle);

      memByte0_handle = vpi_scan(memByteItr);  // get handle for MEM[0]
      vpi_printf("\n Memory Location %s = ",vpi_get_str(vpiName,memByte0_handle));     
      vpi_get_value(memByte0_handle,&valueMemByte0);
      string_p = valueMemByte0.value.str;
      string_keep = malloc(strlen((char *)string_p)+1);
      strcpy(string,(char *)string_p);

 //     vpi_printf("\n Value = %s \n",BufMemByte0);      

      memByte1_handle = vpi_scan(memByteItr);  // get handle for MEM[1]
      vpi_printf("\n Memory Location %s = ",vpi_get_str(vpiName,memByte1_handle));     
      vpi_get_value(memByte1_handle,&valueMemByte1);             

      vpi_printf("\n MEM[0] Before Strcpy Value = %s \n",BufMemByte0);      
      strcpy(BufMemByte1,valueMemByte1.value.str);  
      vpi_printf("\n MEM[0] After Strcpy Value = %s \n",BufMemByte0);

      vpi_printf("\n Value = %s \n",BufMemByte1);   
      
      memByte2_handle = vpi_scan(memByteItr);  // get handle for MEM[2]
      vpi_printf("\n Memory Location %s = ",vpi_get_str(vpiName,memByte2_handle));     
      vpi_get_value(memByte2_handle,&valueMemByte2);
      strcpy(BufMemByte2,valueMemByte2.value.str);
      vpi_printf("\n Value = %s \n",BufMemByte2);
            
      memByte3_handle = vpi_scan(memByteItr);  // get handle for MEM[3]
      vpi_printf("\n Memory Location %s = ",vpi_get_str(vpiName,memByte3_handle));     
      vpi_get_value(memByte3_handle,&valueMemByte3);
      strcpy(BufMemByte3,valueMemByte3.value.str);
      vpi_printf("\n Value = %s \n",BufMemByte3);

/*      printf("\n Modify Value To = ");      
      scanf("%s",&InputvalueMemByte3);
      valueMemByte3.value.str = InputvalueMemByte3;
      vpi_put_value(memByte3_handle, &valueMemByte3, &time_s, vpiNoDelay);
*/
       vpi_printf("\n!!  MEM[0] = %s \n",BufMemByte0);
       vpi_printf("!!  MEM[1] = %s \n",BufMemByte1);
       vpi_printf("!!  MEM[2] = %s \n",BufMemByte2);
       vpi_printf("!!  MEM[3] = %s \n",BufMemByte3);
       vpi_printf("String Value = %s \n",string);

      } // end if
      
    }  // end while	    
       
/*     
       
      if (strcmp(BufMemByte0,"48") == 0)  {
      	 vpi_printf("Compared Value = %s \n",BufMemByte3);  
      } 
*/
  } // end if

//  fflush(stdin);  // clear keyboard input 
  vpi_free_object(memItr);
  vpi_free_object(memByteItr);
  return(0);
}  // end UserIO_callt
