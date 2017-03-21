//
//  MazeConnector.h
//  GameDev Assignment2
//
//  Created by robert moffat on 3/4/17.
//  Copyright © 2017 robert moffat. All rights reserved.
//

#ifndef MazeConnector_h
#define MazeConnector_h

#import <Foundation/Foundation.h>



struct MazeCPP;

@interface MazeConnector : NSObject{
@public
    
@private
    struct MazeCPP *mazeCPP;
    
    
}

-(void)setMazeSize: (int)rows columns:(int)cols;
-(void)createMaze;

-(bool)hasNorthWall: (int)row column:(int)col;
-(bool)hasSouthWall: (int)row column:(int)col;
-(bool)hasWestWall: (int)row column:(int)col;
-(bool)hasEastWall: (int)row column:(int)col;

-(bool)hasWallAt:(int)direction row:(int)row coloumn:(int)column;

@end


#endif /* MazeConnector_h */
