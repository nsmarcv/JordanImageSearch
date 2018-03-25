//
//  ImageCollectionViewCell.m
//  JordanImageSearch
//
//  Created by Jordan Lepretre on 24/03/2018.
//  Copyright © 2018 JDN. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import <SDWebImage/UIView+WebCache.h>

@implementation ImageCollectionViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imgView.image = nil;
    [self.imgView sd_cancelCurrentImageLoad];
    
    [self.selectedImageView setHidden:YES];
    [self.imageLoadingIndicator setHidden:NO];
}

@end
