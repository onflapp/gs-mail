#
#  GNUMail Makefile for GNUstep
#
#  Copyright (C) 2001-2006 Ludovic Marcotte
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

ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECTS = \
	Framework/GNUMail \
	Bundles/Account \
	Bundles/Advanced \
	Bundles/Colors \
	Bundles/Compose \
	Bundles/Filtering \
	Bundles/Fonts \
	Bundles/Import \
	Bundles/MIME \
	Bundles/Receiving \
	Bundles/Sending \
	Bundles/Viewing \
	Bundles/PGP \
	Bundles/Emoticon \

VERSION = 1.3.0
PACKAGE_NAME = Mail
APP_NAME = Mail
Mail_OBJC_FILES = GNUMail_main.m 
Mail_RESOURCE_FILES = \
	Resources/*.lproj \
	Resources/Icons/*.tiff \
	Resources/Goodies/Welcome \
	ScriptingInfo.plist

Mail_LANGUAGES = \
	Resources/English

Mail_LIB_DIRS = -L../$(GNUSTEP_LIBRARIES_ROOT) -LFramework/GNUMail/GNUMail.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR) -LFramework/GNUMail/GNUMail.framework
Mail_GUI_LIBS = -lGNUMail -lPantomime -lAddresses -lAddressView
Mail_LOCALIZED_RESOURCE_FILES = Localizable.strings

ADDITIONAL_INCLUDE_DIRS += -I./Framework/GNUMail
ADDITIONAL_OBJCFLAGS += -Wall -Wno-import -I/usr/kerberos/include -I/usr/local/ssl/include

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
