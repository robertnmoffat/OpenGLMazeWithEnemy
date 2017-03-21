//
//  MazeConnector.m
//  GameDev Assignment2
//
//  Created by robert moffat on 3/4/17.
//  Copyright © 2017 robert moffat. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "MazeConnector.h"
#include "maze.h"

struct MazeCPP{
    Maze maze;
};

@implementation MazeConnector

const int WEST_WALL =0;
const int EAST_WALL =1;
const int NORTH_WALL =2;
const int SOUTH_WALL =3;

-(id)init{
    self = [super init];
    if(self){
        mazeCPP = new MazeCPP;
        mazeCPP->maze;
    }
    return self;
}

-(void)setMazeSize:(int)rows columns:(int)cols{
    mazeCPP->maze.initMaze(rows, cols);
   // mazeCPP->maze.rows = rows;
    //mazeCPP->maze.cols = cols;
    
    //mazeCPP->maze.GetCell(1, 1);
}

-(void)createMaze{
    //mazeCPP->maze.Create();
    mazeCPP->maze.hardSetMaze();
    
    int i, j;
    
    printf("2D overhead view of 3D maze:\n");
    
    int numRows = 5;
    int numCols=5;
    
    for (i=numRows-1; i>=0; i--) {
        
        for (j=numCols-1; j>=0; j--) { // top
            
            printf(" %c ", mazeCPP->maze.GetCell(i, j).southWallPresent ? '-' : ' ');
            
        }
        
        printf("\n");
        
        for (j=numCols-1; j>=0; j--) { // left/right
            
            printf("%c", mazeCPP->maze.GetCell(i, j).eastWallPresent ? '|' : ' ');
            
            printf("%c", ((i+j) < 1) ? '*' : ' ');
            
            printf("%c", mazeCPP->maze.GetCell(i, j).westWallPresent ? '|' : ' ');
            
        }
        
        printf("\n");
        
        for (j=numCols-1; j>=0; j--) { // bottom
            
            printf(" %c ", mazeCPP->maze.GetCell(i, j).northWallPresent ? '-' : ' ');
            
        }
        
        printf("\n");
        
    }
}

-(bool)hasNorthWall:(int)row column:(int)col{
    return mazeCPP->maze.GetCell(row, col).northWallPresent;
}

-(bool)hasSouthWall:(int)row column:(int)col{
    return mazeCPP->maze.GetCell(row, col).southWallPresent;
}

-(bool)hasWestWall:(int)row column:(int)col{
    return mazeCPP->maze.GetCell(row, col).westWallPresent;
}

-(bool)hasEastWall:(int)row column:(int)col{
    return mazeCPP->maze.GetCell(row, col).eastWallPresent;
}

-(bool)hasWallAt:(int)direction row:(int)row coloumn:(int)column{
    switch(direction){
        case WEST_WALL:
            return mazeCPP->maze.GetCell(row, column).westWallPresent;
            break;
        case EAST_WALL:
            return mazeCPP->maze.GetCell(row, column).eastWallPresent;
            break;
        case NORTH_WALL:
            return mazeCPP->maze.GetCell(row, column).northWallPresent;
            break;
        case SOUTH_WALL:
            return mazeCPP->maze.GetCell(row, column).southWallPresent;
            break;
        default:
            return false;
    }
}


@end
