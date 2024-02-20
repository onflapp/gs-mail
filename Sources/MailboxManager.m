/*
**  MailboxManager.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
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

#include "MailboxManager.h"

#include "GNUMail.h"
#include "Constants.h"
#include "LabelWidget.h"
#include "ExtendedOutlineView.h"


//
//
//
@implementation MailboxManager

- (void) dealloc
{
  [super dealloc];
}

//
//
//
- (void) awakeFromNib
{
  [outlineView setHeaderView: nil];
  [outlineView setIndentationPerLevel: 10];
  [outlineView setAutoresizesOutlineColumn: YES];
  [outlineView setIndentationMarkerFollowsCell: YES];
  [outlineView setAutoresizesAllColumnsToFit: YES];
  [outlineView sizeLastColumnToFit];
  [outlineView setIndentationPerLevel: 5];
}

@end
