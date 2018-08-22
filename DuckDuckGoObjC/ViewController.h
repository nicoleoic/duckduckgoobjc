//
//  ViewController.h
//  DuckDuckGoObjC
//
//  Created by Nicole Alana Grace on 2018-08-20.
//  Copyright © 2018 The O.I.C. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    
    // Result data
    NSData *resultsData;
    
    // Declare arrays
    NSMutableArray *itemDict;
    NSMutableArray *urlArray;
    NSMutableArray *textArray;
    NSMutableArray *relatedTopics;
    
    // Declare dictionaries
    NSMutableDictionary *jsonDict;
    NSMutableDictionary *finalDict;
    
    NSString *urlPrefix;
    NSString *urlQuery;
    NSString *urlSuffix;
    NSString *urlString;
    
    int numItems;
    
    UITableView *resultsTable;
    UISearchBar *searchBar;
    
}

// The property declaration is unncessary.
// A self reference would work fine.
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) IBOutlet UITableView *resultsTable;

@property (nonatomic,retain) NSData *resultsData;

@property (nonatomic,retain) NSMutableArray *itemDict;
@property (nonatomic,retain) NSMutableArray *urlArray;
@property (nonatomic,retain) NSMutableArray *textArray;

@property (nonatomic,retain) NSMutableDictionary *jsonDict;
@property (nonatomic,retain) NSMutableDictionary *finalDict;

@property (nonatomic,retain) NSString *urlPrefix;
@property (nonatomic,retain) NSString *urlQuery;
@property (nonatomic,retain) NSString *urlSuffix;
@property (nonatomic,retain) NSString *urlString;

@end

