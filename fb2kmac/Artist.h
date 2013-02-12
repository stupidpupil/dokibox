//
//  Artist.h
//  fb2kmac
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import <CoreData/CoreData.h>
#import "common.h"

@interface Artist : NSManagedObject

@property (nonatomic) NSString *name;
@property (readonly, nonatomic) NSSet* albums;
@property (readonly, nonatomic) NSSet* tracks;

@end
