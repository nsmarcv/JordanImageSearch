//
//  ImagesSearchViewController.m
//  JordanImageSearch
//
//  Created by Jordan Lepretre on 24/03/2018.
//  Copyright © 2018 JDN. All rights reserved.
//

#import "ImagesSearchViewController.h"
#import "ApiManager.h"

@interface ImagesSearchViewController ()

@end

@implementation ImagesSearchViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    //Test APIManager
    [[ApiManager sharedInstance] getImagesWithSearch:@"yellow flowers" andCompletionBlock:^(NSError *error, NSArray *json) {
        if(error){
            NSLog(@"Une erreur s'est produite !");
        } else{
            NSLog(@"%@", json);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    return cell;
}


@end
