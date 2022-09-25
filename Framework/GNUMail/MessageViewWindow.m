/*
**  MessageViewWindow.m
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "MessageViewWindow.h"

#include "ExtendedTextView.h"
#include "Constants.h"

//
//
//
@implementation MessageViewWindow

- (void) dealloc
{
  [super dealloc];
}

//
//
//
- (void) awakeFromNib
{  
  [textView setTextContainerInset: NSMakeSize(5,5)];
  [textView setBackgroundColor: [NSColor textBackgroundColor]];
  [textView setRichText: YES];
  [textView setUsesFontPanel: YES];
  [textView setHorizontallyResizable: NO];
  [textView setVerticallyResizable: YES];

  [[textView textContainer] setWidthTracksTextView: YES];
  [textView setEditable: NO];
  [textView setString: @""];
}

@end
