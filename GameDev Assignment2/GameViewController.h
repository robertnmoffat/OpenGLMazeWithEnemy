//
//  GameViewController.h
//  GameDev Assignment2
//
//  Created by robert moffat on 3/2/17.
//  Copyright © 2017 robert moffat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "MazeConnector.h"
#import "Floor.h"

extern const int mazeSize = 5;

@interface GameViewController : GLKViewController{
    NSMutableArray *floorModelViewProjMatrixArray;
    NSMutableArray *floorTranslationMatrixArray;
    NSMutableArray *floorRotationMatrixArray;
    
    GLuint _texCoordSlot;
    GLuint _textureUniform;
}

-(void)initializeMapArrays;
-(GLuint)setupTexture:(NSString *)fileName;
-(void)generateTexStuff:(GLfloat **)textureCoords;

@end
