//
//  ImagesSearchViewController.m
//  JordanImageSearch
//
//  Created by Jordan Lepretre on 24/03/2018.
//  Copyright © 2018 JDN. All rights reserved.
//

#import "ImagesSearchViewController.h"
#import "ApiManager.h"
#import "ImageCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SearchCollectionReusableView.h"

@interface ImagesSearchViewController ()

@property (strong, nonatomic) NSArray* imagesList;

@property (strong, nonatomic) IBOutlet UILabel *backgroundLabel;


@end

@implementation ImagesSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

-  (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader) {
        SearchCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionViewHeader" forIndexPath:indexPath];

        headerView.searchBar.delegate = self;
        
        return headerView;
    }
    
    return [[UICollectionReusableView alloc] init];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_imagesList.count > 0){
        [_backgroundLabel setHidden:YES];
    }
    else{
        [_backgroundLabel setHidden:NO];
    }
    
    return _imagesList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    NSDictionary *imgDict = [_imagesList objectAtIndex:indexPath.row];
    NSURL *imgUrl = [NSURL URLWithString:[imgDict objectForKey:@"largeImageURL"]];
    
    
    if(imgUrl){
        //Load image
        [[SDWebImageManager sharedManager] loadImageWithURL:imgUrl options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {

            //If success
            if(image){
                cell.imgView.image = image;
            }
            //If failed
            else{
                cell.imgView.image = nil;
            }
        }];
    }
    
    return cell;
}

#pragma mark SearchBar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if(searchBar.text.length > 0){
        [self loadImagesWithSearch:searchBar.text];
    } else{
        _imagesList = nil;
        [self.collectionView reloadData];
    }
}

#pragma mark - API MANAGEMENT
- (void) loadImagesWithSearch:(NSString *)searchParam{
    [[ApiManager sharedInstance] getImagesWithSearch:searchParam andCompletionBlock:^(NSError *error, NSDictionary *json) {
        if(error) {
            NSLog(@"Error: %@", error);
            
            //Show error alert
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oups :(" message:@"Une erreur s'est produite ! Veuillez réessayez plus tard."preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else{
            //            NSLog(@"%@", json);
            
            if(!_imagesList){
                _imagesList = [[NSArray alloc] init];
            }
            
            _imagesList = [json objectForKey:@"hits"];
            [self.collectionView reloadData];
        }
    }];
}


@end
