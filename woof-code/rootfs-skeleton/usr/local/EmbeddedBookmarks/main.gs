[indent=4]

uses
    Gtk


//-- Global variables --

windows : bool
tree1 : treeclass
window1 : Window

status : Statusbar
glade : string

counter : int
mynames : array of string
mystreams : array of string
myoptions : array of string

rcfile : string

isactive : bool



def tree1_row_click()

    status.push(1 , "")
    //print "click"



    var ret = tree1.foldertree_click()
    //print("-----------------%s" , ret)
    if ret is ""
        return
    if not ret.contains("/")
        return
        
    var pathlist = ret.split("/")
    if pathlist.length <2
        return 
      
        
    //print ("%s" , ret)     
    
     
        
    for var n = 0 to (mynames.length -1)
        //print ("-- %s" , mynames[n])
        if (pathlist[1] + "/" + pathlist[2]) is mynames[n]
            //print ("name: %s" , mynames[n])
            //print ("stream: %s" , mystreams[n])            
            
  
  
            var theurl = mystreams[n]
            var option = myoptions[n]

            var otherprog = false
            var theprog = "/usr/local/PuppyBrowser/puppy-browser -title='" + pathlist[2] + "' -profile=flashviewer "
            if option.contains("-run=")

                var re = new Regex (".*-run=")
                var result2 = re.replace(option, option.len(), 0, "")
                
                re = new Regex (" -converter=.*")
                theprog = re.replace(result2 , result2.len() , 0 , "")
                
                re = new Regex ("|.*")
                theprog = re.replace(theprog , theprog.len() , 0 , "")  
                
                option = option.replace("-run=" + result2 , "")
                otherprog = true

            var conv = ""

            if option.contains("-converter=")
            

                status.push(1,"wait, searching....")
                var r = new Regex (".*-converter=")
                var result = r.replace(option, option.len(), 0, "")
                
                r = new Regex ("-run=.*")
                conv = r.replace(result , result.len() , 0 , "")
                
                r = new Regex ("|.*")
                conv = r.replace(conv , conv.len() , 0 , "")                
                
                theurl = shell ("./converter " + conv + " \"" + theurl + "\"") 
                option = option.replace("-converter=" + result , "")   
                
                status.push(1,"")
                exec(theprog + " " + option + " " + theurl)
                return
                
            if otherprog is true
                exec(theprog + " " +  option + " '" + mystreams[n]+"'")
                return
            
            try
                FileUtils.set_contents("/tmp/EmbeddedBookmarks.htm" , theurl)
 
            except ex : FileError
                print ("%s" , "save error")   

        
            status.push(1,"")
            
            
            print( "theprog %s" , theprog )        
            print( "option: %s" , option )
            print( "conv: %s" , conv)
            print( "theurl: %s" , theurl)
            
        

        
            if mystreams[n].substring(0,4) is "http"
                exec(theprog + " " +  option + " '" + mystreams[n]+"'")
            
            else        
                exec(theprog + " " + option + " /tmp/EmbeddedBookmarks.htm")



            break
            
init

    isactive = false

    rcfile = "channels2.txt"
    if args.length > 1
        rcfile = args[1]

    var cattitle = "category"
    if args.length > 2
        cattitle = args[2]
        
    windows = true
    if not Environment.get_tmp_dir().contains("\\")
        windows = false
    libglade_init(args)
    window1 = (Window)get_widget("window1")
    window1.set_default_size (300 , 500) 
    window1.move(0 , 40)
     

    status = (Statusbar)get_widget("statusbar1")

    tree1 = new treeclass()
    tree1.init()
    tree1.column.set_title("Bookmarks")
    var sw1 = (ScrolledWindow)get_widget("scrolledwindow1")
    sw1.add(tree1.tree)


    window1.show()
    
    var item_A1 = tree1.add_root_item( cattitle )
    
    var channellist = read_file_to_array(Environment.get_home_dir() + "/.EmbeddedBookmarks" + "/" + rcfile)
    
    item : TreeIter
    item = item_A1
    var thepath = ""
    mynames = new array of string[channellist.length]
    mystreams = new array of string[channellist.length]
    myoptions = new array of string[channellist.length]
    counter = 0
    for var theline in channellist
        
        if theline.contains("[category]")
            tree1.set_image("folder.png")
            var name = theline.replace("[category]" , "")
            item = tree1.add_item(name , item_A1)
            thepath = name + "/"
        else
            if theline.contains("|")
                var s = theline.split("|")
                             
                if theline.substring(0,1) is not "#"
                    tree1.set_image("text.png")
                    tree1.add_item( s[0].strip() , item)
                    
                    mynames[counter] = thepath + s[0].strip()
                    myoptions[counter] = s[1].strip() 
                    mystreams[counter] = s[2].strip() 
                    counter ++  

    

    tree1.expand( "0" )
    Signal.connect_after (tree1.tree, "button_release_event", tree1_row_click, null);
    
    Gtk.main ()
