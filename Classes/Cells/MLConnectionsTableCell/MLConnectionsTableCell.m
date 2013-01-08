//
//  MLConnectionsTableCell.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 12/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLConnectionsTableCell.h"

@interface MLConnectionsTableCell ()

@end

@implementation MLConnectionsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MLConnectionsTableCell"
                                                          owner:self
                                                        options:nil];
        self = [nibArray objectAtIndex:0];
        self.profileImage.useLoadIndicator = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if ([self isSelected]) {
        [self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    } else {
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
}

@end
