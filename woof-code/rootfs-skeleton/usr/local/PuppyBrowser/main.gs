[indent=4]

uses
    Gtk


//-- global variables --

param_url : string
param_width : int
param_height : int
param_x : int
param_y : int
param_title : string
param_profile : string
window1 : Window


def get_options(a : array of string)

    for var i = 1 to (a.length -1)
        //print("%s" , a[i])
        
        if a[i] is "" do continue
        if not a[i].contains("=")
            param_url = a[i].strip()
        else
            if a[i].contains("?")
                param_url = a[i].strip()
                continue
        
            var s = a[i].split("=",2)
            if s[0].strip() is "-w" 
                param_width = s[1].to_int()
                continue
                
            if s[0].strip() is "-h" 
                param_height = s[1].to_int()
                continue                

            if s[0].strip() is "-x" 
                param_x = s[1].to_int()
                continue
                
            if s[0].strip() is "-y" 
                param_y = s[1].to_int()
                continue                    
                
                
            if s[0].strip() is "-title" 
                param_title = s[1].strip()
                continue

                
            if s[0].strip() is "-profile" 
                param_profile = s[1].strip()
                continue                

init

    //-- analyse comandline arguments, init gtk --

    //param_url=args[1]


    Gtk.init (ref args)
    
    param_width = Gdk.Screen.width() /2
    param_height = Gdk.Screen.height()-100
    param_x = 0
    param_y = 40
    param_title = "Puppy Browser"
    param_profile="default"

    param_url = "file:///usr/share/doc/index.html" /*BK"http://google.com"*/

    get_options(args)

    if param_url == "--help"

        print "options: 'url' '-title=title' -x=x -y=y -w=width -h=height -profile=profilename"
        return


    
    //-- build window now, not in the class, so that later new instances might be added to tabs --

    window1 = new Gtk.Window (Gtk.WindowType.TOPLEVEL) 
    window1.set_default_size ( param_width , param_height ) 
    window1.destroy += Gtk.main_quit 
    window1.set_title(param_title) 
    window1.move(param_x , param_y) 
  
    var vbox = new Gtk.VBox(false , 0) 
    vbox.border_width = 0 
    vbox.spacing = 0
    vbox.show()
    window1.add (vbox) 
    


    //-- this path does not need to exist, but must be set to avoid crashes --

    MozEmbed.set_profile_path( Environment.get_home_dir() + "/.PuppyBrowser/" , "mozilla") /*BK*/

    
    //MozEmbed.set_profile_path("/root/.mozilla/default/" , "r3y1skkw.slt")
    
    
    //-- create an instance of the viewer --
    
    //window1.show_all ()
    
    print("%s" , param_profile)

    
    var hw = new HtmlViewer ()
    hw.init(param_profile)
    
    //-- attach it to the window, show it --
    vbox.pack_start(hw.vbox,true , true ,0)
    
    window1.show()

    //-- open the web page --
    //print("-- %s" , param_url)
    hw.load(param_url) 


    Gtk.main ()
