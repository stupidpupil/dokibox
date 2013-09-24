//
//  Album.m
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import "LibraryAlbum.h"
#import "LibraryArtist.h"
#import "LibraryTrack.h"
#import "LibraryCoreDataManager.h"

@implementation LibraryAlbum
@dynamic name;
@dynamic artist;
@dynamic tracks;

@synthesize isCoverFetched = _isCoverFetched;

-(NSSet*)tracksFromSet:(NSSet *)set
{
    if([set member:self] || [set member:[self artist]]) // when itself or parent artist is the match, return all
        return [self tracks];
    else {
        NSMutableSet *retval = [[NSMutableSet alloc] initWithSet:[self tracks]];
        [retval intersectSet:set];
        return retval;
    }
}

-(void)setArtistByName:(NSString *)artistName
{
    NSError *error;
    LibraryArtist *artist;

    if([self artist]) { //prune old one
        [[self artist] pruneDueToAlbumBeingDeleted:self];
    }

    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", artistName];
    [fr setPredicate:predicate];

    NSArray *results = [[self managedObjectContext] executeFetchRequest:fr error:&error];
    if(results == nil) {
        NSLog(@"error fetching results");
    }
    else if([results count] == 0) {
        artist = [NSEntityDescription insertNewObjectForEntityForName:@"artist" inManagedObjectContext:[self managedObjectContext]];
        [artist setName:artistName];
    }
    else { //already exists in library
        artist = [results objectAtIndex:0];
    }

    [self setArtist:artist];
}

-(void)pruneDueToTrackBeingDeleted:(LibraryTrack *)track;
{
    if([[self tracks] count] == 1) {
        LibraryTrack *lastTrack = [[[self tracks] allObjects] objectAtIndex:0];
        if([[lastTrack objectID] isEqual:[track objectID]]) {
            [[self managedObjectContext] deleteObject:self];
        }
    }
}

-(void)prepareForDeletion
{
    [[self artist] pruneDueToAlbumBeingDeleted:self];
}

-(NSImage*)cover
{
    if(_isCoverFetched == NO) {
        // Look for directory first
        NSMutableSet *trackDirs = [[NSMutableSet alloc] init];
        for(LibraryTrack *t in [self tracks]) {
            NSString *s = [[t filename] substringToIndex:[[t filename] length] - [[[t filename] lastPathComponent] length]];
            [trackDirs addObject:s];
        }
        if([trackDirs count] == 1) { // all tracks belong in one folder
            NSError *error;
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *dir = [[trackDirs allObjects] objectAtIndex:0];
            
            NSArray *files = [fm contentsOfDirectoryAtPath:dir error:&error];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@ OR SELF LIKE[c] %@", @"cover.jpg", @"folder.jpg"];
            NSArray *possible = [files filteredArrayUsingPredicate:pred];
            if([possible count] >= 1) {
                NSString *coverlocation = [NSString stringWithFormat:@"%@/%@", dir, [possible objectAtIndex:0]];
                _cover = [[NSImage alloc] initWithContentsOfFile:coverlocation];
                _isCoverFetched = YES;
                return _cover;
            }
        }
        
        // Now try the track tags
        if([[self tracks] count] > 0) {
            LibraryTrack *t = [[[self tracks] allObjects] objectAtIndex:0];
            NSImage *cover = [t cover];
            if(cover) {
                _cover = cover;
                _isCoverFetched = YES;
                return _cover;
            }
        }

    }
    return _cover;
}

-(void)fetchCoverAsync:(void (^) ())blockWhenFinished
{
    if(_isCoverFetched) {
        blockWhenFinished();
        return;
    }
    dispatch_queue_t calling_q = dispatch_get_current_queue();

    
    NSManagedObjectID *self_id = [self objectID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSManagedObjectContext *context = [LibraryCoreDataManager newContext];
        LibraryAlbum *album = (LibraryAlbum*)[context objectWithID:self_id];
        NSImage *cover = [album cover];
        
        dispatch_async(calling_q, ^{ // call block on original queue
            _isCoverFetched = YES;
            _cover = cover;
            blockWhenFinished();
        });
    });
}

@end
