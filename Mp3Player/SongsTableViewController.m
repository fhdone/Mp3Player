//
//  ViewController.m
//  GetAddressBook
//
//  Created by FHDone on 15/1/12.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//

#import "SongsTableViewController.h"
#import "PlayerViewController.h"
#import "Utils.h"

@interface SongsTableViewController ()

    

@end

@implementation SongsTableViewController




- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songs" forIndexPath:indexPath];
    cell.textLabel.text = [Utils getAllSongs][indexPath.row];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [[Utils getAllSongs] count];
}



#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"PLAY_SONG" ]) {
        if ([segue.destinationViewController isKindOfClass:[PlayerViewController class]]) {
            PlayerViewController *vc = (PlayerViewController *)segue.destinationViewController;
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            [vc setSongName:[Utils getAllSongs][indexPath.row]];
            [Utils setPlayIndex: indexPath.row ];
        }
    }
}


@end
