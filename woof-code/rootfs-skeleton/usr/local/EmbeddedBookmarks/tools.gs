[indent=4]


/*----------------------------------------------------

  this file contains some general helpfull methods

  you might add others here, to keep your 
  mainprogram short.

  So you can set up a tool library for use in other 
  programs, too.

------------------------------------------------------*/

//-- run a program in background --
def exec(thecmd : string)
    //print("%s" , thecmd)
    try
        Process.spawn_command_line_async(thecmd)
    except ex : GLib.Error
        print("%s", "exec failed: " + thecmd)


def run(thecmd : string)
    //print("%s" , thecmd)
    try
        Process.spawn_command_line_sync(thecmd)
    except ex : GLib.Error
        print("%s", "exec failed: " + thecmd)


//-- run a command and return the output --
def shell(thecmd : string) : string
    //print("%s" , thecmd)
    ret_stdout:string
    ret_stdout = ""
    ret_stderr:string
    ret_status:int
    try
        Process.spawn_command_line_sync(thecmd,out ret_stdout,out ret_stderr,out ret_status)
    except ex : GLib.Error
        print("%s", "run failed!")
    return ret_stdout

    
//-- run a command and return the output --
def exec_pipe(thecmd : string , thearg1 : string, thearg2 : string, thearg3 : string , thearg4 : string, thearg5 : string) :int

    a : array of string = {thecmd , thearg1 , thearg2 , thearg3, thearg4, thearg5}
    //b : array of string = {""}
    pid : int
    thein:int
    theout:int
    theerr:int
    try
        Gdk.spawn_on_screen_with_pipes(Gdk.Screen.get_default(),null , a,null,SpawnFlags.SEARCH_PATH|SpawnFlags.DO_NOT_REAP_CHILD  ,null,out pid, out thein, out theout, out theerr)
    except ex : GLib.Error
        print("%s", "run failed!")
    
    //print("%d\n" , theout)

    //SpawnFlags.SEARCH_PATH
    
    return thein

//-- run a command and return the output --
def exec_pipe2(thecmd : string , thearg1 : string, thearg2 : string, thearg3 : string , thearg4 : string) :array of int

    a : array of string = {thecmd , thearg1 , thearg2 , thearg3, thearg4}
    //b : array of string = {""}
    pid : int
    thein:int
    theout:int
    theerr:int
    try
        Gdk.spawn_on_screen_with_pipes(Gdk.Screen.get_default(),null , a,null,SpawnFlags.SEARCH_PATH|SpawnFlags.DO_NOT_REAP_CHILD  ,null,out pid, out thein, out theout, out theerr)
    except ex : GLib.Error
        print("%s", "run failed!")
    
    //print("%d\n" , theout)

    //SpawnFlags.SEARCH_PATH
    
    ret: array of int = {thein , theout}
    return ret


/*
def read_file_to_list(thefile : string) : list of string
    var l = new list of string
    var f = FileStream.open(thefile , "r")
    var a = new array of char[1024]
    while f.gets(a) is not null
        var s = (string)a
        l.add(s)

    return l
*/

def read_file_to_array(thefile : string) : array of string
    

    text : string 
    text = ""
    len : int 
    try
        FileUtils.get_contents (thefile, out text, out len) 
    except e:Error 
        print "load error"

    var l = text.split("\n")
    return l

def windows_drives () : array of string


    /*
    check : array of string = {"C:" , "D:" , "E:" , "Z:"}
    l : int
    l = check.length -1
    newstring : string
    newstring = ""
    for var i = 0 to l
        try
            if GLib.FileUtils.test( check[i] , GLib.FileTest.EXISTS )
                newstring = newstring + check[i] + "-"
                print("%s" , check[i])
        
        except
            print("%s" , "oops")
        
    if newstring.substring(-1) is "-"
        newstring = newstring.substring(0, newstring.length-1)

    var newarray = newstring.split("-")
    */

    newarray : array of string = {"C:" , "D:" , "E:" , "F:" , "G:", "H:" , "I:" , "J:" , "Y:" , "Z:"}
    
    return newarray

//-- sort a stringarray --

def natsortarray( le :int , thelist : array of string): array of string

    inOrderFlag : bool
    var i=le
    while i > 0
    
        inOrderFlag = true
        var le2 = le-2
        var s1= ""
        var s2=""
        for var j = 0 to le2 
            if thelist[j].down() > thelist[j + 1].down()
                inOrderFlag = false
                s1 = thelist[j]
                s2 = thelist[j + 1]
                thelist[j] = s2
                thelist[j + 1] = s1
     
        if inOrderFlag
             break
             
        i--

    return thelist
