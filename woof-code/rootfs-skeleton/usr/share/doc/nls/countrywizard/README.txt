COUNTRYWIZARD
This is a alternative of classic countrywizard.

*KEYMAPS
If the file named 'keympas' is not exists, countrysetup makes a file '/tmp/countrywizard-keymaps' at the first run.
You can copy it and rename as '/usr/share/i18n/keymaps'. It is prefered if you make the remaster of puppy.

*ABOUT LANGUAGES
countrysetup makes language menu from 2 files, /usr/share/i18n/languagelist.data and /usr/share/i18n/shortlists.
Languages in shortlist apears at the top of the list in this order.
Others in languagelist.data follows with alphabetically sorted.
All the languagelist.data is not apears on the menu. It is selected depend on the fonts installed.

*ABOUT NLS
Translations can be made using countrysetup.pot in nls directory. Or, you can make new pot with next command (devx required).
# cd /usr/sbin
# xgettext --lang=shell --from-code=utf-8 -o countrywizard.pot countrywizard.qs extralang

Make the translation using poedit or proper tool. Place countrywizard.mo at /usr/share/locale/??/LC_MESSAGES where '??' is the language code.
But the translations may not be effective because it is available only after the locale is set.
