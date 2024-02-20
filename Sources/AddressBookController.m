/*
**  AddressBookController.m
**
**  Copyright (c) 2003-2006 Ludovic Marcotte
**  Copyright (C) 2018-2020 Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**          Riccardo Mottola <rm@gnu.org>
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "AddressBookController.h"

#import "AddressTaker.h"

#import <AddressBook/AddressBook.h>

#import "AddressBookPanel.h"
#import "GNUMail.h"
#import "Constants.h"
#import "Utilities.h"

#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/NSString+Extensions.h>

#define AB_SEARCH_ELEMENT(class, property, prefix) \
  [class searchElementForProperty: property \
	    label: nil \
	    key: nil \
	    value: prefix \
	    comparison: kABPrefixMatchCaseInsensitive]

static AddressBookController *singleInstance = nil;

//
//
//
@implementation NSArray (GNUMailABExtensions)
- (BOOL) containsRecord: (ABRecord *) record
{
  NSUInteger i;
  
  i = [self count];
  
  while( i-- )
    {
      if ( [[[self objectAtIndex: i] uniqueId] isEqualToString: [record uniqueId]] )
	{
	  return YES;
	}
    }

  return NO;
}
@end


//
//
//
@implementation ABPerson (GNUMailABExtensions)
- (NSArray *) formattedValuesForPrefix: (NSString *) thePrefix
{
  NSMutableArray *arr; ABMultiValue *emails;
  NSString *firstName, *lastName;
  NSUInteger i;

  thePrefix = [thePrefix lowercaseString]; // only check to-lower

  emails = [self valueForProperty: kABEmailProperty];
  if(![emails count])
    return [NSArray array];
  
  firstName = [self valueForProperty: kABFirstNameProperty];
  lastName = [self valueForProperty: kABLastNameProperty];

  arr = [NSMutableArray array];
  if (firstName && [[firstName lowercaseString] hasPrefix: thePrefix])
    {
      for (i = 0; i < [emails count]; i++)
	{
	  if (lastName)
	    {
	      [arr addObject: [NSString stringWithFormat: @"%@ %@ <%@>",
					firstName, lastName, [emails valueAtIndex: i]]];
	    }
	  else
	    {
	      [arr addObject: [NSString stringWithFormat: @"%@ <%@>",
					firstName, [emails valueAtIndex: i]]];
	    }
	}
      
      return [NSArray arrayWithArray: arr];
    }
  
  if (lastName && [[lastName lowercaseString] hasPrefix: thePrefix])
    {
      for (i = 0; i < [emails count]; i++)
	{
	  if (firstName)
	    {
	      [arr addObject: [NSString stringWithFormat: @"%@, %@ <%@>",
					lastName, firstName, [emails valueAtIndex: i]]];
	    }
	  else
	    {
	      [arr addObject: [NSString stringWithFormat: @"%@ <%@>",
					lastName, [emails valueAtIndex: i]]];
	    }
	}

      return [NSArray arrayWithArray: arr];
    }
  
  for (i = 0; i < [emails count]; i++)
    {
      if ([[[emails valueAtIndex: i] lowercaseString] hasPrefix: thePrefix])
	{
	  [arr addObject: [emails valueAtIndex: i]];
	}
    }

  return [NSArray arrayWithArray: arr];
}

- (NSString *) formattedValue
{
  NSString *firstName, *lastName;

  firstName = [self valueForProperty: kABFirstNameProperty];
  lastName = [self valueForProperty: kABLastNameProperty];

  if ( firstName && lastName )
    {
      return [NSString stringWithFormat: @"%@ %@ <%@>", firstName, lastName,
		       [(ABMultiValue *)[self valueForProperty: kABEmailProperty] valueAtIndex: 0]];
    }
  else if ( firstName || lastName )
    {
      return [NSString stringWithFormat: @"%@ <%@>", (firstName == nil ? lastName : firstName),
		       [(ABMultiValue *)[self valueForProperty: kABEmailProperty] valueAtIndex: 0]];
    }
  
  return [(ABMultiValue *)[self valueForProperty: kABEmailProperty] valueAtIndex: 0];
}

- (NSString *) fullName
{
  NSString *firstName, *lastName;
      
  firstName = [self valueForProperty: kABFirstNameProperty];
  lastName = [self valueForProperty: kABLastNameProperty];
      
  if ( firstName && lastName )
    {
      return [NSString stringWithFormat: @"%@ %@", firstName, lastName];
    }
  else if ( firstName && !lastName )
    {
      return firstName;
    }
  else if ( !firstName && lastName )
    {
      return lastName;
    }

 return _(@"< unknown >");
}

@end


//
// We use the window ivar to represent the Address Book window, but we
// expect only a single instance of the controller app-wide.
//
@implementation AddressBookController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
    NSEnumerator *e;
    ABPerson *person;

  AddressBookPanel *thePanel;
  
  thePanel = [[AddressBookPanel alloc] initWithContentRect: NSMakeRect(200,200,520,325)
				       styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask
				       backing: NSBackingStoreBuffered
				       defer: YES];
  
  self = [super initWithWindow: thePanel];

  [thePanel layoutPanel];
  [thePanel setDelegate: self];
  [thePanel setMinSize: [thePanel frame].size];

  // We link our outlets
  singlePropertyView = thePanel->singlePropertyView;
  preferredEmailLabelPopUp = thePanel->prefLabelPopup;
  RELEASE(thePanel);

  // We set some initial parameters
  [[self window] setTitle: _(@"Address Book")];

  // We finally set our autosave window frame name and restore the one from the user's defaults.
  [[self window] setFrameAutosaveName: @"AddressBookPanel"];
  [[self window] setFrameUsingName: @"AddressBookPanel"];
  
  _table = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 64);
  
  // we initialize the available email label types
  e = [[[ABAddressBook sharedAddressBook] people] objectEnumerator];
  while((person = [e nextObject]))
    {
      ABMultiValue *emails;
      unsigned i;
      
      emails = [person valueForProperty: kABEmailProperty];
      for(i=0; i<[emails count]; i++)
	{
	  NSString *label = [emails labelAtIndex: i];
	  if([preferredEmailLabelPopUp indexOfItemWithRepresentedObject: label] == -1)
	    {
	      [preferredEmailLabelPopUp addItemWithTitle: ABLocalizedPropertyOrLabel(label)];
	      [[preferredEmailLabelPopUp lastItem] setRepresentedObject: label];
	    }
	}
    }

  return self;
}


//
//
//
- (void) dealloc
{
  NSFreeMapTable(_table);

  [super dealloc];
}


//
//
//
- (void) addSenderToAddressBook: (CWMessage *) theMessage
{
  NSString *personal, *email, *first, *last;
  ABMutableMultiValue *aMutableMultiValue;
  NSEnumerator *theEnumerator;
  ABPerson *aPerson;
  ABPerson *other;
  NSUInteger v;
  
  personal = [[theMessage from] personal];
  email = [[theMessage from] address];

  if (!email && !personal)
    {
      NSBeep();
      return;
    }
  
  aPerson = [[[ABPerson alloc] init] autorelease];
  
  if (email)
    {
      aMutableMultiValue = AUTORELEASE([[aPerson valueForProperty: kABEmailProperty] mutableCopy]);
      [aMutableMultiValue addValue: email  withLabel: kABEmailWorkLabel];
      [aPerson setValue: aMutableMultiValue  forProperty: kABEmailProperty];
    }
  
  if (personal)
    {
      if ([personal rangeOfString: @","].location == NSNotFound)
	{
	  NSArray *theComponents;
	  
	  theComponents = [personal componentsSeparatedByString: @" "];
	  
	  if ([theComponents count] > 1)
	    {
	      first = [[theComponents subarrayWithRange: NSMakeRange(0, [theComponents count]-1)]
			componentsJoinedByString: @" "];
	      last = [theComponents objectAtIndex: [theComponents count]-1];
	      [aPerson setValue: first forProperty: kABFirstNameProperty];
	      [aPerson setValue: last forProperty: kABLastNameProperty];
	    }
	  else
	    {
	      [aPerson setValue: personal forProperty: kABLastNameProperty];
	    }
	}
      else
	{
	  NSArray *theComponents;
	  
	  theComponents = [personal componentsSeparatedByString: @","];
	  
	  if ([theComponents count] > 1)
	    {
	      last = [theComponents objectAtIndex: 0];
	      first = [theComponents objectAtIndex: 1];
	      [aPerson setValue: first forProperty: kABFirstNameProperty];
	      [aPerson setValue: last forProperty: kABLastNameProperty];
	    }
	  else
	    {
	      [aPerson setValue: personal forProperty: kABLastNameProperty];
	    }
       }
    }
  
  // We verify if the person is already in the address book
  theEnumerator = [[[ABAddressBook sharedAddressBook] people] objectEnumerator];
  
  while ((other = [theEnumerator nextObject]))
    {
      if ([[other fullName] isEqualToString: [aPerson fullName]])
	{
	  v = NSRunAlertPanel(_(@"Person exists!"),
			      _(@"There is already a person named '%@'\nin the address book."),
			      _(@"Don't add"),               // Default
			      _(@"Add anyway"),              // Alternate
			      _(@"Add address to existing"), // Other
			      [aPerson fullName]);
	  switch (v)
	    {
	      // add anyway, i.e. continue
	    case NSAlertAlternateReturn: 
	      break;
	      // add email to existing
	    case NSAlertOtherReturn: 
	      if (!email)
		{
		  NSRunAlertPanel(_(@"No address!"),
				  _(@"The sender of this messages has no email address!"),
				  _(@"OK"), 
				  nil, 
				  nil, 
				  nil);
		  return;
		}
	      
	      aMutableMultiValue = AUTORELEASE([[other valueForProperty: kABEmailProperty] mutableCopy]);
	      [aMutableMultiValue addValue: email withLabel: kABEmailWorkLabel];
	      [other setValue: aMutableMultiValue forProperty: kABEmailProperty];
	      [[ABAddressBook sharedAddressBook] save];
	      return;
	    case 1:
	    default:
	      return;
	    }
	}
    }
  
  if (![[ABAddressBook sharedAddressBook] addRecord: aPerson])
    {
      NSRunAlertPanel(_(@"The person could not be added "
			@"to the address book."), _(@"OK"), nil, nil, nil);
    }
  
  [[ABAddressBook sharedAddressBook] save];
}


//
//
//
- (void) freeCache
{
  NSResetMapTable(_table);
}

// 
// Action methods
//
- (void) doubleClickOnName: (NSString *) theName
                     value: (NSString *) theValue
                    inView: (id) theView
{
  int modifier;

  modifier = [[[self window] currentEvent] modifierFlags];

  if ( (modifier&NSControlKeyMask) && !(modifier&NSShiftKeyMask) )
    {
      return [self ccClicked: nil];
    }
  else if ( !(modifier&NSControlKeyMask) && (modifier&NSShiftKeyMask) )
    {
      return [self bccClicked: nil];
    }
  else
    {
      return [self toClicked: nil];
    }
}


//
//
//
- (IBAction) toClicked: (id) sender
{
  [self _updateFieldUsingSelector: @selector(takeToAddress:)];
}


//
//
//
- (IBAction) ccClicked: (id) sender
{
  [self _updateFieldUsingSelector: @selector(takeCcAddress:)];
}


//
//
//
- (IBAction) bccClicked: (id) sender
{
  [self _updateFieldUsingSelector: @selector(takeBccAddress:)];
}


//
//
//
- (IBAction) openClicked: (id) sender
{
  [[NSWorkspace sharedWorkspace] launchApplication: @"AddressManager"];
}

- (IBAction) emailLabelChanged: (id) sender
{
}

//
// Other methods
//
- (NSArray *) addressesWithPrefix: (NSString *) thePrefix
{
  ABSearchElement *firstNameElement, *lastNameElement, *emailElement, *groupNameElement;
  NSEnumerator *e; ABRecord *r;
  NSMutableArray *aMutableArray;
   
  if ( !thePrefix || [[thePrefix stringByTrimmingWhiteSpaces] length] == 0 )
    {
      return [NSArray array];
    }
  
  //
  // Create our search elements; we search on first name, last name, and E-Mail address.
  // Do search on last name last so that the order of the list is sensible.
  //
  firstNameElement = AB_SEARCH_ELEMENT(ABPerson, kABFirstNameProperty, thePrefix);
  lastNameElement = AB_SEARCH_ELEMENT(ABPerson, kABLastNameProperty, thePrefix);
  emailElement = AB_SEARCH_ELEMENT(ABPerson, kABEmailProperty, thePrefix);

  // We also search on groups    
  groupNameElement = AB_SEARCH_ELEMENT(ABGroup, kABGroupNameProperty, thePrefix);
  
  aMutableArray = [[NSMutableArray alloc] init];
      
  [aMutableArray addObjectsFromArray: [[ABAddressBook sharedAddressBook] recordsMatchingSearchElement: firstNameElement]];
  e = [[[ABAddressBook sharedAddressBook] recordsMatchingSearchElement: lastNameElement] objectEnumerator];
  while((r = [e nextObject]))
    if(![aMutableArray containsRecord: r])
      [aMutableArray addObject: r];
  e = [[[ABAddressBook sharedAddressBook] recordsMatchingSearchElement: emailElement] objectEnumerator];
  while((r = [e nextObject]))
    if(![aMutableArray containsRecord: r])
      [aMutableArray addObject: r];
  e = [[[ABAddressBook sharedAddressBook] recordsMatchingSearchElement: groupNameElement] objectEnumerator];
  while((r = [e nextObject]))
    if(![aMutableArray containsRecord: r])
      [aMutableArray addObject: r];
  
  return AUTORELEASE(aMutableArray);
}


//
//
//
- (NSArray *) addressesWithSubstring: (NSString *) theSubstring
		       inGroupWithId: (NSString *) theGroupId
{
  if (!theSubstring || ![theSubstring length])
    {
      return [NSArray array];
    }
  else
    {
      NSMutableArray *aMutableArray;
      NSArray *thePeople;
      ABPerson *aPerson;
      ABGroup *aGroup;
      
      NSUInteger i, j, count;

      aMutableArray = NSMapGet(_table, theSubstring);

      if (aMutableArray && !theGroupId) return aMutableArray;
      
      if (theGroupId)
	{
	  aGroup = (id)[[ABAddressBook sharedAddressBook] recordForUniqueId: theGroupId];
	
	  if (!aGroup || ![aGroup isKindOfClass: [ABGroup class]])
	    {
	      return [NSArray array];
	    }
	  
	  thePeople = [aGroup members];
	}
      else
	{
	  thePeople = [[ABAddressBook sharedAddressBook] people];
	}

      aMutableArray = [[NSMutableArray alloc] init];
      count = [thePeople count];

      for (i = 0; i < count; i++)
	{
	  aPerson = [thePeople objectAtIndex: i];
	  
	  // We first look for the name
	  if ([theSubstring rangeOfString: [aPerson fullName]  options: NSCaseInsensitiveSearch].length)
	    {
	      for (j = 0; j < [[aPerson valueForProperty: kABEmailProperty] count]; j++)
		{
		  [aMutableArray addObject: [(ABMultiValue *)[aPerson valueForProperty: kABEmailProperty] valueAtIndex: j]];
		}
	    }
	  // We look at the addresses directly
	  else
	    {
	      for (j = 0; j < [[aPerson valueForProperty: kABEmailProperty] count]; j++)
		{
		  if ([theSubstring rangeOfString: [(ABMultiValue *)[aPerson valueForProperty: kABEmailProperty] valueAtIndex: j]
				    options: NSCaseInsensitiveSearch].length)
		    {
		      [aMutableArray addObject: [(ABMultiValue *)[aPerson valueForProperty: kABEmailProperty] valueAtIndex: j]];
		    }
		}
	    }
	}
      
      if (!theGroupId) NSMapInsert(_table, theSubstring, aMutableArray);
      
      return AUTORELEASE(aMutableArray);
    }
}


- (NSArray *) addressesWithSubstring: (NSString *) theSubstring
{
  return [self addressesWithSubstring: theSubstring inGroupWithId: nil];
}
  
//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[AddressBookController alloc] initWithWindowNibName: @"AddressBookPanel"];
    }
  
  return singleInstance;
}

@end


//
// AddressBookController private category
//
@implementation AddressBookController (Private)

- (void) _updateFieldUsingSelector: (SEL) theSelector
{
  id theValues;

  if (![GNUMail lastAddressTakerWindowOnTop])
    {
      [[NSApp delegate] composeMessage: self];
    }

  theValues = [singlePropertyView selectedNamesAndValues];
  
  if ([theValues count] > 0)
    { 
      NSUInteger i;
           
      for (i = 0; i < [theValues count]; i++)
	{
	  [(id<NSObject>)[GNUMail lastAddressTakerWindowOnTop] performSelector: theSelector
			 withObject: [theValues objectAtIndex: i]];
	}
    }
  else
    {
      NSBeep();
    }
}

@end
