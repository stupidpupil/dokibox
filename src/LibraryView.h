//
//  LibaryView.h
//  dokibox
//
//  Created by Miles Wu on 05/02/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RBLScrollView;
@class LibraryViewSearchView;
@class TableViewRowData;
@class Library;

@interface LibraryView : NSView <NSTableViewDataSource, NSTableViewDelegate> {
    NSTableView *_tableView;
    RBLScrollView *_libraryScrollView;
    NSView *_libraryNoTracksView;
    LibraryViewSearchView *_librarySearchView;
    BOOL _searchVisible;
    NSString *_searchString;
    
    TableViewRowData *_rowData;
    
    Library *_library;
    NSManagedObjectContext *_objectContext;
    NSMutableSet *_searchMatchedObjects;
    
    dispatch_queue_t _searchQueue;
    int _searchQueueDepth;
}

- (id)initWithFrame:(CGRect)frame andLibrary:(Library *)library;

-(void)runSearch:(NSString *)text;

- (void)addButtonPressed:(id)sender;

-(BOOL)isRowExpanded:(NSUInteger)row;
-(BOOL)isRowExpanded:(NSUInteger)row inCellData:(NSMutableArray*)celldata;
-(void)collapseRow:(NSUInteger)row;
-(void)expandRow:(NSUInteger)row;
-(void)expandRow:(NSUInteger)row recursive:(BOOL)recursive onCellData:(NSMutableArray*)celldata andMatchedObjects:(NSMutableSet*)matchedObjects;
-(void)expandRow:(NSUInteger)row recursive:(BOOL)recursive;
-(NSInteger)insertionIndexFor:(NSManagedObject *)object withSearchFiltering:(BOOL)searchFiltering;

@property() BOOL searchVisible;

@end
