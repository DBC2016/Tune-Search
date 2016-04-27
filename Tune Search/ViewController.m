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

@interface ViewController ()

@property (nonatomic, strong) NSString           *hostname;
@property (nonatomic, strong) NSArray            *tunesearchArray;
@property (nonatomic, weak) IBOutlet UITableView *tunesearchTable;
@property (nonatomic, weak) IBOutlet UITextField *artistNameTextField;
@property (nonatomic, weak) IBOutlet UIImageView *tuneImageView;



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
    
    return [fileManager fileExistsAtPath: filePath];
    
}

//for (NSDictionary *resultsDict in tempArray) {
//    NSLog(@"songs: %@ track %@", [resultsDict objectForKey:@"artistName"],[resultsDict objectForKey:@"trackId"]);
//    Song *newsong = [[Song alloc] initWithArtistName:[resultsDict objectForKey:@"artistName"] andSongTitle:[resultsDict objectForKey:@"trackName"] andalbumTitle:[resultsDict objectForKey:@"collectionName"] andAlbumtArtFileName:[resultsDict objectForKey:@"artworkUrl60"] andtrackExplicit:[resultsDict objectForKey:@"trackExplicitness"] andtrackId:[NSString stringWithFormat:@"%@.jpg",[resultsDict objectForKey:@"trackId"]] anditemKind:[resultsDict objectForKey:@"kind"] andpreviewUrl:[resultsDict objectForKey:@"previewURL"] andpreviewName:[NSString stringWithFormat:@"%@.m4a",[resultsDict objectForKey:@"trackId"]] anddescriptString:[resultsDict objectForKey:@"longDescription"]];
//    [_resultsArray addObject:newsong];


#pragma mark - Table View Methods

//ENTER DATA INTO TABLE VIEW CELLS & INDEX PATH FOR ROWS

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tunesearchArray.count;
}



//NSString *uniqueImageName = [[NSProcessInfo processInfo] globallyUniqueString];
//NSString *uniqueImageNameWithExt = [uniqueImageName stringByAppendingString:@".jpg"];


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *currentTune = _tunesearchArray[indexPath.row];
    cell.textLabel.text = [currentTune objectForKey:@"artistName"];
    cell.detailTextLabel.text = [currentTune objectForKey:@"trackName"];
   
    
    return cell;
}
//if ([self file:currentTune.trackId isInDirectory:NSTemporaryDirectory()]) {
//    NSLog(@"Found %@",currentTune.trackId);
//    cell.albumArtImageView.image = [UIImage imageNamed:[NSTemporaryDirectory() stringByAppendingPathComponent:currentTune.trackId]];
//} else {
//    cell.albumArtImageView.image = nil;
//    [self getImageFromServer:currentTune.trackId fromURL: currentTune.albumArtFileName atIndexPath:indexPath];
//    NSLog(@"had to fetch %@", currentTune.trackId);
//}






// LAB WORK REFERENCE
//if ([self file:currentFlavor.flavorImageFilename isInDicrectory:[self getDocumentsDirectory]]) {
//    NSLog(@"Found %@", currentFlavor.flavorImageFilename);
//    cell.imageView.image =[UIImage imageNamed:[[self getDocumentsDirectory] stringByAppendingPathComponent:currentFlavor.flavorImageFilename]];
//} else {
//    NSLog(@"Not Found %@", currentFlavor.flavorImageFilename);
//    [self getImageFromServer:currentFlavor.flavorImageFilename fromURL:[NSString stringWithFormat:@"http://%@/classfiles/images/%@",_hostname,currentFlavor.flavorImageFilename] atIndexPath:indexPath];
//    
//    
//}
//
//return cell;
//}


#pragma mark - Interactivity Methods



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *destController = [segue destinationViewController];
    NSIndexPath *indexPath = [_tunesearchTable indexPathForSelectedRow];
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
                NSString *savedFilePath = [[self getDocumentsDirectory] stringByAppendingPathComponent:localFilename];
                UIImage *imageTemp = [UIImage imageWithData:data];
                if (imageTemp !=nil) {
                    [data writeToFile:savedFilePath atomically:true];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tunesearchTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
                        [_tunesearchTable reloadData];
                        
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

//Flavor *newFlavor= [[Flavor alloc] initWithName:[flavorDict objectForKey:@"name"] andImageName:[flavorDict objectForKey:@"filename"] andDateUpdate:[formatter dateFromString:[flavorDict objectForKey:@"dateUpdated"]]];
////                    newFlavor.flavorName = [flavorDict objectForKey:@"name"];
////                    newFlavor.flavorImageFilename = [flavorDict objectForKey:@"filename"];
////                    newFlavor.dateUpdated = [formatter dateFromString:[flavorDict objectForKey:@"dateUpdated"]];
//[_flavorsArray addObject:newFlavor];
//}
//dispatch_async(dispatch_get_main_queue(), ^{
//    //MAIN THREAD CODE GOES HERE
//    // Refresh Data on Interface
//    [_flavorTable reloadData];
//});
//
//}
//
//}] resume];




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




