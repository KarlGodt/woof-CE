[indent=4]

/*----------------------------------------------------

  this file contains the libglade related actions
  for our program.

  you must add here the methods, that return
  a widget like a button or a entry if required


------------------------------------------------------*/

uses
    Gtk

xml : Glade.XML
ioc : IOChannel
//iocout : IOChannel
fd : int
watch_id : uint

//http://www.vala-project.org/doc/references/glib-2.0.vapi/GLib/IOChannel.htm

def libglade_init( args : array of string)
    Gtk.init (ref args)
    xml = new Glade.XML ("project.glade", null, null)
    //im = (Image)get_widget("image1")
    //print "000"
    //pixbuf= new Gdk.Pixbuf.from_file("folder.png")
    xml.signal_autoconnect_full (connect_signals)



//-- HELPER method: this is needed for every program using libglade --

def connect_signals (handler_name : string, object : GLib.Object, signal_name : string ,signal_data : string? , connect_object : GLib.Object?, after : bool)
    var module = Module.open (null, ModuleFlags.BIND_LAZY)
    sym : void*

    if (module.symbol (handler_name, out sym))
        Signal.connect (object, signal_name, (GLib.Callback) sym, null)


//-- HELPER method: this method returns a WIDGET ! --
//-- it finds a widget object managed by libglade using the name of the widget --

def get_widget(name : string) : Widget
    var w = xml.get_widget(name)
    return w



//------------------------------------------------- ACTIONS

def on_window1_destroy (widget : Widget)

  //-- exit program when window is closed --
  

    Gtk.main_quit ()



def on_toolbutton_edit_clicked (widget : EventBox, eventbutton : Gdk.EventButton)


    run("leafpad " + Environment.get_home_dir() + "/.EmbeddedBookmarks" + "/" + rcfile)
    exec("/usr/local/EmbeddedBookmarks/embedded-bookmarks")
    Gtk.main_quit ()

    
