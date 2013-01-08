//
//  MLConnectionsTableCell.h
//  MapLinked
//
//  Created by Alexey Naboychenko on 12/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MLConnectionsTableCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet AsyncImageView *profileImage;
@property(nonatomic, weak) IBOutlet UILabel *industryLabel;
@end
