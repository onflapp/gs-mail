#
#  GNUMail Makefile for GNUstep
#
#  Copyright (C) 2001-2006
#
#  Author: Ludovic Marcotte <ludovic@Sophos.ca>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = Sending
BUNDLE_EXTENSION = .prefs

BUNDLE_INSTALL_DIR = $(GNUSTEP_APPLICATION_SUPPORT)/Mail

Sending_RESOURCE_FILES = MailIcon_send.tiff

Sending_OBJC_FILES = \
	SendingView.m \
	SendingViewController.m

Sending_HEADERS = \
	SendingView.h \
	SendingViewController.h

Sending_PRINCIPAL_CLASS = \
	SendingViewController

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../../Headers

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
