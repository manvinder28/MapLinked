//
//  MLMapAnnotationView.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 1/8/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MLMapAnnotationView.h"
#import "AsyncImageView.h"
#import "MLMapAnnotation.h"

@interface MLMapCustomAnnotationView()
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet AsyncImageView *imageView;
@end

@implementation MLMapCustomAnnotationView

@end

@interface MLMapAnnotationView ()
@property (nonatomic, strong) MLMapCustomAnnotationView *loadedView;
@end

@implementation MLMapAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        MLMapAnnotation *mapAnnotation = annotation;
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MLMapAnnotationView"
                                                          owner:self
                                                        options:nil];
        switch (mapAnnotation.mapAnnotationType) {
            case MLMapAnnotationTypeCompany:
                self.loadedView = [nibArray objectAtIndex:1];
                self.loadedView.imageView.defaultImage = [UIImage imageNamed:@"company.png"];
                break;
            default:
                self.loadedView = [nibArray objectAtIndex:0];
                self.loadedView.imageView.defaultImage = [UIImage imageNamed:@"connection.png"];
                break;
        }
        [self.loadedView.imageView loadImageFromURL:mapAnnotation.imageURL];
        self.loadedView.nameLabel.text = mapAnnotation.title;
        self.loadedView.descriptionLabel.text = mapAnnotation.subtitle;
        self.loadedView.center = self.center;
        self.centerOffset = CGPointMake(0, self.loadedView.frame.size.height / -2);
        [self addSubview:self.loadedView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
