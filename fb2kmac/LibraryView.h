//
//  LibaryView.h
//  fb2kmac
//
//  Created by Miles Wu on 05/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "TUIKit.h"


@interface LibraryView : TUIView <TUITableViewDelegate, TUITableViewDataSource> {
    TUITableView *_tableView;
}

@end