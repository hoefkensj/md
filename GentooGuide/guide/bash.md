## Bash Login Shell:

```bash
if [ -e /etc/profile.env ] ; then
	. /etc/profile.env
fi     
```

```ba
# process *.sh files in /etc/profile.d                                                                                                                                                                          
for sh in /etc/profile.d/*.sh ; do                                                                                                                                                                              
        [ -r "$sh" ] && . "$sh"                                                                                                                                                                                 
done                                                                                                                                                                                                            
unset sh   

```



```bash
 if [ -f /etc/bash/bashrc ] ; then                                                                                                                                                                       
                # Bash login shells run only /etc/profile                                                                                                                                                       
                # Bash non-login shells run only /etc/bash/bashrc                                                                                                                                               
                # Since we want to run /etc/bash/bashrc regardless, we source it                                                                                                                                
                # from here.  It is unfortunate that there is no way to do                                                                                                                                      
                # this *after* the user's .bash_profile runs (without putting                                                                                                                                   
                # it in the user's dot-files), but it shouldn't make any                                                                                                                                        
                # difference.                                                                                                                                                                                   
                . /etc/bash/bashrc                                                                                                                                                                              
        else                              
```





```bash
d
```





```bash
d
```





```bash
d
```





```bash
d
```





```bash
d
```





