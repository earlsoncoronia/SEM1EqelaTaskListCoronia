/*
 * TaskListWidget
 * Created by Eqela Studio 2.0b7.4
 */

class TaskListWidget : LayerWidget, EventReceiver
{
	class AddEvent
	{	
	}

    TextInputWidget text;
    ListSelectorWidget list;
	Collection items;

    public void initialize() {
        base.initialize();
        set_draw_color(Color.instance("black"));
        add(CanvasWidget.for_color(Color.instance("white")));
        var vbox = BoxWidget.vertical();
        vbox.set_margin(px("1mm"));
        vbox.set_spacing(px("1mm"));
        var input = BoxWidget.horizontal();
        input.set_spacing(px("1mm"));
        input.add_box(1, text = TextInputWidget.instance());
        input.add_box(0, ButtonWidget.for_string("Add").set_event(new AddEvent()));
        vbox.add(input);
        list = ListSelectorWidget.instance();
        list.set_show_desc(false);
        list.set_show_icon(false);
        vbox.add_box(1, list);
        add(vbox);
		text.set_listener(this);
		load_items();
    }


    public void cleanup() 
	{
        base.cleanup();
        list = null;
        text = null;
    }

	void on_items_changed() 
	{
		
        if(list != null) 
		{
            list.set_items(items);
        }

		save_items();
    }

    void add_item(String item) 
	{
        if(String.is_empty(item)) 
		{
            return;
        }

        if(items == null) 
		{
            items = LinkedList.create();
        }

        items.prepend(item);
        on_items_changed();
    }

    void on_add_event() 
	{
        add_item(text.get_text());
        text.set_text("");
        text.grab_focus();
    }

    public void on_event(Object o) 
	{
		if(o is TextInputWidgetEvent && ((TextInputWidgetEvent)o).get_selected()) 
		{
            on_add_event();
            return;
        }
	
        if(o is AddEvent) 
		{
            on_add_event();
            return;
        }

		if(o is String) 
		{
            Popup.widget(get_engine(), new DeleteConfirmDialog().set_widget(this).set_todelete((String)o));
            return;
        }
    }

	public void start()
	{
    	base.start();
        if(text != null) 
		{
            text.grab_focus();
        }
    }

	public void delete_item(String todelete) 
	{
        items.remove(todelete);
        on_items_changed();
    }

	class DeleteConfirmDialog : YesNoDialogWidget
    {
        property TaskListWidget widget;
        property String todelete;

        public void initialize() 
		{
            set_title("Confirmation");
            set_text("Are you sure to delete the task `%s'".printf().add(todelete).to_string());
            base.initialize();
        }

        public bool on_yes() 
		{
            widget.delete_item(todelete);
            return(false);
        }
    }

	void save_items() 
	{
        var ad = ApplicationData.for_this_application();

        if(ad == null) 
		{
            return;
        }

        ad.mkdir_recursive();
        var sb = StringBuffer.create();

        foreach(String item in items) 
		{
            sb.append(item);
            sb.append_c('\n');
        }

        ad.entry("items.txt").set_contents_string(sb.to_string());
    }

    void load_items() {
        var ad = ApplicationData.for_this_application();
        if(ad == null) {
            return;
        }
        var i = LinkedList.create();
        foreach(String line in ad.entry("items.txt").lines()) {
            i.add(line);
        }
        items = i;
        on_items_changed();
    }
}	
