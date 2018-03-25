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

@property (strong, nonatomic) NSMutableArray* imagesList;
@property (strong, nonatomic) NSMutableArray* selectedImagesList;
@property int totalHits;
@property (strong, nonatomic) NSString *currentSearchText;

@property (strong, nonatomic) IBOutlet UILabel *backgroundLabel;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIButton *pixabayLogo;

@property (strong, nonatomic) IBOutlet UIButton *showImagesButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *showImagesBottomConstraint;

@property BOOL isLoadingImages;

@end

@implementation ImagesSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imagesList = [[NSMutableArray alloc] init];
    _selectedImagesList = [[NSMutableArray alloc] init];
    _totalHits = 0;
    _isLoadingImages = NO;
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
    
    //If there is more images to see, show 1 cell to display more_icon
    if([_imagesList count] < _totalHits){
        return _imagesList.count + 1;
    }
    
    return _imagesList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    if(indexPath.row < [_imagesList count]){
        NSDictionary *imgDict = [_imagesList objectAtIndex:indexPath.row];
        
        //Show green filter if image is selected
        if([_selectedImagesList containsObject:imgDict]){
            [cell.selectedImageView setHidden:NO];
        }
        
        
        //Load image
        NSURL *imgUrl = [NSURL URLWithString:[imgDict objectForKey:@"largeImageURL"]];
        if(imgUrl){
            
            [cell.imgView sd_setImageWithURL:imgUrl completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                [cell.imageLoadingIndicator setHidden:YES];
                //TODO SHOW PLACEHOLDER IF ERROR 'X'
            }];
        }
    }
    //Last cell used to load more images
    else{
        cell.imgView.image = [UIImage imageNamed:@"more_icon"];
        [cell.imageLoadingIndicator setHidden:YES];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row < [_imagesList count]){
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
    else{
        int page = (int) (_imagesList.count/20) + 1;
        [self loadImagesWithSearch:_currentSearchText atPage:page];
    }
}

#pragma mark SearchBar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _currentSearchText = searchBar.text;
    
    //Reset pictures and selected pictures + hide animate button + scroll to top
    [_imagesList removeAllObjects];
    [_selectedImagesList removeAllObjects];
    [self updateShowImageBottomConstraint];
    [self.imagesCollectionView setContentOffset:CGPointZero animated:YES];
    
    if(_currentSearchText.length > 0){
        [self loadImagesWithSearch:_currentSearchText atPage:1];
    } else{
        _totalHits = 0;
        [_pixabayLogo setHidden:YES];
        _backgroundLabel.text = @"Quelles images voulez-vous afficher ?";
        [self.imagesCollectionView reloadData];
    }
}

#pragma mark - API MANAGEMENT
- (void) loadImagesWithSearch:(NSString *)searchParam atPage:(int)page{
    if(!_isLoadingImages){
        _isLoadingImages = YES;
    
        [[ApiManager sharedInstance] getImagesWithSearch:searchParam andPage:page andCompletionBlock:^(NSError *error, NSDictionary *json) {
            if(error) {
                NSLog(@"Error: %@", error);
                
                //Show error alert
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oups :(" message:@"Une erreur s'est produite ! Veuillez réessayez plus tard."preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            } else{
    //            NSLog(@"%@", json);
                
                _totalHits = [[json objectForKey:@"totalHits"] intValue];
                [_imagesList addObjectsFromArray:[json objectForKey:@"hits"]];
                
                if([_imagesList count] < 1){
                    _backgroundLabel.text = [NSString stringWithFormat:@"Aucune image trouvée pour la recherche : \n%@", searchParam];
                    [_pixabayLogo setHidden:YES];
                }
                else{
                    [_pixabayLogo setHidden:NO];
                }
                
                [self.imagesCollectionView reloadData];
            }
            
            _isLoadingImages = NO;
        }];
    }
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
