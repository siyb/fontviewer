#!/usr/bin/env wish8.5
# Copyright (c) 2010, Patrick Sturm <siyb@geekosphere.org>
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#    This product includes software developed by geekosphere.org / geekosphere.
# 4. Neither the name geekosphere.org / geekosphere nor the
#    names of its contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY Patrick Sturm ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Patrick Sturm BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# History
# Version 0.5.2
#
# - Some visual enhancements
#
# Version 0.5
# 
# - Added file preview option
# - Fonts are sorted alphabetically now
#
# Version 0.4
#
# - Added box for entering text
#
# Version 0.3
#
# - Added color to buttons whose modifier is active (bold, underline, overstrike, italic)
# - Added color setting
# - Added maxSize setting, allowing users to modify the maximal display size of the font (dropdown menu)

#
# Config
#

# set the text to be displayed here
set text "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890?"

# set the maximum displayable size of the font, 72 should be sufficient :)
set maxSize 72

#
# Code
#
package require Tk 8.5
package require XTk

set bold 0
set italic 0
set underline 0
set overstrike 0

set families [lsort [font families]]
for {set i 1} {$i <= $maxSize} {incr i} { lappend slist $i }

set genCode [xtk::load ./fontviewer.xml]
puts $genCode
xtk::run $genCode

trace add variable text write adjustWidth

# configure default font
$fontSizes set 12
set defaultFont [lindex $families 0]
$fontTypes set $defaultFont
set fonts($defaultFont) [font create -family $defaultFont -size 12]

proc bindCallback {path args} {
	global fontSizes fontTypes
	if {$path eq $fontTypes} {
		setFont
	} elseif {$path eq $fontSizes} {
		setSize
	}
}

proc preview {} {
	global env fonts fontTypes
	set path [tk_getOpenFile -initialdir $env(HOME) -multiple false -title "File Preview" \
		-filetypes {
			{{All Files} *}
		}]
	if {$path eq ""} { return }
	if {![winfo exists .textPreview]} {
		set font [$fontTypes get]
		toplevel .textPreview
		pack [ttk::scrollbar .textPreview.scroll -command {.textPreview.text yview}] -side right -fill y
		pack [text .textPreview.text -fg black -wrap word -yscrollcommand {.textPreview.scroll set} -font $fonts($font)] -side left -fill both -expand 1
	}
	if {![file exists $path]} { return }
	.textPreview.text configure -state normal
	set data [read [set fl [open $path r]]];close $fl
	.textPreview.text delete 0.0 end
	.textPreview.text insert 0.0 $data
	.textPreview.text configure -state disabled
}

proc setFont {} {
	global fonts bold italic underline overstrike fontSizes fontTypes
	set font [$fontTypes get]
	set size [$fontSizes get]
	if {$bold} { set bolds "bold" } { set bolds "normal" }
	if {$italic} { set italics "italic" } { set italics "roman" }
	if {![info exists fonts($font)]} {
		set fonts($font) [font create -family $font -size $size -overstrike $overstrike -underline $underline -weight $bolds -slant $italics]
	} else {
		font configure $fonts($font) -overstrike $overstrike -underline $underline -weight $bolds -slant $italics
	}
	$::textfield configure -font $fonts($font)
	if {[winfo exists .textPreview.text]} {
		.textPreview.text configure -font $fonts($font)
	}
}

proc setSize {} {
	global fonts
	set size [$::fontSizes get]
	set font [lindex [$::textfield configure -font] end]
	font configure $font -size $size
}

proc toggleBold {} {
	global bold b
	set font [lindex [$::textfield configure -font] end]
	if {[font configure $font -weight] eq "normal"} {
		font configure $font -weight bold
		set bold 1
		toggleButtonSet $b(bold) 1
	} else {
		font configure $font -weight normal
		set bold 0
		toggleButtonSet $b(bold) 0
	}
}

proc toggleItalic {} {
	global italic b
	set font [lindex [$::textfield configure -font] end]
	if {[font configure $font -slant] eq "roman"} {
		font configure $font -slant italic
		set italic 1
		toggleButtonSet $b(italic) 1
	} else {
		font configure $font -slant roman
		set italic 0
		toggleButtonSet $b(italic) 0
	}
}

proc toggleUnderline {} {
	global underline b
	set font [lindex [$::textfield configure -font] end]
	if {[font configure $font -underline]} {
		font configure $font -underline 0
		set underline 0
		toggleButtonSet $b(underline) 0
	} else {
		font configure $font -underline 1
		set underline 1
		toggleButtonSet $b(underline) 1
	}
}

proc toggleOverstrike {} {
	global overstrike b
	set font [lindex [$::textfield configure -font] end]
	if {[font configure $font -overstrike]} {
		font configure $font -overstrike 0
		set overstrike 0
		toggleButtonSet $b(overstrike) 0
	} else {
		font configure $font -overstrike 1
		set overstrike 1
		toggleButtonSet $b(overstrike) 1
	}
}

proc toggleButtonSet {button on} {
	global b buttonHightlight
	if {$on} {
		$button state {pressed !focus}
	} {
		$button state {!pressed !focus}
	}
}

proc adjustWidth {args} {
	global text
	$::textfield configure -width [string length $text]
}

proc setTheme {} {
  global tcl_platform

  set themes {tile-qt tile-gtk clam}

  if {$tcl_platform(platform) eq "windows"} {
    lappend themes winnative
    if {$tcl_platform(osVersion) >= 5.1} {
      lappend themes winxpnative
    }
    if {$tcl_platform(osVersion) >= 6.0} {
      lappend themes vista
    }
  }

  if {$tcl_platform(platform) eq "macintosh" || $tcl_platform(os) eq "Darwin"} {
    lappend themes aqua
  }

  foreach theme [lreverse $themes] {
    if {$theme in [ttk::themes]} {
      ttk::style theme use $theme
      break
    }
  }
}


# Initialize theme and font

setTheme
setFont
