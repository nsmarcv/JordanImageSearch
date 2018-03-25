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
#import "UIColor+Utilities.h"
#import "ImagesDetailViewController.h"

@interface ImagesSearchViewController ()

@property (strong, nonatomic) NSArray* imagesList;
@property (strong, nonatomic) NSMutableArray* selectedImagesList;

@property (strong, nonatomic) IBOutlet UILabel *backgroundLabel;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIButton *pixabayLogo;

@property (strong, nonatomic) IBOutlet UIButton *showImagesButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *showImagesBottomConstraint;


@end

@implementation ImagesSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedImagesList = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

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
    
    //Show green filter if image is selected
    if([_selectedImagesList containsObject:imgDict]){
        [cell.selectedImageView setHidden:NO];
    } else{
        [cell.selectedImageView setHidden:YES];
    }
    
    
    cell.imgView.image = nil;
    [cell.imageLoadingIndicator setHidden:NO];
    
    //Load image
    NSURL *imgUrl = [NSURL URLWithString:[imgDict objectForKey:@"largeImageURL"]];
    if(imgUrl){
        [[SDWebImageManager sharedManager] loadImageWithURL:imgUrl options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {

            //If success
            if(image){
                cell.imgView.image = image;
                [cell.imageLoadingIndicator setHidden:YES];
            }
        }];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *selectedImage = [_imagesList objectAtIndex:indexPath.row];
    
    //If image already selected, deselect it
    if([_selectedImagesList containsObject:selectedImage]){
        [_selectedImagesList removeObject:selectedImage];
    } else{
        [_selectedImagesList addObject:selectedImage];
    }
    
    //Update button title to show nb of selected images
    [_showImagesButton setTitle:[NSString stringWithFormat:@"Voir les %lu images", (unsigned long)[_selectedImagesList count]] forState:UIControlStateNormal];
    
    [self updateShowImageBottomConstraint];
    
    //Reload item to show green filter
    [self.imagesCollectionView reloadItemsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil]];
}

#pragma mark SearchBar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //Reset selected pictures + hide animate button
    [_selectedImagesList removeAllObjects];
    [self updateShowImageBottomConstraint];
    
    if(searchBar.text.length > 0){
        [self loadImagesWithSearch:searchBar.text];
    } else{
        _imagesList = nil;
        [_pixabayLogo setHidden:YES];
        _backgroundLabel.text = @"Quelles images voulez-vous afficher ?\n(Recherche en anglais)";
        [self.imagesCollectionView reloadData];
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
            
            if([_imagesList count] < 1){
                _backgroundLabel.text = [NSString stringWithFormat:@"Aucune image trouvée pour la recherche : \n%@", searchParam];
                [_pixabayLogo setHidden:YES];
            }
            else{
                [_pixabayLogo setHidden:NO];
            }
            
            [self.imagesCollectionView reloadData];
        }
    }];
}

#pragma mark - bottom button
- (void) updateShowImageBottomConstraint{
    //If 2 items selected or more
    if([_selectedImagesList count] >= 2){
        //If button is hidden
        if([_showImagesBottomConstraint constant] == -50){
            _showImagesBottomConstraint.constant = 0;
        }
    }
    else{
        if([_showImagesBottomConstraint constant] == 0){
            _showImagesBottomConstraint.constant = -50;
        }
    }
    
    //Animate button
    [UIView animateWithDuration:0.45 animations:^{
        [self.view layoutIfNeeded];
        [_showImagesButton setNeedsDisplay];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"showImages"]){
        ImagesDetailViewController *destVC = [segue destinationViewController];
        destVC.imagesList = _selectedImagesList;
    }
}

- (IBAction)openPixabay:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://pixabay.com/"] options:@{} completionHandler:^(BOOL success) { }];
}



@end
