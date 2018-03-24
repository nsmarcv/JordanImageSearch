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

@interface ImagesDetailViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation ImagesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float width = scrollView.frame.size.width;
    float xPos = scrollView.contentOffset.x+10;
    
    //Calculate the page we are on based on x coordinate position and width of scroll view
    _pageControl.currentPage = (int)xPos/width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
