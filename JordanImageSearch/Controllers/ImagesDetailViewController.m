//
//  ImagesDetailViewController.m
//  JordanImageSearch
//
//  Created by Jordan Lepretre on 24/03/2018.
//  Copyright © 2018 JDN. All rights reserved.
//

#import "ImagesDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "UIColor+Utilities.h"

@interface ImagesDetailViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIView *pageControlBackground;

@property (strong, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (strong, nonatomic) IBOutlet UILabel *tagsLabel;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) IBOutlet UILabel *favLabel;

@property (strong, nonatomic) IBOutlet UIButton *fallButton;
@property (strong, nonatomic) IBOutlet UILabel *hireMeLabel;


@end

@implementation ImagesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initImagesScrollView];
}


- (void) initImagesScrollView {
    //Remove all subviews
    [[_imagesScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if([_imagesList count] > 0){
        CGFloat screenWidth = ([[UIScreen mainScreen] bounds].size.width);
        
        _pageControl.numberOfPages = [_imagesList count];
        
        //Create images scroll view
        for(int i = 0; i < [_imagesList count]; i++)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, screenWidth)];
            imageView.contentMode = UIViewContentModeScaleToFill;
            [_imagesScrollView addSubview:imageView];
            
            [imageView sd_setShowActivityIndicatorView:YES];
            [imageView sd_setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            NSDictionary *imageDict = [_imagesList objectAtIndex:i];
            NSURL *imageUrl = [NSURL URLWithString:[imageDict objectForKey:@"largeImageURL"]];
            if(imageUrl){
                [imageView sd_setImageWithURL:imageUrl]; //Image is already cached from previous screen
            }
        }
        
        _imagesScrollView.contentSize = CGSizeMake(screenWidth * [_imagesList count], screenWidth);
        
        [self updateDetailLabels];
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float width = scrollView.frame.size.width;
    float xPos = scrollView.contentOffset.x+10;
    
    //Calculate the page we are on based on x coordinate position and width of scroll view
    _pageControl.currentPage = (int)xPos/width;
    
    [self updateDetailLabels];
}

- (void) updateDetailLabels{
    NSDictionary *currentImg = [_imagesList objectAtIndex:_pageControl.currentPage];
    _tagsLabel.text = [currentImg objectForKey:@"tags"];
    _userLabel.text = [currentImg objectForKey:@"user"];
    _likesLabel.text = [[currentImg objectForKey:@"likes"] stringValue];
    _favLabel.text = [[currentImg objectForKey:@"favorites"] stringValue];
}

//Fall Animation
- (IBAction)fallButton:(id)sender {
    if([_fallButton.titleLabel.text isEqualToString:@"DO NOT PRESS"]){
        [_pageControl setHidden:YES];
        [_pageControlBackground setHidden:YES];
        [_detailScrollView setHidden:YES];
        [_hireMeLabel setHidden:NO];
        
        [_fallButton setEnabled:NO];
        
        CGFloat screenWidth = ([[UIScreen mainScreen] bounds].size.width);
        CGFloat screenHeight = ([[UIScreen mainScreen] bounds].size.height);
        
        CGRect newFrame = CGRectMake(_imagesScrollView.contentOffset.x+screenWidth/2,
                                     screenHeight,
                                     screenWidth/6,
                                     screenWidth/6);
        
        for(UIView *view in [_imagesScrollView subviews]){
            if([view isKindOfClass:[UIImageView class]]){
                
                [UIView animateWithDuration:0.50 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    //If view is on the left (from visible view), rotate right
                    if(view.frame.origin.x < _imagesScrollView.contentOffset.x){
                        [view setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                    }
                    //Else if view is on the right (from visible view), rotate left
                    else if(view.frame.origin.x > _imagesScrollView.contentOffset.x){
                        [view setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
                    }
                    //Else if view is in center, no rotation but send view to back
                    else{
                        [_imagesScrollView sendSubviewToBack:view];
                    }
                    
                    //Change frame to move it down
                    view.frame = newFrame;
                    
                } completion:^(BOOL finished) {
                    [_fallButton setEnabled:YES];
                    [_fallButton setTitle:@"REMETTRE" forState:UIControlStateNormal];
                    _fallButton.backgroundColor = [UIColor colorFromHexString:@"#68D89B"];
                }];
            }
        }
    }
    else{
        [_pageControl setHidden:NO];
        [_pageControlBackground setHidden:NO];
        [_detailScrollView setHidden:NO];
        [_hireMeLabel setHidden:YES];
        
        [_fallButton setTitle:@"DO NOT PRESS" forState:UIControlStateNormal];
        _fallButton.backgroundColor = [UIColor colorFromHexString:@"#FF7675"];
        
        [self initImagesScrollView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
