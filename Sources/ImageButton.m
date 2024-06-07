#import "ImageButton.h"

@implementation ImageButton

static NSMutableParagraphStyle* label_style;

- (id) initWithFrame:(NSRect) r
{
  self = [super initWithFrame:r];
  return self;
}

- (void) drawRect:(NSRect) r 
{
  [super drawRect:r];

  if (!label_style) {
    label_style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    label_style.alignment = NSTextAlignmentCenter;
  }
  NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys: 
                                          [NSFont labelFontOfSize:9], NSFontAttributeName,
                                          label_style, NSParagraphStyleAttributeName, nil];

  NSRect f = NSMakeRect(0, r.size.height - 15, r.size.width, 13);
  [[super title] drawInRect:f withAttributes:attr];
}

@end
