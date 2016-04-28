//
//  ViewController.m
//  Tune Search
//
//  Created by Demond Childers on 4/25/16.
//  Copyright © 2016 Demond Childers. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "DetailViewController.h"
#import "TuneCollectionViewCell.h"

@interface ViewController ()

@property (nonatomic, strong) NSString                *hostname;
@property (nonatomic, strong) NSArray                 *tunesearchArray;
//@property (nonatomic, weak) IBOutlet UITableView    *tunesearchTable;
@property (nonatomic, weak) IBOutlet UITextField      *artistNameTextField;
@property (nonatomic, weak) IBOutlet UICollectionView *tuneCollectionView;





@end

@implementation ViewController


Reachability *hostReach;
Reachability *hostReach;
Reachability *internetReach;
Reachability *wifiReach;
bool internetAvailable;
bool serverAvailable;



#pragma mark- File System Methods

-(NSString *)getDocumentsDirectory {
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSLog(@"DocPath:%@",paths[0]);
    return paths [0];
}

-(BOOL)file:(NSString *)filename isInDicrectory:(NSString *)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [directory stringByAppendingPathComponent: filename];
    NSLog(@"FilePath: %@",filePath);
    return [fileManager fileExistsAtPath: filePath];
    
}


#pragma mark - Collection View Methods

//ENTER DATA INTO TABLE VIEW CELLS & INDEX PATH FOR ROWS

//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return _tunesearchArray.count;
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _tunesearchArray.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TuneCollectionViewCell *cell = (TuneCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *currentTune = _tunesearchArray[indexPath.row];
    cell.artistNameLabel.text = [currentTune objectForKey:@"artistName"];
    cell.tuneNameLabel.text = [currentTune objectForKey:@"trackName"];
    
        NSString *filename = [NSString stringWithFormat:@"%@.jpg",[currentTune objectForKey:@"trackId"]];
    
        if ([self file:filename isInDicrectory:NSTemporaryDirectory()]) {
            NSLog(@"Found %@",filename);
            cell.tuneImageView.image = [UIImage imageNamed:[NSTemporaryDirectory() stringByAppendingPathComponent:filename]];
        } else {
            cell.tuneImageView.image = nil;
            [self getImageFromServer:filename fromURL: [currentTune objectForKey:@"artworkUrl100"] atIndexPath:indexPath];
            NSLog(@"had to fetch %@",filename);
        }
    
    
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 4;
    
    
    return cell;
}

-(CGSize) collectionView: (UICollectionView *)UICollectionView layout:(UICollectionViewLayout *)UICollectionViewLayout sizeforItemAtIndexPath: (NSIndexPath *)indexpath {
    return CGSizeMake(141.0, 168.0);
    
}




//#pragma mark-  Table View Methods

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    NSDictionary *currentTune = _tunesearchArray[indexPath.row];
//    cell.textLabel.text = [currentTune objectForKey:@"artistName"];
//    cell.detailTextLabel.text = [currentTune objectForKey:@"trackName"];
//    NSString *filename = [NSString stringWithFormat:@"%@.jpg",[currentTune objectForKey:@"trackId"]];
//   
//    if ([self file:filename isInDicrectory:NSTemporaryDirectory()]) {
//        NSLog(@"Found %@",filename);
//        cell.imageView.image = [UIImage imageNamed:[NSTemporaryDirectory() stringByAppendingPathComponent:filename]];
//    } else {
//        cell.imageView.image = nil;
//        [self getImageFromServer:filename fromURL: [currentTune objectForKey:@"artworkUrl60"] atIndexPath:indexPath];
//        NSLog(@"had to fetch %@",filename);
//    }
//    
//    return cell;
//}


//if ([self file:currentTune.trackId isInDirectory:NSTemporaryDirectory()]) {
//    NSLog(@"Found %@",currentTune.trackId);
//    cell.albumArtImageView.image = [UIImage imageNamed:[NSTemporaryDirectory() stringByAppendingPathComponent:currentTune.trackId]];
//} else {
//    cell.albumArtImageView.image = nil;
//    [self getImageFromServer:currentTune.trackId fromURL: currentTune.albumArtFileName atIndexPath:indexPath];
//    NSLog(@"had to fetch %@", currentTune.trackId);
//}



#pragma mark - Interactivity Methods



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *destController = [segue destinationViewController];
    NSIndexPath *indexPath = [_tuneCollectionView indexPathsForSelectedItems][0];
    destController.currentTuneDict =[_tunesearchArray objectAtIndex:indexPath.row];
}


-(void)getImageFromServer:(NSString *)localFilename fromURL:(NSString *)fullFileName atIndexPath:(NSIndexPath *) indexPath {
        if (serverAvailable) {
            
        NSURL *fileURL = [NSURL URLWithString:fullFileName];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (([data length] > 0) && (error == nil)) {
                NSString *savedFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:localFilename];
                UIImage *imageTemp = [UIImage imageWithData:data];
                
                if (imageTemp !=nil) {
                    [data writeToFile:savedFilePath atomically:true];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tuneCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                        //withRowAnimation:
                         //UITableViewRowAnimationAutomatic];
                    });
                }
            }
        }] resume];
        
    } else {
        NSLog(@"Server Not Available");
        
    }
}

-(IBAction)getFilePressed:(id)sender {
    NSLog(@"grab from host ");
    
    if (serverAvailable) {
        NSLog(@"Server Avail");
        
        if (serverAvailable) {
            NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@",_artistNameTextField.text]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:fileURL];
            [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
            [request setTimeoutInterval:30.0];
            NSURLSession *session = [NSURLSession sharedSession];
            [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"Got Response");
                
                if (([data length] > 0) && (error == nil)) {
                    
//TEST TO RETURN HEX DATA
//                  NSLog(@"Got Data: %@", data);
//                  NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                  NSLog(@"Got String: %@",dataString);
                    NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    NSLog(@"Json: %@",json);
                    _tunesearchArray = [(NSDictionary *)json objectForKey:@"results"];
                    for (NSDictionary *tunesearchDict in _tunesearchArray) {
                        NSLog(@"Tune Search: %@",[tunesearchDict objectForKey:@"artistName"]);
                        
                        
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Refresh Data on Interface
                        [_tuneCollectionView reloadData];
                        
                    });
                }
            }] resume];
            
        
            //    } else {
            //        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Server Not Available" message:@"Hey, turn on your Internet. Or perhaps server is down. Call for help!" preferredStyle: UIAlertControllerStyleAlert];
            //        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:nil];
            //        [alert addAction:okAction];
            //        [self presentViewController:alert animated:true completion: nil];
            //
            //
            //
            //    }
            //}
        }
    
    }
}




#pragma mark  - Network Methods


//Is this REALLY, REALLY REACHIBILITY??

- (void)updateReachabilitStatus:(Reachability *)currentReach {
    NSParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currentReach currentReachabilityStatus];
    
    //HOST REACH
    
    if (currentReach == hostReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Server Not Avaiable");
                serverAvailable = false;
                break;
            case ReachableViaWWAN:
                NSLog(@"Server Reachable via WWAN");
            case ReachableViaWiFi:
                NSLog(@"Server Reachable via WiFi");
                serverAvailable = true;
            default:
                break;
        }
    }
    //INTERNET REACH
    
    if (currentReach == internetReach || currentReach == wifiReach) {
        
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Internet Not Available");
                internetAvailable = false;
                break;
            case ReachableViaWWAN:
                NSLog(@"Internet Available via WWAN");
                internetAvailable = true;
            case ReachableViaWiFi:
                NSLog(@"Internet Available via WifFi");
                internetAvailable = true;
            default:
                break;
        }
    }
}

-(void)reachabilityChanged:(NSNotification *)notification {
    Reachability *currentReach = [notification object];
    [self updateReachabilitStatus:currentReach];
}


#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostname = @"itunes.apple.com";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    
    hostReach = [Reachability reachabilityWithHostname:_hostname];
    [hostReach startNotifier];
    
    internetReach = [Reachability reachabilityWithHostname:_hostname];
    [internetReach startNotifier];
    
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end




