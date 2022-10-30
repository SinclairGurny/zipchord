# ZipChord Keyboard

_ZipChord_ is a customizable hybrid keyboard input method for Windows that augments regular typing with chorded entry. For a discussion of why that might be useful, see [ZipChord: Hybrid Chorded Keyboard](https://pavelsoukenik.com/zipchord-hybrid-chorded-keyboard).  

## Installation

Download and save the executable **zipchord.exe** of the latest [release](https://github.com/psoukie/zipchord/releases) in a folder where you have read and write access, and run it. (Optionally, download a dictionary from the dictionaries folder to use as a starting point.)

(Note that _ZipChord_ has not been ported to MacOS because of its dependency on AutoHotKey.)

## Using ZipChord

Type normally using individual keystrokes in combination with predefined chords (several keys pressed at the same time which type out either whole words or prefixes and suffixes). _ZipChord_ uses smart spaces and capitalization to add (or remove) spaces as needed to separate words, whether they were typed using individual strokes or chords, and to capitalize words as selected.

### Defining New Chords

To define a new chord, select the word you want to define a chord for, and **press and hold Ctrl-C** until a dialog box appears. Next, type the individual keys (without pressing Shift or any function keys) and click OK.

Note that if the selected text is already defined in the chord dictionary, holding Ctrl-C will remind you of its chord.

## Menu Options

To open the menu, click the _ZipChord_ icon in the Windows tray or press and hold **Ctrl-Shift-C** until it appears.

### Dictionary

The dictionary group shows the currently loaded chord dictionary and the number of chords it contains. You can select a different dictionary file using the **Open** button, edit its chords directly in default text editor (**Edit**), and **Reload** the dictionary when you make changes to the chord file directly in an editor.

Notes:
* See [below](#chord-dictionary) for more details about the chord dictionary file and advanced features.
* When you add chords by selecting text and pressing and holding Ctrl-C, the new chord is added automatically, and you do not need to open the menu to edit or reload the dictionary.

### Sensitivity

This group allows you to adjust the sensitivity of the chord recognition and add a delay to the output of the chords.

**Input delay:** Depending on your regular typing, you might be holding two or more keys pressed at the same time for longer than the threshold that triggers the chord recognition. This can result in some intended key presses in your regular typing being deleted or misinterpreted as chords. In that case, you can increase the number of milliseconds under Input delay.

**Output delay:** In some situations, the window you are typing in might be outputting the chords with some distortions (where keystrokes are replaced incorrectly). In that case, you can try setting the Output delay to 50ms, which can solve the issue.

### Enabling and Disabling the Chords

You can temporarily disable the chord recognition by unchecking the **Recognition enabled** checkbox.

## Chord Dictionary

_ZipChord_ uses a separate text file with a dictionary of chords and the full words. _ZipChord_ will remember the last used dictionary. (Note: When you run _ZipChord_ for the first time or the dictionary isn't available, it will either open a chord*.txt file in its working folder or create a new chord.txt.)

Chord dictionaries are text files which define each chord on a separate line. Each entry is defined as follows:

* Lowercase keys that form the chord (the key order does not matter, space bar is represented by a single space)
* A single Tab character (note that spaces cannot be used instead of tabulator)
* The word that the chord produces. (Lowercase unless it is a proper name.)

Blank lines and lines without a tab are ignored and can be used as comments.

_ZipChord_ will notify you if two words are attempting to use the same chord, such as in the following example where two words are using the chord W N.
```
wn   win
ths  this
nw   new
```
Note that if you edit the dictionary file directly in a text editor, you need to click the Reload button from the _ZipChord_ menu for the changes to be loaded.

### Special Characters

Key that activate a chord can only consist of alphanumerical keys, including space bar (simply type a space in the chord, e.g. "` w`"), number keys, and keys for comma, semicolon etc. (,./;'[]-=\\). Note that Shift, Control, Tab and other function keys cannot be used in a chord.

The words entered using a chord can include the following special features:

* **Suffixes**: To define suffixes that can be entered using a chord and joined to the last word, start the word definition with ~. Example: `;g  ~ing` (pressing **;** and **G** together will add "ing" to the last word). Note that `~~ing` would also remove the last character of the preceding word.
* **Prefixes**: For prefixes, place the `~` at the end of the prefix (such as `pre~`). This will ensure there will be no space after the chord.
* **Special keys**: Other keys can be entered using expressions in curly braces: {Left}, {Right}, {Up}, {Down} for cursor, {Tab} and {Enter} can all be used.

## Feedback

If you have any feedback, feature requests, or encounter a bug, please [file an issue](https://github.com/psoukie/zipchord/issues/new). You can contact write to me on Twitter at [@pavel_soukenik](https://twitter.com/pavel_soukenik).
