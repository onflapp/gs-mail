/*
**  EditWindowToolbar.m
**
**  Copyright (c) 2002-2006 Ludovic Marcotte
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

#include "EditWindowToolbar.h"

#include "Constants.h"

@implementation EditWindowController (EditWindowToolbar)


//
// NSToolbar delegate methods
//
- (void) toolbarDidRemoveItem: (NSNotification *) theNotification
{
  if ([[theNotification userInfo] objectForKey: @"item"] == send)
    {
      DESTROY(send);
    }
  else if ([[theNotification userInfo] objectForKey: @"item"] == insert)
    {
      DESTROY(insert);
    }
  else if ([[theNotification userInfo] objectForKey: @"item"] == addCc)
    {
      DESTROY(addCc);
    }
  else if ([[theNotification userInfo] objectForKey: @"item"] == addBcc)
    {
      DESTROY(addBcc);
    }
  else if ([[theNotification userInfo] objectForKey: @"item"] == addresses)
    {
      DESTROY(addresses);
    }
  else if ([[theNotification userInfo] objectForKey: @"item"] == saveInDrafts)
    {
      DESTROY(saveInDrafts);
    }
}


//
//
//
- (void) toolbarWillAddItem: (NSNotification *) theNotification
{
  id item;
  
  item = [[theNotification userInfo] objectForKey: @"item"];

  if ([[item itemIdentifier] isEqualToString: @"send"])
    {
      send = (id)item;
      RETAIN(send);
    }
  else if ([[item itemIdentifier] isEqualToString: @"insert"])
    {
      insert = (id)item;
      RETAIN(insert);
    }
  else if ([[item itemIdentifier] isEqualToString: @"add_cc"])
    {
      addCc = (id)item;
      RETAIN(addCc);
    }
  else if ([[item itemIdentifier] isEqualToString: @"add_bcc"])
    {
      addBcc = (id)item;
      RETAIN(addBcc);
    }
  else if ([[item itemIdentifier] isEqualToString: @"addresses"])
    {
      addresses = (id)item;
      RETAIN(addresses);  
    }
  else if ([[item itemIdentifier] isEqualToString: @"save_in_drafts"])
    {
      saveInDrafts = (id)item;
      RETAIN(saveInDrafts);  
    }
}


//
//
//
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
      itemForItemIdentifier: (NSString *) itemIdentifier
  willBeInsertedIntoToolbar: (BOOL) flag
{
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
  
  if ([itemIdentifier isEqualToString: @"send"])
    {
      [item setLabel: _(@"Send")];
      [item setPaletteLabel: _(@"Send Message")];
      [item setImage: [NSImage imageNamed: @"send_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(sendMessage:)];
    }
  else if ([itemIdentifier isEqualToString: @"insert"])
    {
      [item setLabel: _(@"Attach")];
      [item setPaletteLabel: _(@"Insert Attachment")];
      [item setImage: [NSImage imageNamed: @"attach_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(insertFile:)];
    }
  else if ([itemIdentifier isEqualToString: @"add_cc"])
    {
      [item setLabel: _(@"Add Cc")];
      [item setPaletteLabel: _(@"Add Cc Field")];
      [item setImage: [NSImage imageNamed: @"add_cc_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(showCc:)];
    }
  else if ([itemIdentifier isEqualToString: @"add_bcc"])
    {
      [item setLabel: _(@"Add Bcc")];
      [item setPaletteLabel: _(@"Add Bcc Field")];
      [item setImage: [NSImage imageNamed: @"add_bcc_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(showBcc:)];
    }
  else if ([itemIdentifier isEqualToString: @"addresses"])
    {
      [item setLabel: _(@"Addresses")];
      [item setPaletteLabel: @"Show Address Book"];
      [item setImage: [NSImage imageNamed: @"addresses_32.tiff"]];
      [item setTarget: [NSApp delegate]];
      [item setAction: @selector(showAddressBook:)];
    }
  else if ([itemIdentifier isEqualToString: @"save_in_drafts"])
    {
      [item setLabel: _(@"Save in Drafts")];
      [item setPaletteLabel: @"Add Save in Drafts"];
      [item setImage: [NSImage imageNamed: @"drafts_32.tiff"]];
      [item setTarget: [NSApp delegate]];
      [item setAction: @selector(saveInDrafts:)];
    }
  else
    {
      // We return the toolbar item from a bundle...
      RELEASE(item);
    }

  return AUTORELEASE(item);
}


//
//
//
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar
{
  return nil;//allowedToolbarItemIdentifiers;
}


//
//
//
- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar
{
  return [NSArray arrayWithObjects: @"send",
		  @"insert",
                  @"add_cc",
                  @"add_bcc",
		  @"addresses",
		  @"save_in_drafts",
		  nil];
}


//
// NSToolbarItemValidation protocol
//
- (BOOL) validateToolbarItem:(NSToolbarItem *) theItem
{
  return [theItem isEnabled];
}
@end

