**************************************************
* System Call: F$SUser
*
* Function: Set User ID number
*
* Input:  Y = Desired user ID number
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FSUser         ldx       <D.Proc             get current process dsc ptr
               ldd       R$Y,u               get requested user number
               std       P$User,x            save new user # in process descriptor
               clrb                          no error
               rts                           and return
