/**********************************************************************
* $dump_mem example -- C source code using TF/ACC PLI routines
*
* C source to illustrate reading 4-state logic values from all
* addresses of a Verilog memory array.
*
* The logic values are represented as characters in the C language. 
* Every eight bits of a Verilog memory word are passed to/from 
* Verilog as a C structure containing a pair of C bytes (of type char),
* using an aval/bval encoding, where:
* 0/0 = logic 0, 1/0 = logic 1, 0/1 = logic Z, 1/1 = logic X.
*
* For the book, "The Verilog PLI Handbook" by Stuart Sutherland
*  Book copyright 1999, Kluwer Academic Publishers, Norwell, MA, USA
*   Contact: www.wkap.il
*  Example copyright 1998, Sutherland HDL Inc, Portland, Oregon, USA
*   Contact: www.sutherland.com or (503) 692-0898
*
* Usage:
* ------
*   Syntax:  $dump_mem_hex(<memory_word_select>);
*            $dump_mem_ascii(<memory_word_select>);
*
*     Note:  The word select of the memory is ignored, but is
*            required by the tf_nodeinfo() syntax.
*
*   Example:
*    reg [23:0] RAM [0:3];
*    initial $ump_mem_hex(RAM[0]);
*
* Routine definitions for a veriusertfs array:
*  /* routine prototypes -/
*   extern int PLIbook_WatchVar_checktf(),
*              PLIbook_WatchVar_calltf();
*  /* table entries -/
*   {usertask,                         /* type of PLI routine -/
*     0,                               /* user_data value -/
*     PLIbook_WatchVar_checktf,         /* checktf routine -/
*     0,                               /* sizetf routine -/
*     PLIbook_WatchVar_calltf,          /* calltf routine -/
*     PLIbook_WatchVar_misctf,          /* misctf routine -/
*     "$dump_mem_hex",                 /* system task/function name -/
*     1                                /* forward reference = true -/
*   },
*   {usertask,                         /* type of PLI routine -/
*     1,                               /* user_data value -/
*     PLIbook_WatchVar_checktf,         /* checktf routine -/
*     0,                               /* sizetf routine -/
*     PLIbook_WatchVar_calltf,          /* calltf routine -/
*     PLIbook_WatchVar_misctf,          /* misctf routine -/
*     "$dump_mem_bin",                 /* system task/function name -/
*     1                                /* forward reference = true -/
*   },
*   {usertask,                         /* type of PLI routine -/
*     2,                               /* user_data value -/
*     PLIbook_WatchVar_checktf,         /* checktf routine -/
*     0,                               /* sizetf routine -/
*     PLIbook_WatchVar_calltf,          /* calltf routine -/
*     PLIbook_WatchVar_misctf,          /* misctf routine -/
*     "$dump_mem_ascii",               /* system task/function name -/
*     1                                /* forward reference = true -/
*   },
**********************************************************************/

#include <stdio.h>
#include <string.h>
#include "veriuser.h"         /* IEEE 1364 PLI TF  routine library */

#define HEX   0  /* values of user_data for system task names */

#define NBR_VAR	10	/* number of variables supported */

typedef struct{
		int	active;				// indicate to watch or no
		char name[20];				// Name of the variable to watch
		int addr;				// adresse of the variable to watch
		int type;				// type of variable (number of byte/variable)
		int length;				// length of the array
 	}s_variable;

s_variable table_var[NBR_VAR];

/* prototypes of functions invoked by the calltf routine */
void PLIbook_WatchVarHex(p_tfnodeinfo node_info, s_variable var);


/**********************************************************************
* checktf routine
**********************************************************************/
int PLIbook_WatchVar_checktf(int user_data)
{
  if (tf_nump() != 1)
    if (user_data == HEX)
      tf_error("Usage error: $dump_mem_hex(<memory_word_select>);");
  return(0);
}

/**********************************************************************
* misctf routine
*
* The misctf routine is used to call tf_nodeinfo() at the 
* beginning of simulation, so that the memory allocated by 
* tf_nodeinfo() is only allocated one time for each instance of
* $dump_mem_??.
**********************************************************************/
int PLIbook_WatchVar_misctf(int user_data, int reason)
{
  p_tfnodeinfo node_info;  /* pointer to structure for tf_nodeinfo() */

		FILE		*fp;
		char		*line;
		
#define	MAX_LENGTH	80
  int i;
  
  if (reason != REASON_ENDOFCOMPILE)
    return(0);  /* exit now if this is not the start of simulation */
  
  /* allocate memory for an s_tfexprinfo structure */
  node_info = (p_tfnodeinfo)malloc(sizeof(s_tfnodeinfo));

  /* Get the nodeinfo structure for tfarg 1 */
  if (!tf_nodeinfo(1, node_info)) {
    tf_error("Err: $dump_mem_?? could not get tf_nodeinfo for tfarg 1");
    tf_dofinish(); /* about simulation */
    return(0);
  }
  else if (node_info->node_type != TF_MEMORY_NODE) {
    tf_error("Err: $dump_mem_?? arg is not a memory word -- aborting");
    tf_dofinish(); /* about simulation */
    return(0);
  }
  else
    tf_setworkarea((char *)node_info); /*put info pointer in workarea*/

	io_printf("\nMemory architecture:\n");
	io_printf(" Memory array width=%d  depth=%d  ngroups=%d\n",
               node_info->node_vec_size,
               node_info->node_mem_size,
               node_info->node_ngroups);

	io_printf(" node_ms_index = %d    node_ls_index = %d\n\n",
          node_info->node_ms_index, node_info->node_ls_index);
          
	/* initialise variables infos */
	for (i=0;i<NBR_VAR;i++)
	{
//		table_var[i].active = 0;
		table_var[i].name[0] = '\0';
	}
	
	/* read from file the variables info */
	{
		

//		fp = fopen(tf_strgetp(FILENAME, 'h'), "r");
		fp = fopen("WatchVar.txt", "r");
		line = (char *) malloc(MAX_LENGTH);
						
		i=0;
		/* find out the word main */
		while(!feof(fp) && (i < NBR_VAR))
		{
			fgets(line, MAX_LENGTH, fp);
			sscanf(line, "%i %20s %x %i %i",&(table_var[i].active), table_var[i].name, &(table_var[i].addr), &(table_var[i].type), &(table_var[i].length));
			i++;
		}
		table_var[i].active = 0;
	}
  return(0);
}

/**********************************************************************
* calltf routine
**********************************************************************/
int PLIbook_WatchVar_calltf(int user_data)
{
  p_tfnodeinfo node_info;
  int i;

  node_info = (p_tfnodeinfo)tf_getworkarea();/*get info pointer from workarea*/

	if (user_data == HEX){      /* application called by $dump_mem_hex */
		for (i=0;i<NBR_VAR;i++)
		{
			if (table_var[i].name[0] == '\0') break;
			if (table_var[i].active)
				PLIbook_WatchVarHex(node_info, table_var[i]);
		}
	}

  return(0);
}

/**********************************************************************
* Function to dump each word of a Verilog array in hexadecimal
**********************************************************************/
void PLIbook_WatchVarHex(
	p_tfnodeinfo	node_info,
	s_variable		info_variable
	)
{
	char *aval_ptr;//, *bval_ptr;
	int   word_increment, mem_address, group_num;
	int   octet, index=0;
	
	if ((info_variable.addr + info_variable.length * info_variable.type)>node_info->node_mem_size)
		return;
		
	io_printf("Watch: %s\n", info_variable.name);
	word_increment = node_info->node_ngroups * 2;
	for (mem_address = info_variable.addr;
	       mem_address < info_variable.addr + info_variable.length * info_variable.type;
	       mem_address += info_variable.type)//mem_address++)
	{
	
		io_printf("@%8.8x: [%i]=", mem_address,index++);
				
		/* set pointers to aval and bval words for the address */
		aval_ptr = node_info->node_value.memoryval_p
			               + (mem_address * word_increment);

	    for(octet = info_variable.type - 1;
	    	octet >= 0;
	    	octet--)
	    {
			
			/* print groups in word in reverse order so will match Verilog:
				the highest group number represents the left-most byte of a
				Verilog word, the lowest group represents the right-most byte */
			for (group_num = node_info->node_ngroups - 1;
			         group_num >= 0; 
			         group_num--)
			{
				io_printf("%2.2x", (unsigned char)aval_ptr[group_num]);
			}
			
			aval_ptr += word_increment;
			
		}	
		io_printf("\n");
	}
	io_printf("\n");
	return;
}



/*********************************************************************/
