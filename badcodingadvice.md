![image-20230407123603907](/home/hoefkens/image-20230407123603907.png)

# This Truly is A NON-Issue. 



ths is just an example of aticles like these , and for whatever reason , trying to boast themselves as a true connaisseur of the craft. Sell you something? Make the next generation of programmers weary of certain keywords,... limit their powers by handicapping them? i have no clue. But really if you think about it about 2 seconds you realize this is just a load of big fucking shit.

## Some Cheap-Shots:

lets use the example he used: an no i wont be bitching about the fact that only on linux or macos or any bsd this will work , nor will i make a cheap shot by notifying that you can print the contents of /etc/password as much as you like , in fact here is the first few lines of mine:

<img src="/home/hoefkens/image-20230407124354590.png" alt="image-20230407124354590" style="zoom:150%;" />

pleas informe me what you can possibly get of usefull info out of there... since long all passwords moved to be stored as a hash value , instead of as plain text in /etc/password, and with that they moved to /etc/shadow.... not that getting that file will do anyone much good , her is the first 5 of mine: 

<img src="/home/hoefkens/image-20230407124640879.png" alt="image-20230407124640879" style="zoom:150%;" />

### But now to the actual reason

its actually not that hard to see why ,... think of any place there a programs user is asked for or is able to give a program input... now remove any place where its not required that the user should be able to input code of some form... whats left over? maybe, thinking about forum software where posts can include code.. if somehow that code gets beyond the function that actually deals with ingesting the users textfield unescaped and/or url/web encoded making the actual code a string with formatting included, wich wont even remotly validate as python code anymore , wel if it gets past that function , there is your security failure. any others. nope? aah pistonbot , discord chatbot that runs code .... well in that case the code should actually be run regardless... and asking for 'securty protected' files should be part of it.  so perhaps , security there comes from sandboxing the 'whole chroot' that runs the users code... no really where does it make sense that the user is able to input all possible characters to make python code , and at the same time makes sense to some run eval on that input. input name should not be eval()'d a simple calculator , shoulld not allow for anything other then numbers and operators ... as far as i know ' and "  arent used in math aside for degrees minuts and seconds , besides any one just gonna run eval() on a math input field or , are you goning to parse it , or pass it trought shlex or anything first , since python is rather unforginving in its math syntax , something what most users will have problems with figuring out , remaking excel? whel in that case eval() should prolly be used in some circumstanses but then again if that is the case your security should not stem from not using eval. but from what can be accessed directly from within the program,... ask any microsoft developer that worked on outlook how good of an idea it is to not shield the program internals from the rest of the os ... if thats doen eval is safe again.. so ...