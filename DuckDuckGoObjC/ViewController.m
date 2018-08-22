//
//  ViewController.m
//  DuckDuckGoObjC
//
//  Created by Nicole Alana Grace on 2018-08-20.
//  Copyright © 2018 The O.I.C. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
    
@synthesize urlArray, textArray, itemDict, resultsTable, urlPrefix, urlQuery, urlSuffix, urlString, jsonDict, resultsData, finalDict, searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Initialize the variables.
    [self initVariables];
    // Provide a default value for the search.
    urlQuery = @"apple";
    // Set our initial URL value.
    [self setUpURL];
    // Make our first call, in the background,
    // as network calls should never be made
    // in the main thread so the UI is stable.
    [self performSelectorInBackground:@selector(aSyncLoad) withObject:nil];
    
}

// Set the default values for the varibles.
- (void) initVariables {
    numItems = 0;
    itemDict = [[NSMutableArray alloc] init];
    urlArray = [[NSMutableArray alloc] init];
    textArray = [[NSMutableArray alloc] init];
}

// Set up the URL for the API call.
- (void) setUpURL {
    // Define the URL prefix and suffix here.
    urlPrefix = @"https://api.duckduckgo.com/?q=";
    urlSuffix = @"&format=json&pretty=1";
    // Assemble the URL.
    urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,urlQuery,urlSuffix];
}

// Perform the API call and download the data.
- (void) aSyncLoad {
    // Define the needed NSError.
    NSError *error;
    // Get raw NSData from the URL.
    resultsData = [NSData dataWithContentsOfURL: [NSURL URLWithString:urlString]];
    // Create an interpretable JSON object from it.
    jsonDict = [NSJSONSerialization JSONObjectWithData:resultsData options:kNilOptions error:&error];
    // The 'RelatedTopics' key contains the relevant data.
    relatedTopics = [jsonDict objectForKey:@"RelatedTopics"];
    // Parse the results.
    [self parseResults];
    
}

// Parse the results from the API call.
// This function is certainly not as clean as it could be.
// The original intention was Swift with Decodables,
// the time wasn't present to make that work.
- (void) parseResults {
    // The project requires a maximum ten results.
    int numResults = 0;
    for(NSDictionary *tempDict in relatedTopics){
        if(numResults<=20){
            // Increase the number of results.
            numResults += 1;
            // Define the empty variables.
            NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
            NSString *resultString;
            NSString *titleString;
            NSString *nameString;
            NSString *firstURLString;
            // Is the result a result or a category?
            if (tempDict[@"Result"] != nil) {
                resultString = [tempDict valueForKey:@"Result"];
                NSRange range= [resultString rangeOfString: @"\">" options: NSBackwardsSearch];
                NSString* finalStr = [resultString substringFromIndex: range.location+2];
                range= [finalStr rangeOfString: @"<" options: NSBackwardsSearch];
                titleString = [finalStr substringToIndex: range.location];
                range= [finalStr rangeOfString: @">" options: NSBackwardsSearch];
                finalStr = [finalStr substringFromIndex: range.location+1];
                [resultDict setValue:@"result" forKey:@"type"];
                [resultDict setValue:finalStr forKey:@"result"];
                [resultDict setValue:titleString forKey:@"title"];
            }
            
            if (tempDict[@"Name"] != nil) {
                nameString = [tempDict valueForKey:@"Name"];
                [resultDict setValue:@"category" forKey:@"type"];
                [resultDict setValue:nameString forKey:@"name"];
            }
            
            if (tempDict[@"FirstURL"] != nil) {
                firstURLString = [tempDict valueForKey:@"FirstURL"];
                [resultDict setValue:firstURLString forKey:@"firsturl"];
            }
            
            if (tempDict[@"Topic"] != nil) {
                NSMutableDictionary *topicDict = [tempDict objectForKey:@"Topic"];
                NSLog(@"td: %@",topicDict);
            }
             NSLog(@"rd: %@",resultDict);
            [itemDict addObject:resultDict];
            
            numItems += 1;
           
        }
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.resultsTable reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Reload the UI post-API call.
- (void) reloadUI {
    [resultsTable reloadData];
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
    }
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSMutableDictionary *tempDict = [itemDict objectAtIndex:indexPath.row];
    NSLog(@"tempDict: %@",tempDict);
    if([[tempDict objectForKey:@"type"] isEqualToString:@"result"]){
        
        cell.textLabel.text = [tempDict objectForKey:@"title"];
        cell.detailTextLabel.text = [tempDict objectForKey:@"result"];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    if([[tempDict objectForKey:@"type"] isEqualToString:@"category"]){
        cell.textLabel.text = [tempDict objectForKey:@"name"];
        cell.detailTextLabel.text = @"(category)";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
   
    return cell;
    
}

#pragma mark UITABLEVIEW_DELEGATE

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *tempDict = [itemDict objectAtIndex:indexPath.row];
    if([[tempDict objectForKey:@"type"] isEqualToString:@"result"]){
        
        NSString *wikiString = [NSString stringWithFormat:@"https://en.wikipedia.org/wiki/%@",[[tempDict objectForKey:@"title"] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:wikiString]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
    
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [itemDict count];
}

#pragma mark UISEARCHBAR_DELEGATE

// If the user cancels, hide the keyboard.
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSLog(@"Cancel clicked");
}

// If the user searches, replace the results.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search clicked");
    [searchBar resignFirstResponder];
    urlQuery = searchBar.text;
    [self initVariables];
    [self setUpURL];
    [self performSelectorInBackground:@selector(aSyncLoad) withObject:nil];
}
    
    @end
