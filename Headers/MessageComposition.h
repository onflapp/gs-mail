/*
**  MessageComposition.h
**
**  Copyright (c) 2001-2004 Ujwal S. Sathyam
**
**  Author: Ujwal S. Sathyam
**
**  Description: Header file for scriptable MessageComposition class.
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

#ifndef _GNUMail_H_MessageComposition
#define _GNUMail_H_MessageComposition

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class CWInternetAddress;
@class ToRecipient;
@class CcRecipient;
@class BccRecipient;
@class EditWindowController;

@interface MessageComposition : NSObject 
{
  // instance variables for attributes: 
  NSString *_author;
  NSTextStorage *_content;
  int _signaturePosition;
  BOOL _hasSignature;
  NSString *_subject;
  NSMutableArray *_attachments;
  NSString *_account;
  
  // instance variables for to-many relationships: 
  NSMutableArray *_recipients;
  
  @private
    EditWindowController *_editWindowController;
}

- (void) send;
- (void) show: (BOOL) flag;
- (void) addAttachment: (NSString *) aFileName;

//
// accessors for attributes:
// 
- (NSString *) author;
- (void) setAuthor: (NSString *)author;
- (NSTextStorage *) content;
- (void) setContent: (NSTextStorage *)content;
- (int) signaturePosition;
- (void) setSignaturePosition: (int) signaturePosition;
- (BOOL) hasSignature;
- (void) setHasSignature: (BOOL) hasSignature;
- (NSString *) subject;
- (void) setSubject: (NSString *) subject;
- (NSArray *) attachments;
- (void) setAttachments: (NSArray *) attachments;
- (NSString *) account;
- (void) setAccount: (NSString *) accountName;

//
// accessors for to-many relationships:
// 
- (NSArray *)recipients;
- (void) setRecipients: (NSArray *) recipients;
- (NSArray *)ccRecipients;
- (void) setCcRecipients: (NSArray *) ccRecipients;
- (NSArray *)bccRecipients;
- (void) setBccRecipients: (NSArray *) bccRecipients;
- (NSArray *)toRecipients;
- (void) setToRecipients: (NSArray *) toRecipients;

@end


//
//
//
@interface MessageComposition (KeyValueCoding)

- (void) insertInRecipients: (CWInternetAddress *) object;
- (void) insertInRecipients: (CWInternetAddress *) object  atIndex: (unsigned) index;
- (void) removeFromRecipientsAtIndex: (unsigned) index;
- (void) replaceInRecipients: (CWInternetAddress *) object  atIndex: (unsigned) index;
- (id) valueInRecipientsAtIndex: (unsigned) index;
- (void) insertInToRecipients: (ToRecipient *) object;
- (void) insertInToRecipients: (ToRecipient *) object  atIndex: (unsigned) index;
- (void) removeFromToRecipientsAtIndex: (unsigned) index;
- (void) replaceInToRecipients: (ToRecipient *) object  atIndex: (unsigned) index;
- (id) valueInToRecipientsAtIndex: (unsigned) index;
- (void) insertInCcRecipients: (CcRecipient *) object;
- (void) insertInCcRecipients: (CcRecipient *) object  atIndex: (unsigned) index;
- (void) removeFromCcRecipientsAtIndex: (unsigned) index;
- (void) replaceInCcRecipients: (CcRecipient *) object  atIndex: (unsigned) index;
- (id) valueInCcRecipientsAtIndex: (unsigned) index;
- (void) insertInBccRecipients: (BccRecipient *) object;
- (void) insertInBccRecipients: (BccRecipient *) object  atIndex: (unsigned) index;
- (void) removeFromBccRecipientsAtIndex: (unsigned) index;
- (void) replaceInBccRecipients: (BccRecipient *) object  atIndex: (unsigned) index;
- (id) valueInBccRecipientsAtIndex: (unsigned) index;

@end

@interface MessageComposition (Private)

- (void) _loadMessage;

@end

#endif // _GNUMail_H_MessageComposition
