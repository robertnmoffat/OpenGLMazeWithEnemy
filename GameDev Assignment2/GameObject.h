//
//  GameObject.h
//  GameDev Assignment2
//
//  Created by robert moffat on 3/6/17.
//  Copyright © 2017 robert moffat. All rights reserved.
//

#ifndef GameObject_h
#define GameObject_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

@interface GameObject : NSObject{
@public
    
@private
    int _x,_y,_z;
    int _rotx,_roty,_rotz;
}

-(GLKMatrix4)getTranslationMatrix;
-(GLKMatrix4)getRotationMatrix;

-(void)setx:(int)x;
-(void)sety:(int)y;
-(void)setz:(int)z;
-(void)setRotx:(int)rotx;
-(void)setRoty:(int)roty;
-(void)setRotz:(int)rotz;


@end

#endif /* GameObject_h */
