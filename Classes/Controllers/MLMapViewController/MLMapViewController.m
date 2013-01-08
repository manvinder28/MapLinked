//
//  MLMapViewController.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 12/10/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLMapViewController.h"
#import "MLUser.h"
#import "MLCompany.h"
#import "MLMapAnnotation.h"
#import "MLMapAnnotationView.h"

@interface MLMapViewController ()

@property(nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation MLMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"Around_toolbar_icon.png"];
        self.mapView.showsUserLocation = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addNewCompanyAnnotation:)
                                                     name:kCompanyAnnotationDidAddedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addNewConnectionAnnotation:)
                                                     name:kConnectionAnnotationDidAddedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(logoutDidFinish:)
                                                     name:kLogOutNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[MLLinkedInManager sharedInstance] findAllConnectionsCoordinates];
    [[MLLinkedInManager sharedInstance] findAllCompaniesCoordinates];
}

- (void)logoutDidFinish:(NSNotification *)notification {
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)addNewCompanyAnnotation:(NSNotification *)notification {
    MLMapAnnotation *annotation = [[notification userInfo] objectForKey:@"annotation"];
    NSLog(@"Map: new company annotation %@", annotation);
    [self.mapView addAnnotation:annotation];
}

- (void)addNewConnectionAnnotation:(NSNotification *)notification {
    MLMapAnnotation *annotation = [[notification userInfo] objectForKey:@"annotation"];
    NSLog(@"Map: new connection annotation %@", annotation);
    [self.mapView addAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MLMapAnnotationView *annotationView = (MLMapAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    [annotationView removeFromSuperview];
    annotationView = nil;
    if(!annotationView) {
        annotationView = [[MLMapAnnotationView alloc] initWithAnnotation:annotation
                                                         reuseIdentifier:AnnotationIdentifier];
    }
//    MLMapAnnotation *mapAnnotation = annotation;
//
//    UIImage *annotationImage;
//    switch (mapAnnotation.mapAnnotationType) {
//        case MLMapAnnotationTypeCompany:
//            annotationImage = [UIImage imageNamed:[NSString stringWithFormat:@"home.png"]];
//            break;
//        case MLMapAnnotationTypeConnection:
//            annotationImage = [UIImage imageNamed:[NSString stringWithFormat:@"flag.png"]];
//            break;
//        case MLMapAnnotationTypeCurrentUser:
//            annotationImage = [UIImage imageNamed:[NSString stringWithFormat:@"flag.png"]];
//            break;
//        default:
//            break;
//    }
//    annotationView.canShowCallout = YES;
//    annotationView.image = annotationImage;
    return annotationView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
