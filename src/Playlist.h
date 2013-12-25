//
//  Playlist.h
//  dokibox
//
//  Created by Miles Wu on 28/07/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PlaylistTrack.h"

@interface Playlist : NSManagedObject {
    BOOL _shuffle;
    NSMutableArray *_shuffleNotPlayedYetTracks;
}

-(NSUInteger)numberOfTracks;
-(NSUInteger)getTrackIndex:(PlaylistTrack *)track;
-(PlaylistTrack *)trackAtIndex:(NSUInteger)index;
-(PlaylistTrack *)currentlyActiveTrack;

-(void)removeTrackAtIndex:(NSUInteger)index;
-(void)removeTrack:(PlaylistTrack *)track;

-(void)insertTrackWithFilename:(NSString *)filename atIndex:(NSUInteger)index onCompletion:(void (^)(void)) completionHandler;
-(void)insertTrack:(PlaylistTrack *)track atIndex:(NSUInteger)index;
-(void)addTrackWithFilename:(NSString *)filename onCompletion:(void (^)(void)) completionHandler;
-(void)addTrack:(PlaylistTrack *)track;

-(void)playTrackAtIndex:(NSUInteger)index;
-(void)playNextTrackAfter:(PlaylistTrack *)trackJustEnded;
-(void)save;

@property (nonatomic) NSString *name;
@property (nonatomic) NSSet* tracks;
@property BOOL repeat;
@property BOOL shuffle;

@end