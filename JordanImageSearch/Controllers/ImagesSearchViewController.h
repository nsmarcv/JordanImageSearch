//
//  ImagesSearchViewController.h
//  JordanImageSearch
//
//  Created by Jordan Lepretre on 24/03/2018.
//  Copyright © 2018 JDN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagesSearchViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *imagesCollectionView;


@end
