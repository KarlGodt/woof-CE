# For complete documentation of this file, please see Geany's main documentation
[styling]
# Edit these in the colorscheme .conf file intead
default=default
comment=comment
commentml=comment_doc
identifier=identifier_1
control=keyword_1
keyword=keyword_1
defword=keyword_2
preword1=keyword_3
preword2=keyword_4
number=number_1
string=string_1
locale=other


[keywords]
# all items must be in one line
primary=ABORT EXIT DO LOOP UNLOOP BEGIN UNTIL WHILE REPEAT EXIT IF ELSE THEN CASE ENDCASE OF ENDOF


[settings]
# default extension used when saving files
extension=fs

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file
comment_single=\\ 
# multiline comments
comment_open=(
comment_close= )

# comment_open=\
# comment_close=

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments
comment_use_indent=true

# context action command (please see Geany's main documentation for details)
context_action_cmd=
