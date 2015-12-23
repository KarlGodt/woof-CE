[indent=4]


/*----------------------------------------------------

  this is the MAIN program.
  here you initialize all libraries,
  build your window,
  and define the actions for the window.



------------------------------------------------------*/


uses
    Gtk


//-- Global variables --

window1 : Window
picview : Picviewclass

//-- custom methods --
def set_title()

    var name = picview.filename.get_text()
    window1.set_title(Filename.display_basename(name))
    return


def drop(d : Gdk.DragContext , x : int, y : int , sel : Gtk.SelectionData, info : uint , timestamp : uint) 


    //-- manage drag n drop --
    
    var uriustring =  (string) sel.data
    var uri = uriustring.split("\n")[0].strip()

    picview.load_picture(uri)
    return

//-- main program --

init

    Gtk.init (ref args) 

    //-- build the first window -- 




    window1 = new Gtk.Window (Gtk.WindowType.TOPLEVEL) 
    window1.set_default_size (Gdk.Screen.width() /2 , Gdk.Screen.height()-100) 
    
    //window1.set_default_size (200 , 200)
    
    window1.destroy += Gtk.main_quit 
    window1.set_title("Picture viewer") 
    window1.move(0 , 40) 
  
    var vbox = new Gtk.VBox(false , 1) 
    vbox.border_width = 10 
    vbox.spacing = 10 
    vbox.show()
    window1.add (vbox) 
    
   
    //-- use the class --    
 
    picview = new Picviewclass ()
    
    picview.init()
    vbox.add(picview.vbox)    

    window1.show()  
    
    
    //-- add some buttons to run helpfull programs --
    
    //BKpicview.add_run_button("gqview" , "gqview")
    //BK have edited the following buttons...
    
    picview.add_run_button("mtpaint" , "mtpaint")
    
    picview.add_run_button("wallpaper" , "set_wallpaper")
    
    picview.add_run_button_pdf("EPDFview" , "epdfview")
 

 
    //var thefile = Environment.get_current_dir() + "/1.pdf"
    var thefile = Environment.get_current_dir() + "/graphics.png"
    
    if args.length > 1
        thefile = args[1]
 



    //-- react on a change --
    picview.filename.changed += set_title
    
    //-- must load a picture AFTER window is visible ! --

    picview.load_picture(thefile)

    //-- must set resize event AFTER picview was assigned to a window ! --    
    window1.check_resize += picview.on_size_request  
   
    
    //-- add a custom drag and drop action --
    picview.eventbox.drag_data_received += drop

    Gtk.main ()



