# For complete documentation of this file, please see Geany's main documentation
[styling]
# foreground;background;bold;italic

#default=0x000000;0x89ef0f;true;false
default=0x000000;0xffffff;true;false
##black;white;

commentline=0xF5A80D;0xffffff;true;true
##orange=F5A80D ;was=0xCCC7C7

number=0x007f00;0xffffff;true;false
##dark green;white;

word=0x111199;0xffffff;true;false
##dark blue;white;

string=0x000000;0xffffff;true;false
##black;white;

character=0x404000;0xffffff;true;false
##dark olive;white;

operator=0x301010;0xffffff;true;false
##black red;white;

identifier=0x000000;0xffffff;true;false
##black;white;

backticks=0x000000;0x89ef0f;true;false
##black;light gray=0xd0d0d0;

param=0x009f00;0xffffff;true;false
##green;white;

scalar=0x105090;0xffffff;true;false
##dark blue;white;

error=0xff0000;0xffffff;true;false
##red;white;

here_delim=0x000000;0x89ef0f;true;false
##black;purple white=0xddd0dd;

#here_q : unused background ?
#here_q=0x7f007f;0x89ef0f;true;false
here_q=0x000000;0xffffff;true;false
##dark purple;purple white;neon green=0x89ef0f

[keywords]
primary=break case continue do done elif else esac eval exit export fi for function goto if in integer return set shift then until while


[settings]
# default extension used when saving files
#extension=sh

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# if only single comment char is supported like # in this file, leave comment_close blank
comment_open=#
comment_close=

# set to false if a comment character/string should start a column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments
comment_use_indent=true

# context action command (please see Geany's main documentation for details)
context_action_cmd=

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)
run_cmd="./%f"
