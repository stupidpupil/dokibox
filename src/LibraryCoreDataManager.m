//
//  LibraryCoreDataManager.m
//  dokibox
//
//  Created by Miles Wu on 30/06/2013.
//
//

#import "LibraryCoreDataManager.h"
#import "LibraryTrack.h"

@implementation LibraryCoreDataManager

SHAREDINSTANCE

-(id)init
{
    if(self = [super initWithFilename:@"library.sql" andModel:[self model]]) {
    }
    return self;
}

-(NSManagedObjectModel*)model
{
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] init];
    NSMutableArray *entities = [[NSMutableArray alloc] init];

    NSEntityDescription *trackEntity = [[NSEntityDescription alloc] init];
    NSEntityDescription *albumEntity = [[NSEntityDescription alloc] init];
    NSEntityDescription *artistEntity = [[NSEntityDescription alloc] init];

    { // Track
        [trackEntity setName:@"track"];
        [trackEntity setManagedObjectClassName:@"LibraryTrack"];
        NSMutableArray *trackProperties = [[NSMutableArray alloc] init];
        { // trackEntity properties
            NSAttributeDescription *filenameAttribute = [[NSAttributeDescription alloc] init];
            [filenameAttribute setName:@"filename"];
            [filenameAttribute setAttributeType:NSStringAttributeType];
            [filenameAttribute setOptional:NO];
            [trackProperties addObject:filenameAttribute];

            NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
            [nameAttribute setName:@"name"];
            [nameAttribute setAttributeType:NSStringAttributeType];
            [nameAttribute setOptional:NO];
            [trackProperties addObject:nameAttribute];
            
            NSAttributeDescription *trackNumberAttribute = [[NSAttributeDescription alloc] init];
            [trackNumberAttribute setName:@"trackNumber"];
            [trackNumberAttribute setAttributeType:NSInteger32AttributeType];
            [trackNumberAttribute setOptional:YES];
            [trackProperties addObject:trackNumberAttribute];
            
            NSAttributeDescription *lengthAttribute = [[NSAttributeDescription alloc] init];
            [lengthAttribute setName:@"length"];
            [lengthAttribute setAttributeType:NSInteger32AttributeType];
            [lengthAttribute setOptional:YES];
            [trackProperties addObject:lengthAttribute];

            NSAttributeDescription *attributesAttribute = [[NSAttributeDescription alloc] init];
            [attributesAttribute setName:@"attributes"];
            [attributesAttribute setAttributeType:NSUndefinedAttributeType];
            [attributesAttribute setTransient:YES];
            [trackProperties addObject:attributesAttribute];

            NSRelationshipDescription *albumRelation = [[NSRelationshipDescription alloc] init];
            [albumRelation setName:@"album"];
            [albumRelation setDestinationEntity:albumEntity];
            [albumRelation setMaxCount:1];
            [albumRelation setMinCount:1];
            //[albumRelation setOptional:NO];
            [trackProperties addObject:albumRelation];
        }
        [trackEntity setProperties:trackProperties];
        [entities addObject:trackEntity];
    }

    { // album
        [albumEntity setName:@"album"];
        [albumEntity setManagedObjectClassName:@"LibraryAlbum"];
        NSMutableArray *albumProperties = [[NSMutableArray alloc] init];
        { // albumEntity properties
            NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
            [nameAttribute setName:@"name"];
            [nameAttribute setAttributeType:NSStringAttributeType];
            [nameAttribute setOptional:NO];
            [albumProperties addObject:nameAttribute];

            NSRelationshipDescription *artistRelation = [[NSRelationshipDescription alloc] init];
            [artistRelation setName:@"artist"];
            [artistRelation setDestinationEntity:artistEntity];
            [artistRelation setMaxCount:1];
            [artistRelation setMinCount:1];
            //[artistRelation setOptional:NO];
            [albumProperties addObject:artistRelation];

            NSRelationshipDescription *tracksRelation = [[NSRelationshipDescription alloc] init];
            [tracksRelation setName:@"tracks"];
            [tracksRelation setDestinationEntity:trackEntity];
            [tracksRelation setMinCount:1];
            //[tracksRelation setOptional:NO];
            [albumProperties addObject:tracksRelation];

        }
        [albumEntity setProperties:albumProperties];
        [entities addObject:albumEntity];
    }

    { // Artist
        [artistEntity setName:@"artist"];
        [artistEntity setManagedObjectClassName:@"LibraryArtist"];
        NSMutableArray *artistProperties = [[NSMutableArray alloc] init];
        { // artistEntity properties
            NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
            [nameAttribute setName:@"name"];
            [nameAttribute setAttributeType:NSStringAttributeType];
            [nameAttribute setOptional:NO];
            [artistProperties addObject:nameAttribute];

            NSRelationshipDescription *albumsRelation = [[NSRelationshipDescription alloc] init];
            [albumsRelation setName:@"albums"];
            [albumsRelation setDestinationEntity:albumEntity];
            [albumsRelation setMinCount:1];
            //[albumsRelation setOptional:NO];
            [artistProperties addObject:albumsRelation];
        }
        [artistEntity setProperties:artistProperties];
        [entities addObject:artistEntity];
    }

    [[[artistEntity relationshipsByName] objectForKey:@"albums"] setInverseRelationship:[[albumEntity relationshipsByName] objectForKey:@"artist"]];
    [[[albumEntity relationshipsByName] objectForKey:@"artist"] setInverseRelationship:[[artistEntity relationshipsByName] objectForKey:@"albums"]];
    [[[albumEntity relationshipsByName] objectForKey:@"tracks"] setInverseRelationship:[[trackEntity relationshipsByName] objectForKey:@"album"]];
    [[[trackEntity relationshipsByName] objectForKey:@"album"] setInverseRelationship:[[albumEntity relationshipsByName] objectForKey:@"tracks"]];

    [mom setEntities:entities];
    return mom;
}

@end