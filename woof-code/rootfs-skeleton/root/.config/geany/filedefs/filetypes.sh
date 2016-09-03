# For complete documentation of this file, please see Geany's main documentation
[styling]
# foreground;background;bold;italic
default=0x000000;0xffffff;false;false
# orig red on white
#commentline=0xd00000;0xffffff;false;false
# red on gray
commentline=0xd00000;0xd0d0d0;false;false
number=0x007f00;0xffffff;false;false
word=0x111199;0xffffff;true;false
# orig orange
#string=0xff901e;0xffffff;false;false
# pale brown also pale inverted
#string=0xddb58d;0xffffff;false;false
# medium brown ->medium dark blue inv
#string=0xd77e23;0xffffff;false;false
# medium pink -> unreadable black? inverted
#string=0xffc0cb;0xffffff;false;false
# darker lila
string=0x9716c0;0xffffff;false;false
character=0x404000;0xffffff;false;false
operator=0x301010;0xffffff;false;false
identifier=0x000000;0xffffff;false;false
# orig gray
#backticks=0x000000;0xd0d0d0;false;false
# yellow
backticks=0x000000;0xffff00;false;false
param=0x009f00;0xffffff;false;false
scalar=0x105090;0xffffff;false;false
error=0xff0000;0xffffff;false;false
here_delim=0x000000;0xddd0dd;false;false
here_q=0x7f007f;0xddd0dd;false;false

[keywords]
primary=alias bg break case cd command continue declare do done echo elif else esac eval exec exit export false fg fi for function hash if in jobs kill let local read return set shift source [ test ] then trap true type unset until wait while cp rm rmdir mv ln ls cat du df tac grep sed awk find file mkdir
#secondary=cp rm rmdir mv ln ls cat du df tac grep sed awk find file mkdir

[settings]
# default extension used when saving files
extension=sh

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file
comment_single=#
# multiline comments
#comment_open=
#comment_close=

# set to false if a comment character/string should start a column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
    #command_example();
# setting to false would generate this
#   command_example();
# This setting works only for single line comments
comment_use_indent=true

# context action command (please see Geany's main documentation for details)
context_action_cmd=

[indentation]
#width=4
# 0 is spaces, 1 is tabs, 2 is tab & spaces
#type=1

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)
run_cmd="./%f"
