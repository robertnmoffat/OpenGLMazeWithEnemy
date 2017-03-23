//
//  GameViewController.m
//  GameDev Assignment2
//
//  Created by robert moffat on 3/2/17.
//  Copyright © 2017 robert moffat. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#include <stdlib.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_MODELVIEW_MATRIX,
    /* more uniforms needed here... */
    UNIFORM_TEXTURE,
    UNIFORM_FLASHLIGHT_POSITION,
    UNIFORM_DIFFUSE_LIGHT_POSITION,
    UNIFORM_SHININESS,
    UNIFORM_AMBIENT_COMPONENT,
    UNIFORM_DIFFUSE_COMPONENT,
    UNIFORM_SPECULAR_COMPONENT,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

const int WEST_WALL =0;
const int EAST_WALL =1;
const int NORTH_WALL =2;
const int SOUTH_WALL =3;

const int WEST_DIRECTION =0;
const int EAST_DIRECTION =1;
const int NORTH_DIRECTION =2;
const int SOUTH_DIRECTION =3;


typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2]; // New
} Vertex;

const Vertex texVertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, 0}, {1, 0, 0, 1}, {1, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}, {0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}, {0, 0}},
    {{1, -1, -1}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, -1}, {1, 0, 0, 1}, {1, 1}},
    {{-1, 1, -1}, {0, 1, 0, 1}, {0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}, {0, 0}}
};

GLfloat cubeTex[] =
{
    0.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f,
    1.0f, 0.0f,
    1.0f, 0.0f,
    1.0f, 1.0f,
    0.0f, 1.0f,
    0.0f, 0.0f,
    0.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f,
    1.0f, 0.0f,
    0.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f,
    1.0f, 0.0f,
    0.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f,
    1.0f, 0.0f,
    0.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f,
    1.0f, 0.0f,
};

GLfloat floorVertexData[] =
{
    0.5f, 0.0f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.0f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.0f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.0f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.0f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.0f, 0.5f,         0.0f, 1.0f, 0.0f
};

//Left wall Facing right
GLfloat wallWestVertexData[] =
{
    -0.48f, 0.0f, -0.5f,        1.0f, 0.0f, 0.0f,
    -0.48f, 1.0f, -0.5f,         1.0f, 0.0f, 0.0f,
    -0.48f, 0.0f, 0.5f,         1.0f, 0.0f, 0.0f,
    -0.48f, 0.0f, 0.5f,         1.0f, 0.0f, 0.0f,
    -0.48f, 1.0f, -0.5f,          1.0f, 0.0f, 0.0f,
    -0.48f, 1.0f, 0.5f,         1.0f, 0.0f, 0.0f
};

GLfloat wallEastVertexData[] =
{
    0.48f, 0.0f, -0.5f,        -1.0f, 0.0f, 0.0f,
    0.48f, 1.0f, -0.5f,         -1.0f, 0.0f, 0.0f,
    0.48f, 1.0f, 0.5f,         -1.0f, 0.0f, 0.0f,
    0.48f, 0.0f, 0.5f,         -1.0f, 0.0f, 0.0f,
    0.48f, 1.0f, -0.5f,         -1.0f, 0.0f, 0.0f,
    0.48f, 1.0f, 0.5f,         -1.0f, 0.0f, 0.0f
};

GLfloat wallNorthVertexData[] =
{
    0.5f, 1.0f, -0.48f,          0.0f, 0.0f, 1.0f,
    -0.5f, 1.0f, -0.48f,         0.0f, 0.0f, 1.0f,
    0.5f, 0.0f, -0.48f,         0.0f, 0.0f, 1.0f,
    0.5f, 0.0f, -0.48f,         0.0f, 0.0f, 1.0f,
    -0.5f, 1.0f, -0.48f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.0f, -0.48f,        0.0f, 0.0f, 1.0f
};

GLfloat wallSouthVertexData[] =
{
    0.5f, 1.0f, 0.48f,          0.0f, 0.0f, -1.0f,
    -0.5f, 1.0f, 0.48f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.0f, 0.48f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.0f, 0.48f,         0.0f, 0.0f, -1.0f,
    -0.5f, 1.0f, 0.48f,         0.0f, 0.0f, -1.0f,
    -0.5f, 0.0f, 0.48f,        0.0f, 0.0f, -1.0f
};

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@interface GameViewController () {
    GLuint _program;
    GLuint _programBlocked;
    GLuint _programLeft;
    GLuint _programRight;
    GLuint _programBoth;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    // Lighting parameters
    /* specify lighting parameters here...e.g., GLKVector3 flashlightPosition; */
    GLKVector3 flashlightPosition;
    GLKVector3 diffuseLightPosition;
    GLKVector4 diffuseComponent;
    float shininess;
    GLKVector4 specularComponent;
    GLKVector4 ambientComponent;
    
    GLKMatrix4 _floorModelViewProjectionMatrix;
    GLKMatrix3 _floorNormalMatrix;
    GLKMatrix4 _wallModelViewProjectionMatrix;
    GLKMatrix3 _wallNormalMatrix;
    
    
    
    GLuint _floorVertexArray;
    GLuint _floorVertexBuffer;
    
    GLuint _wallWestVertexArray;
    GLuint _wallWestVertexBuffer;
    GLuint _wallEastVertexArray;
    GLuint _wallEastVertexBuffer;
    GLuint _wallNorthVertexArray;
    GLuint _wallNorthVertexBuffer;
    GLuint _wallSouthVertexArray;
    GLuint _wallSouthVertexBuffer;
    
    GLuint _cubeVertexArray;
    GLuint _cubeVertexBuffer;
    
    GLKMatrix4 floorMatrices[mazeSize*mazeSize];
    GLKMatrix3 floorNormMatrices[mazeSize*mazeSize];
    
    GLKMatrix4 cubeMatrix;
    GLKMatrix3 cubeNormMatrix;
    
    GLKMatrix4 enemyMatrix;
    GLKMatrix3 enemyNormMatrix;
    
    GLKMatrix4 wallMatrices[mazeSize*mazeSize*4];
    GLKMatrix3 wallNormMatrices[mazeSize*mazeSize*4];
    
    
    /* texture parameters ??? */
    GLuint crateTexture;
    GLuint blockedTexture;
    GLuint bothTexture;
    GLuint leftTexture;
    GLuint rightTexture;
    GLuint northTexture;
    GLuint southTexture;
    
    //-----------------------------------------
    //              FLOOR
    // GLES buffer IDs
    GLuint _floorVertexBuffers[3];
    // Shape vertices, etc. and textures
    GLfloat *floorVertices, *floorNormals, *floorTexCoords;
    GLuint floorNumIndices, *floorIndices;
    
    GLuint _floor2VertexArray;
    GLuint _floor2VertexBuffer;
    //GLuint _texVertexBuffer;
    GLuint _floorIndexBuffer;
    
    
    //              NORTH WALL
    // GLES buffer IDs
    GLuint _wallNorthVertexBuffers[3];
    // Shape vertices, etc. and textures
    GLfloat *wallNorthVertices, *wallNorthNormals, *wallNorthTexCoords;
    GLuint wallNorthNumIndices, *wallNorthIndices;
    
    GLuint _wallNorth2VertexArray;
    GLuint _wallNorth2VertexBuffer;
    //GLuint _texVertexBuffer;
    GLuint _wallNorthIndexBuffer;
    
    
    //              SOUTH WALL
    // GLES buffer IDs
    GLuint _wallSouthVertexBuffers[3];
    // Shape vertices, etc. and textures
    GLfloat *wallSouthVertices, *wallSouthNormals, *wallSouthTexCoords;
    GLuint wallSouthNumIndices, *wallSouthIndices;
    
    GLuint _wallSouth2VertexArray;
    GLuint _wallSouth2VertexBuffer;
    //GLuint _texVertexBuffer;
    GLuint _wallSouthIndexBuffer;
    
    
    
    //              EAST WALL
    // GLES buffer IDs
    GLuint _wallEastVertexBuffers[3];
    // Shape vertices, etc. and textures
    GLfloat *wallEastVertices, *wallEastNormals, *wallEastTexCoords;
    GLuint wallEastNumIndices, *wallEastIndices;
    
    GLuint _wallEast2VertexArray;
    GLuint _wallEast2VertexBuffer;
    //GLuint _texVertexBuffer;
    GLuint _wallEastIndexBuffer;
    
    
    //              West WALL
    // GLES buffer IDs
    GLuint _wallWestVertexBuffers[3];
    // Shape vertices, etc. and textures
    GLfloat *wallWestVertices, *wallWestNormals, *wallWestTexCoords;
    GLuint wallWestNumIndices, *wallWestIndices;
    
    GLuint _wallWest2VertexArray;
    GLuint _wallWest2VertexBuffer;
    //GLuint _texVertexBuffer;
    GLuint _wallWestIndexBuffer;
    
    
    //              Cube WALL
    // GLES buffer IDs
    GLuint _cubeVertexBuffers[3];
    // Shape vertices, etc. and textures
    GLfloat *cubeVertices, *cubeNormals, *cubeTexCoords;
    GLuint cubeNumIndices, *cubeIndices;
    
    GLuint _cube2VertexArray;
    GLuint _cube2VertexBuffer;
    //GLuint _texVertexBuffer;
    GLuint _cubeIndexBuffer;
    
    
    //              Custom File Loaded Enemy
    // GLES buffer IDs
    GLuint _enemyVertexBuffers[3];
    // Shape vertices, etc. and textures
    GLfloat *enemyVertices, *enemyNormals;//, *cubeTexCoords;
    GLuint enemyNumIndices, *enemyIndices, *enemyNormIndices;
    
    GLuint _enemyVertexArray;
    GLuint _enemyVertexBuffer;
    //GLuint _enemyIndexBuffer[2];
    GLuint _enemyIndexBuffer;
    
    GLfloat enemyxPos;
    GLfloat enemyzPos;
    GLuint enemyDirection;
    GLfloat enemySpeed;
    //----------------------------------------
    
    //Touch stuff
    bool _rotating;
    CGPoint _touchStartPoint;
    CGPoint _touchEndPoint;
    CGPoint _touchSave;
    CGPoint _touchZoomStartPoint1;
    CGPoint _touchZoomStartPoint2;
    CGPoint _touchZoomEndPoint1;
    CGPoint _touchZoomEndPoint2;
    float _totalRotationHori;
    float _totalRotationVert;
    float _touchHoriRotation;
    float _touchVertRotation;
    float _translationx, _translationy, _translationz;
    float _totalTranslationx, _totalTranslationy, _totalTranslationz;
    float _scale;
    float _totalScale;
    
    float _playerXpos;
    float _playerYpos;
    
    float _previousRotVert;
    
    
    //enemy stuff
    //Vertex enemyVertices[5];
    //GLubyte enemyIndices[5];
    
    //int mazeSize;
    
    MazeConnector *mazeConnector;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    //mazeSize = 5;
    
    //floorArray = [[NSMutableArray alloc] initWithCapacity:mazeSize*mazeSize];
    floorModelViewProjMatrixArray = [[NSMutableArray alloc] initWithCapacity:mazeSize*mazeSize];
    floorTranslationMatrixArray = [[NSMutableArray alloc] initWithCapacity:mazeSize*mazeSize];
    floorRotationMatrixArray = [[NSMutableArray alloc] initWithCapacity:mazeSize*mazeSize];
    
    
    [self initializeMapArrays];
    mazeConnector = [[MazeConnector alloc] init];
    [mazeConnector setMazeSize:mazeSize columns:mazeSize];
    [mazeConnector createMaze];
    NSLog(@"wall: %d", [mazeConnector hasEastWall:1 column:1]);
    
    _playerXpos=0;
    _playerYpos=0;
    enemyxPos=7.5;
    enemyzPos=7.5;
    enemyDirection=NORTH_DIRECTION;
    enemySpeed =10;
    
    //[self readObjFile:@"monkeyBlock"];
    [self setupVBOs];
    [self setupGL];
}

-(void)initializeMapArrays{
    for(int i=0; i<mazeSize*mazeSize; i++){
        Floor *floor = [[Floor alloc] init];
        //[floorArray addObject:floor];
    }
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setupVBOs{
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(enemyVertices), enemyVertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(enemyIndices), enemyIndices, GL_STATIC_DRAW);
}

/*
    read in contents of obj file
 */
void readObjFile( NSString* fileName, NSMutableArray* vertexMutArray, NSMutableArray* normalMutArray, NSMutableArray* indexMutArray, NSMutableArray* normIndexMutArray){
    NSString *filepath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"obj"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    
    // maybe for debugging...
    //NSLog(@"contents: %@", fileContents);
    
    NSArray *listArray = [fileContents componentsSeparatedByString:@"\n"];
    //NSLog(@"items = %lu", (unsigned long)[listArray count]);
    
    
    NSArray *stringArray = [fileContents componentsSeparatedByString:@"\n"];
    for(int i=4; i<[stringArray count]; i++){
        NSString *currentLine =[stringArray objectAtIndex:i];
        if([currentLine length]==0)continue;
        unichar firstLetter = [currentLine characterAtIndex:0];
        unichar secondLetter = [currentLine characterAtIndex:1];
        if(firstLetter=='v'){
            if(secondLetter=='n'){
                NSString *stringWithoutVn = [currentLine substringFromIndex:2];
                NSArray *vertices = [stringWithoutVn componentsSeparatedByString:@" "];
                //offset by 1 to make up for first space
                for(int j=1; j<[vertices count]; j++){
                    NSString *stringVertex = [vertices objectAtIndex:j];
                    //GLfloat floatVertex = [[formatter numberFromString:stringVertex] floatValue];
                    [normalMutArray addObject:stringVertex];
                    //NSLog(@"%@",[vectors objectAtIndex:j]);
                }
            }else{
                NSString *stringWithoutV = [currentLine substringFromIndex:1];
                NSArray *vertices = [stringWithoutV componentsSeparatedByString:@" "];
                //offset by 1 to make up for first space
                for(int j=1; j<[vertices count]; j++){
                    NSString *stringVertex = [vertices objectAtIndex:j];
                    //GLfloat floatVertex = [[formatter numberFromString:stringVertex] floatValue];
                    [vertexMutArray addObject:stringVertex];
                    //NSLog(@"%@",[vectors objectAtIndex:j]);
                }
            }
        }else if(firstLetter=='f'){
            NSString *stringWithoutf = [currentLine substringFromIndex:1];
            NSArray *vertices = [stringWithoutf componentsSeparatedByString:@" "];
            //offset by 1 to make up for first space
            for(int j=1; j<[vertices count]; j++){
                NSString *stringIndicesWithSlashes = [vertices objectAtIndex:j];
                NSArray *indicesVertAndNorm = [stringIndicesWithSlashes componentsSeparatedByString:@"//"];
                //GLfloat floatVertex = [[formatter numberFromString:stringVertex] floatValue];
                [indexMutArray addObject:[indicesVertAndNorm objectAtIndex:0]];
                [normIndexMutArray addObject:[indicesVertAndNorm objectAtIndex:1]];
                //NSLog(@"%@",[vectors objectAtIndex:j]);
            }
        }
    }
//    NSLog(@"vertexMutArray:%@", vertexMutArray);
//    NSLog(@"Vertex count: %lu", (unsigned long)[vertexMutArray count]);
//    NSLog(@"Normal count: %lu", (unsigned long)[normalMutArray count]);
    
    
    
    //[stringArray count];
    //NSLog(@"%c", firstLetter);
}

-(void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // Load shaders
    [self loadShaders];
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_program, "modelViewMatrix");
    /* more needed here... */
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "texture");
    uniforms[UNIFORM_FLASHLIGHT_POSITION] = glGetUniformLocation(_program, "flashlightPosition");
    uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION] = glGetUniformLocation(_program, "diffuseLightPosition");
    uniforms[UNIFORM_SHININESS] = glGetUniformLocation(_program, "shininess");
    uniforms[UNIFORM_AMBIENT_COMPONENT] = glGetUniformLocation(_program, "ambientComponent");
    uniforms[UNIFORM_DIFFUSE_COMPONENT] = glGetUniformLocation(_program, "diffuseComponent");
    uniforms[UNIFORM_SPECULAR_COMPONENT] = glGetUniformLocation(_program, "specularComponent");
    
    // Load in and set texture
    /* use setupTexture to create crate texture */
    crateTexture = [self setupTexture:@"crate.jpg"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, crateTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_programBlocked, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_programBlocked, "normalMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_programBlocked, "modelViewMatrix");
    /* more needed here... */
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_programBlocked, "texture");
    uniforms[UNIFORM_FLASHLIGHT_POSITION] = glGetUniformLocation(_programBlocked, "flashlightPosition");
    uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION] = glGetUniformLocation(_programBlocked, "diffuseLightPosition");
    uniforms[UNIFORM_SHININESS] = glGetUniformLocation(_programBlocked, "shininess");
    uniforms[UNIFORM_AMBIENT_COMPONENT] = glGetUniformLocation(_programBlocked, "ambientComponent");
    uniforms[UNIFORM_DIFFUSE_COMPONENT] = glGetUniformLocation(_programBlocked, "diffuseComponent");
    uniforms[UNIFORM_SPECULAR_COMPONENT] = glGetUniformLocation(_programBlocked, "specularComponent");
    
    // Load in and set texture
    /* use setupTexture to create crate texture */
    blockedTexture = [self setupTexture:@"blocked.jpg"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, blockedTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    northTexture = [self setupTexture:@"north.jpg"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, northTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    southTexture = [self setupTexture:@"south.jpg"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, southTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_programBoth, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_programBoth, "normalMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_programBoth, "modelViewMatrix");
    /* more needed here... */
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_programBoth, "texture");
    uniforms[UNIFORM_FLASHLIGHT_POSITION] = glGetUniformLocation(_programBoth, "flashlightPosition");
    uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION] = glGetUniformLocation(_programBoth, "diffuseLightPosition");
    uniforms[UNIFORM_SHININESS] = glGetUniformLocation(_programBoth, "shininess");
    uniforms[UNIFORM_AMBIENT_COMPONENT] = glGetUniformLocation(_programBoth, "ambientComponent");
    uniforms[UNIFORM_DIFFUSE_COMPONENT] = glGetUniformLocation(_programBoth, "diffuseComponent");
    uniforms[UNIFORM_SPECULAR_COMPONENT] = glGetUniformLocation(_programBoth, "specularComponent");
    
    // Load in and set texture
    /* use setupTexture to create crate texture */
    bothTexture = [self setupTexture:@"both.jpg"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, bothTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    
    
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_programLeft, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_programLeft, "normalMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_programLeft, "modelViewMatrix");
    /* more needed here... */
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_programLeft, "texture");
    uniforms[UNIFORM_FLASHLIGHT_POSITION] = glGetUniformLocation(_programLeft, "flashlightPosition");
    uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION] = glGetUniformLocation(_programLeft, "diffuseLightPosition");
    uniforms[UNIFORM_SHININESS] = glGetUniformLocation(_programLeft, "shininess");
    uniforms[UNIFORM_AMBIENT_COMPONENT] = glGetUniformLocation(_programLeft, "ambientComponent");
    uniforms[UNIFORM_DIFFUSE_COMPONENT] = glGetUniformLocation(_programLeft, "diffuseComponent");
    uniforms[UNIFORM_SPECULAR_COMPONENT] = glGetUniformLocation(_programLeft, "specularComponent");
    
    // Load in and set texture
    /* use setupTexture to create crate texture */
    leftTexture = [self setupTexture:@"left.jpg"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, leftTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    
    
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_programRight, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_programRight, "normalMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_programRight, "modelViewMatrix");
    /* more needed here... */
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_programRight, "texture");
    uniforms[UNIFORM_FLASHLIGHT_POSITION] = glGetUniformLocation(_programRight, "flashlightPosition");
    uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION] = glGetUniformLocation(_programRight, "diffuseLightPosition");
    uniforms[UNIFORM_SHININESS] = glGetUniformLocation(_programRight, "shininess");
    uniforms[UNIFORM_AMBIENT_COMPONENT] = glGetUniformLocation(_programRight, "ambientComponent");
    uniforms[UNIFORM_DIFFUSE_COMPONENT] = glGetUniformLocation(_programRight, "diffuseComponent");
    uniforms[UNIFORM_SPECULAR_COMPONENT] = glGetUniformLocation(_programRight, "specularComponent");
    
    // Load in and set texture
    /* use setupTexture to create crate texture */
    rightTexture = [self setupTexture:@"right.jpg"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, rightTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    
    
    // Set up lighting parameters
    /* set values, e.g., flashlightPosition = GLKVector3Make(0.0, 0.0, 1.0); */
    flashlightPosition = GLKVector3Make(0.0, 0.0, 1.0);
    diffuseLightPosition = GLKVector3Make(0.0, 1.0, 0.0);
    diffuseComponent = GLKVector4Make(0.8, 0.1, 0.1, 1.0);
    shininess = 200.0;
    specularComponent = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    ambientComponent = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
    
    
    
    
    
    
    
    // Initialize GL and get buffers
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_floor2VertexArray);
    glBindVertexArrayOES(_floor2VertexArray);
    
    glGenBuffers(3, _floorVertexBuffers);
    glGenBuffers(1, &_floorIndexBuffer);
    
    // Generate vertices
    int floorNumVerts;
    //numIndices = generateSphere(50, 1, &vertices, &normals, &texCoords, &indices, &numVerts);
    floorNumIndices = generateFloor(1.5, &floorVertices, &floorNormals, &floorTexCoords, &floorIndices, &floorNumVerts);
    
    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _floorVertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*floorNumVerts, floorVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _floorVertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*floorNumVerts, floorNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _floorVertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*floorNumVerts, floorTexCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _floorIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*floorNumIndices, floorIndices, GL_STATIC_DRAW);
    
    //----------------------------------------------
    glGenVertexArraysOES(1, &_wallNorth2VertexArray);
    glBindVertexArrayOES(_wallNorth2VertexArray);
    
    glGenBuffers(3, _wallNorthVertexBuffers);
    glGenBuffers(1, &_wallNorthIndexBuffer);
    
    // Generate vertices
    int wallNorthNumVerts;
    //numIndices = generateSphere(50, 1, &vertices, &normals, &texCoords, &indices, &numVerts);
    wallNorthNumIndices = generateNorthWall(1.5, &wallNorthVertices, &wallNorthNormals, &wallNorthTexCoords, &wallNorthIndices, &wallNorthNumVerts);
    
    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _wallNorthVertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallNorthNumVerts, wallNorthVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _wallNorthVertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallNorthNumVerts, wallNorthNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _wallNorthVertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallNorthNumVerts, wallNorthTexCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wallNorthIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*wallNorthNumIndices, wallNorthIndices, GL_STATIC_DRAW);
    //--------------------------------------------------------------
    //----------------------------------------------
    glGenVertexArraysOES(1, &_wallSouth2VertexArray);
    glBindVertexArrayOES(_wallSouth2VertexArray);
    
    glGenBuffers(3, _wallSouthVertexBuffers);
    glGenBuffers(1, &_wallSouthIndexBuffer);
    
    // Generate vertices
    int wallSouthNumVerts;
    //numIndices = generateSphere(50, 1, &vertices, &normals, &texCoords, &indices, &numVerts);
    wallSouthNumIndices = generateSouthWall(1.5, &wallSouthVertices, &wallSouthNormals, &wallSouthTexCoords, &wallSouthIndices, &wallSouthNumVerts);
    
    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _wallSouthVertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallSouthNumVerts, wallSouthVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _wallSouthVertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallSouthNumVerts, wallSouthNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _wallSouthVertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallSouthNumVerts, wallSouthTexCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wallSouthIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*wallSouthNumIndices, wallSouthIndices, GL_STATIC_DRAW);
    //--------------------------------------------------------------
    //----------------------------------------------
    glGenVertexArraysOES(1, &_wallEast2VertexArray);
    glBindVertexArrayOES(_wallEast2VertexArray);
    
    glGenBuffers(3, _wallEastVertexBuffers);
    glGenBuffers(1, &_wallEastIndexBuffer);
    
    // Generate vertices
    int wallEastNumVerts;
    //numIndices = generateSphere(50, 1, &vertices, &normals, &texCoords, &indices, &numVerts);
    wallEastNumIndices = generateEastWall(1.5, &wallEastVertices, &wallEastNormals, &wallEastTexCoords, &wallEastIndices, &wallEastNumVerts);
    
    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _wallEastVertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallEastNumVerts, wallEastVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _wallEastVertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallEastNumVerts, wallEastNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _wallEastVertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallEastNumVerts, wallEastTexCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wallEastIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*wallEastNumIndices, wallEastIndices, GL_STATIC_DRAW);
    //--------------------------------------------------------------
    //----------------------------------------------
    glGenVertexArraysOES(1, &_wallWest2VertexArray);
    glBindVertexArrayOES(_wallWest2VertexArray);
    
    glGenBuffers(3, _wallWestVertexBuffers);
    glGenBuffers(1, &_wallWestIndexBuffer);
    
    // Generate vertices
    int wallWestNumVerts;
    //numIndices = generateSphere(50, 1, &vertices, &normals, &texCoords, &indices, &numVerts);
    wallWestNumIndices = generateWestWall(1.5, &wallWestVertices, &wallWestNormals, &wallWestTexCoords, &wallWestIndices, &wallWestNumVerts);
    
    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _wallWestVertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallWestNumVerts, wallWestVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _wallWestVertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallWestNumVerts, wallWestNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _wallWestVertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*wallWestNumVerts, wallWestTexCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wallWestIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*wallWestNumIndices, wallWestIndices, GL_STATIC_DRAW);
    //--------------------------------------------------------------
    //----------------------------------------------
    glGenVertexArraysOES(1, &_cube2VertexArray);
    glBindVertexArrayOES(_cube2VertexArray);
    
    glGenBuffers(3, _cubeVertexBuffers);
    glGenBuffers(1, &_cubeIndexBuffer);
    
    // Generate vertices
    int cubeNumVerts;
    //numIndices = generateSphere(50, 1, &vertices, &normals, &texCoords, &indices, &numVerts);
    cubeNumIndices = generateCube(1.5, &cubeVertices, &cubeNormals, &cubeTexCoords, &cubeIndices, &cubeNumVerts);
    

    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _cubeVertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*cubeNumVerts, cubeVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _cubeVertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*cubeNumVerts, cubeNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _cubeVertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*cubeNumVerts, cubeTexCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _cubeIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*cubeNumIndices, cubeIndices, GL_STATIC_DRAW);
    //--------------------------------------------------------------
    //----------------------------------------------
    glGenVertexArraysOES(1, &_enemyVertexArray);
    glBindVertexArrayOES(_enemyVertexArray);
    
    glGenBuffers(3, _enemyVertexBuffers);
    glGenBuffers(1, &_enemyIndexBuffer);
    
    // Generate vertices
    int enemyNumVerts;
    
    enemyNumIndices = generateCustom(0.5, &enemyVertices, &enemyNormals, &enemyIndices, &enemyNormIndices, &enemyNumVerts, @"monkey");
    
    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _enemyVertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*enemyNumVerts, enemyVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _enemyVertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*enemyNumVerts, enemyNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
//    glBindBuffer(GL_ARRAY_BUFFER, _enemyVertexBuffers[2]);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*enemyNumVerts, enemyTexCoords, GL_STATIC_DRAW);
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _enemyIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*enemyNumIndices, enemyIndices, GL_STATIC_DRAW);
    
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _enemyIndexBuffer[1]);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*enemyNumIndices, enemyNormIndices, GL_STATIC_DRAW);
    //--------------------------------------------------------------
    
    //my added setup. usure of
    glGenVertexArraysOES(1, &_floorVertexArray);
    glBindVertexArrayOES(_floorVertexArray);
    
    glGenBuffers(1, &_floorVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _floorVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(floorVertexData), floorVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    //end of my added setup
    
    //-----------------Setup wall vertex stuff
    glGenVertexArraysOES(1, &_wallWestVertexArray);
    glBindVertexArrayOES(_wallWestVertexArray);
    
    glGenBuffers(1, &_wallWestVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _wallWestVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(wallWestVertexData), wallWestVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glGenVertexArraysOES(1, &_wallEastVertexArray);
    glBindVertexArrayOES(_wallEastVertexArray);
    
    glGenBuffers(1, &_wallEastVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _wallEastVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(wallEastVertexData), wallEastVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glGenVertexArraysOES(1, &_wallNorthVertexArray);
    glBindVertexArrayOES(_wallNorthVertexArray);
    
    glGenBuffers(1, &_wallNorthVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _wallNorthVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(wallNorthVertexData), wallNorthVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glGenVertexArraysOES(1, &_wallSouthVertexArray);
    glBindVertexArrayOES(_wallSouthVertexArray);
    
    glGenBuffers(1, &_wallSouthVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _wallSouthVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(wallSouthVertexData), wallSouthVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    //----------------end of wall setup
    
    glBindVertexArrayOES(0);
    
    
}


int generateFloor(float scale, GLfloat **vertices, GLfloat **normals,
                 GLfloat **texCoords, GLuint **indices, int *numVerts)
{
    int i;
    int numVertices = 24;
    int numIndices = 6;
    
    GLfloat cubeVerts[] =
    {
        -0.5f, -0.0f, -0.5f,
        -0.5f, -0.0f,  0.5f,
        0.5f, -0.0f,  0.5f,
        0.5f, -0.0f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f,  0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, 0.5f,
        -0.5f,  0.5f, 0.5f,
        0.5f,  0.5f, 0.5f,
        0.5f, -0.5f, 0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f, -0.5f,
    };
    
    GLfloat cubeNormals[] =
    {
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
    };
    
    GLfloat cubeTex[] =
    {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    // Allocate memory for buffers
    if ( vertices != NULL )
    {
        *vertices = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *vertices, cubeVerts, sizeof ( cubeVerts ) );
        
        for ( i = 0; i < numVertices * 3; i++ )
        {
            ( *vertices ) [i] *= scale;
        }
    }
    
    if ( normals != NULL )
    {
        *normals = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *normals, cubeNormals, sizeof ( cubeNormals ) );
    }
    
    if ( texCoords != NULL )
    {
        *texCoords = malloc ( sizeof ( GLfloat ) * 2 * numVertices );
        memcpy ( *texCoords, cubeTex, sizeof ( cubeTex ) ) ;
    }
    
    
    // Generate the indices
    if ( indices != NULL )
    {
        GLuint cubeIndices[] =
        {
            0, 2, 1,
            0, 3, 2//,
//            4, 5, 6,
//            4, 6, 7,
//            8, 9, 10,
//            8, 10, 11,
//            12, 15, 14,
//            12, 14, 13,
//            16, 17, 18,
//            16, 18, 19,
//            20, 23, 22,
//            20, 22, 21
        };
        
        *indices = malloc ( sizeof ( GLuint ) * numIndices );
        memcpy ( *indices, cubeIndices, sizeof ( cubeIndices ) );
    }
    
    if (numVerts != NULL)
        *numVerts = numVertices;
    return numIndices;
}


int generateNorthWall(float scale, GLfloat **vertices, GLfloat **normals,
                  GLfloat **texCoords, GLuint **indices, int *numVerts)
{
    
    int i;
    int numVertices = 24;
    int numIndices = 6;
    //-4.6f
//    GLfloat cubeVerts[]= {
//        -0.5f, -0.5f, -4.8f,
//        -0.5f, -0.5f,  -4.8f,
//        0.5f, -0.5f,  -4.8f,
//        0.5f, -0.5f, -4.8f,
//        -0.5f,  0.5f, -4.8f,
//        -0.5f,  0.5f,  -4.8f,
//        0.5f,  0.5f,  -4.8f,
//        0.5f,  0.5f, -4.8f,
//        -0.5f, -0.5f, -4.8f,
//        -0.5f,  0.5f, -4.8f,
//        0.5f,  0.5f, -4.8f,
//        0.5f, -0.5f, -4.8f,
//        -0.5f, -0.5f, -4.8f,
//        -0.5f,  0.5f, -4.8f,
//        0.5f,  0.5f, -4.8f,
//        0.5f, -0.5f, -4.8f,
//        -0.5f, -0.5f, -4.8f,
//        -0.5f, -0.5f,  -4.8f,
//        -0.5f,  0.5f,  -4.8f,
//        -0.5f,  0.5f, -4.8f,
//        0.5f, -0.5f, -4.8f,
//        0.5f, -0.5f,  -4.8f,
//        0.5f,  0.5f,  -4.8f,
//        0.5f,  0.5f, -4.8f,
//    };
    GLfloat cubeVerts[] =
    {
        -0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f,  0.5f,
        0.5f, 0.0f,  0.5f,
        0.5f, 0.0f, -0.5f,
        -0.5f,  1.0f, -0.5f,
        -0.5f,  1.0f,  0.5f,
        0.5f,  1.0f,  0.5f,
        0.5f,  1.0f, -0.49f,
        -0.5f, 0.0f, -0.49f,
        -0.5f,  1.0f, -0.49f,
        0.5f,  1.0f, -0.49f,
        0.5f, 0.0f, -0.49f,
        -0.5f, 0.0f, 0.5f,
        -0.5f,  1.0f, 0.5f,
        0.5f,  1.0f, 0.5f,
        0.5f, 0.0f, 0.5f,
        -0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f,  0.5f,
        -0.5f,  1.0f,  0.5f,
        -0.5f,  1.0f, -0.5f,
        0.5f, 0.0f, -0.5f,
        0.5f, 0.0f,  0.5f,
        0.5f,  1.0f,  0.5f,
        0.5f,  1.0f, -0.5f,
    };

    
    GLfloat cubeNormals[] =
    {
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
    };
    
    GLfloat cubeTex[] =
    {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    // Allocate memory for buffers
    if ( vertices != NULL )
    {
        *vertices = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *vertices, cubeVerts, sizeof ( cubeVerts ) );
        
        for ( i = 0; i < numVertices * 3; i++ )
        {
            ( *vertices ) [i] *= scale;
        }
    }
    
    if ( normals != NULL )
    {
        *normals = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *normals, cubeNormals, sizeof ( cubeNormals ) );
    }
    
    if ( texCoords != NULL )
    {
        *texCoords = malloc ( sizeof ( GLfloat ) * 2 * numVertices );
        memcpy ( *texCoords, cubeTex, sizeof ( cubeTex ) ) ;
    }
    
    
    // Generate the indices
    if ( indices != NULL )
    {
        GLuint cubeIndices[] =
        {
            //0, 2, 1,
            //0, 3, 2,
            //4, 5, 6,
            //4, 6, 7,
            8, 9, 10,
            8, 10, 11//,
//            12, 15, 14,
//            12, 14, 13,
//            16, 17, 18,
//            16, 18, 19,
//            20, 23, 22,
//            20, 22, 21
        };
        
        *indices = malloc ( sizeof ( GLuint ) * numIndices );
        memcpy ( *indices, cubeIndices, sizeof ( cubeIndices ) );
    }
    
    if (numVerts != NULL)
        *numVerts = numVertices;
    return numIndices;
}

int generateSouthWall(float scale, GLfloat **vertices, GLfloat **normals,
                      GLfloat **texCoords, GLuint **indices, int *numVerts)
{
    
    int i;
    int numVertices = 24;
    int numIndices = 6;
    GLfloat cubeVerts[] =
    {
        -0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f,  0.5f,
        0.5f, 0.0f,  0.5f,
        0.5f, 0.0f, -0.5f,
        -0.5f,  1.0f, -0.5f,
        -0.5f,  1.0f,  0.5f,
        0.5f,  1.0f,  0.5f,
        0.5f,  1.0f, -0.5f,
        -0.5f, 0.0f, -0.5f,
        -0.5f,  1.0f, -0.5f,
        0.5f,  1.0f, -0.5f,
        0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f, 0.49f,
        -0.5f,  1.0f, 0.49f,
        0.5f,  1.0f, 0.49f,
        0.5f, 0.0f, 0.49f,
        -0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f,  0.5f,
        -0.5f,  1.0f,  0.5f,
        -0.5f,  1.0f, -0.5f,
        0.5f, 0.0f, -0.5f,
        0.5f, 0.0f,  0.5f,
        0.5f,  1.0f,  0.5f,
        0.5f,  1.0f, -0.5f,
    };
    
    
    GLfloat cubeNormals[] =
    {
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
    };
    
    GLfloat cubeTex[] =
    {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    // Allocate memory for buffers
    if ( vertices != NULL )
    {
        *vertices = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *vertices, cubeVerts, sizeof ( cubeVerts ) );
        
        for ( i = 0; i < numVertices * 3; i++ )
        {
            ( *vertices ) [i] *= scale;
        }
    }
    
    if ( normals != NULL )
    {
        *normals = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *normals, cubeNormals, sizeof ( cubeNormals ) );
    }
    
    if ( texCoords != NULL )
    {
        *texCoords = malloc ( sizeof ( GLfloat ) * 2 * numVertices );
        memcpy ( *texCoords, cubeTex, sizeof ( cubeTex ) ) ;
    }
    
    
    // Generate the indices
    if ( indices != NULL )
    {
        GLuint cubeIndices[] =
        {
            //0, 2, 1,
            //0, 3, 2,
            //4, 5, 6,
            //4, 6, 7,
            //8, 9, 10,
            //8, 10, 11//,
                        12, 15, 14,
                        12, 14, 13//,
            //            16, 17, 18,
            //            16, 18, 19,
            //            20, 23, 22,
            //            20, 22, 21
        };
        
        *indices = malloc ( sizeof ( GLuint ) * numIndices );
        memcpy ( *indices, cubeIndices, sizeof ( cubeIndices ) );
    }
    
    if (numVerts != NULL)
        *numVerts = numVertices;
    return numIndices;
}


int generateEastWall(float scale, GLfloat **vertices, GLfloat **normals,
                      GLfloat **texCoords, GLuint **indices, int *numVerts)
{
    
    int i;
    int numVertices = 24;
    int numIndices = 6;
    GLfloat cubeVerts[] =
    {
        -0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f,  0.5f,
        0.5f, 0.0f,  0.5f,
        0.5f, 0.0f, -0.5f,
        -0.5f,  1.0f, -0.5f,
        -0.5f,  1.0f,  0.5f,
        0.5f,  1.0f,  0.5f,
        0.5f,  1.0f, -0.5f,
        -0.5f, 0.0f, -0.5f,
        -0.5f,  1.0f, -0.5f,
        0.5f,  1.0f, -0.5f,
        0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f, 0.5f,
        -0.5f,  1.0f, 0.5f,
        0.5f,  1.0f, 0.5f,
        0.5f, 0.0f, 0.5f,
        -0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f,  0.5f,
        -0.5f,  1.0f,  0.5f,
        -0.5f,  1.0f, -0.5f,
        0.49f, 0.0f, -0.5f,
        0.49f, 0.0f,  0.5f,
        0.49f,  1.0f,  0.5f,
        0.49f,  1.0f, -0.5f,
    };
    
    
    GLfloat cubeNormals[] =
    {
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
    };
    
    GLfloat cubeTex[] =
    {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    // Allocate memory for buffers
    if ( vertices != NULL )
    {
        *vertices = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *vertices, cubeVerts, sizeof ( cubeVerts ) );
        
        for ( i = 0; i < numVertices * 3; i++ )
        {
            ( *vertices ) [i] *= scale;
        }
    }
    
    if ( normals != NULL )
    {
        *normals = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *normals, cubeNormals, sizeof ( cubeNormals ) );
    }
    
    if ( texCoords != NULL )
    {
        *texCoords = malloc ( sizeof ( GLfloat ) * 2 * numVertices );
        memcpy ( *texCoords, cubeTex, sizeof ( cubeTex ) ) ;
    }
    
    
    // Generate the indices
    if ( indices != NULL )
    {
        GLuint cubeIndices[] =
        {
            //0, 2, 1,
            //0, 3, 2,
            //4, 5, 6,
            //4, 6, 7,
            //8, 9, 10,
            //8, 10, 11//,
            //12, 15, 14,
            //12, 14, 13//,
            //            16, 17, 18,
            //            16, 18, 19,
                        20, 23, 22,
                        20, 22, 21
        };
        
        *indices = malloc ( sizeof ( GLuint ) * numIndices );
        memcpy ( *indices, cubeIndices, sizeof ( cubeIndices ) );
    }
    
    if (numVerts != NULL)
        *numVerts = numVertices;
    return numIndices;
}



int generateWestWall(float scale, GLfloat **vertices, GLfloat **normals,
                     GLfloat **texCoords, GLuint **indices, int *numVerts)
{
    
    int i;
    int numVertices = 24;
    int numIndices = 6;
    GLfloat cubeVerts[] =
    {
        -0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f,  0.5f,
        0.5f, 0.0f,  0.5f,
        0.5f, 0.0f, -0.5f,
        -0.5f,  1.0f, -0.5f,
        -0.5f,  1.0f,  0.5f,
        0.5f,  1.0f,  0.5f,
        0.5f,  1.0f, -0.5f,
        -0.5f, 0.0f, -0.5f,
        -0.5f,  1.0f, -0.5f,
        0.5f,  1.0f, -0.5f,
        0.5f, 0.0f, -0.5f,
        -0.5f, 0.0f, 0.5f,
        -0.5f,  1.0f, 0.5f,
        0.5f,  1.0f, 0.5f,
        0.5f, 0.0f, 0.5f,
        -0.49f, 0.0f, -0.5f,
        -0.49f, 0.0f,  0.5f,
        -0.49f,  1.0f,  0.5f,
        -0.49f,  1.0f, -0.5f,
        0.5f, 0.0f, -0.5f,
        0.5f, 0.0f,  0.5f,
        0.5f,  1.0f,  0.5f,
        0.5f,  1.0f, -0.5f,
    };
    
    
    GLfloat cubeNormals[] =
    {
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
    };
    
    GLfloat cubeTex[] =
    {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    // Allocate memory for buffers
    if ( vertices != NULL )
    {
        *vertices = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *vertices, cubeVerts, sizeof ( cubeVerts ) );
        
        for ( i = 0; i < numVertices * 3; i++ )
        {
            ( *vertices ) [i] *= scale;
        }
    }
    
    if ( normals != NULL )
    {
        *normals = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *normals, cubeNormals, sizeof ( cubeNormals ) );
    }
    
    if ( texCoords != NULL )
    {
        *texCoords = malloc ( sizeof ( GLfloat ) * 2 * numVertices );
        memcpy ( *texCoords, cubeTex, sizeof ( cubeTex ) ) ;
    }
    
    
    // Generate the indices
    if ( indices != NULL )
    {
        GLuint cubeIndices[] =
        {
            //0, 2, 1,
            //0, 3, 2,
            //4, 5, 6,
            //4, 6, 7,
            //8, 9, 10,
            //8, 10, 11//,
            //12, 15, 14,
            //12, 14, 13//,
                        16, 17, 18,
                        16, 18, 19//,
            //20, 23, 22,
            //20, 22, 21
        };
        
        *indices = malloc ( sizeof ( GLuint ) * numIndices );
        memcpy ( *indices, cubeIndices, sizeof ( cubeIndices ) );
    }
    
    if (numVerts != NULL)
        *numVerts = numVertices;
    return numIndices;
}

/*
    Generate custom VBO based on data loaded from file
 */
int generateCustom(float scale, GLfloat **vertices, GLfloat **normals, GLuint **indices, GLuint **normIndices, int *numVerts, NSString *fileName)
{
    NSMutableArray *vertexMutArray;
    NSMutableArray *normalMutArray;
    NSMutableArray *indexMutArray;
    NSMutableArray *indexNormMutArray;
    
    //expandable array for holding the vertex data
    vertexMutArray = [NSMutableArray array];
    normalMutArray = [NSMutableArray array];
    indexMutArray = [NSMutableArray array];
    indexNormMutArray = [NSMutableArray array];
    
    //read file and save data into passed mutable arrays.
    readObjFile(fileName, vertexMutArray, normalMutArray, indexMutArray, indexNormMutArray);
    
    GLfloat *cubeVerts;
    GLfloat *cubeNormals;
   
    int i;
    //int numVertices = sizeof(cubeVerts)/sizeof(GLfloat);
    int numVertices = [vertexMutArray count];
    int numNormals = [normalMutArray count];
    //bad lazy coding. dont want to go through removing *3 from earlier code
    //numVerts = numVertices/3;
    int numIndices = [indexMutArray count];
    
    NSLog(@"Num Vertices: %d",numVertices);
    
    //number formatter for pulling data from file string
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    
    // Allocate memory for buffers
    /*
        Create vertex array
     */
    if ( vertices != NULL )
    {
        *vertices = malloc ( sizeof ( GLfloat ) * numVertices );
        //memcpy ( *vertices, cubeVerts, sizeof ( cubeVerts ) );
        
        for ( i = 0; i < numVertices; i++ )
        {
            NSString *currentVertString = [vertexMutArray objectAtIndex:i];
            //( *vertices ) [i] = [[formatter numberFromString:currentVertString] floatValue];
            float currentVertFloat = [currentVertString floatValue];
            ( *vertices ) [i] = currentVertFloat;
            ( *vertices ) [i] *= scale;
            //NSLog(@"%.4f", (*vertices)[i]);
        }
    }
    
    /*
        Create normal array
     */
    if ( normals != NULL )
    {
        *normals = malloc ( sizeof ( GLfloat ) * numNormals );
        //memcpy ( *normals, cubeNormals, sizeof ( cubeNormals ) );
        for ( i = 0; i < numNormals; i++ )
        {
            NSString *currentNormString = [normalMutArray objectAtIndex:i];
            //( *vertices ) [i] = [[formatter numberFromString:currentVertString] floatValue];
            float currentNormFloat = [currentNormString floatValue];
            ( *normals ) [i] = currentNormFloat;
            ( *normals ) [i] *= scale;
            //NSLog(@"%.4f", (*vertices)[i]);
        }
    }
    
//    if ( texCoords != NULL )
//    {
//        *texCoords = malloc ( sizeof ( GLfloat ) * 2 * numVertices );
//        memcpy ( *texCoords, cubeTex, sizeof ( cubeTex ) ) ;
//    }
    
    
    // Generate the indices
    if ( indices != NULL )
    {
        *indices = malloc ( sizeof ( GLuint ) * numIndices );
        //memcpy ( *indices, cubeIndices, sizeof ( cubeIndices ) );
        for ( i = 0; i < numNormals; i++ )
        {
            NSString *currentIndexString = [indexMutArray objectAtIndex:i];
            //( *vertices ) [i] = [[formatter numberFromString:currentVertString] floatValue];
            int currentIndexInt = [currentIndexString intValue];
            ( *indices ) [i] = currentIndexInt;
            //NSLog(@"%.4f", (*vertices)[i]);
        }
    }
    
    // Generate the indices
    if ( normIndices != NULL )
    {
        *normIndices = malloc ( sizeof ( GLuint ) * numIndices );
        //memcpy ( *indices, cubeIndices, sizeof ( cubeIndices ) );
        for ( i = 0; i < numNormals; i++ )
        {
            NSString *currentIndexString = [indexNormMutArray objectAtIndex:i];
            //( *vertices ) [i] = [[formatter numberFromString:currentVertString] floatValue];
            int currentIndexInt = [currentIndexString intValue];
            ( *normIndices ) [i] = currentIndexInt;
            //NSLog(@"%.4f", (*vertices)[i]);
        }
    }
    
    if (numVerts != NULL)
        *numVerts = numVertices/3;
    return numIndices;
}


int generateCube(float scale, GLfloat **vertices, GLfloat **normals,
                 GLfloat **texCoords, GLuint **indices, int *numVerts)
{
    int i;
    int numVertices = 24;
    int numIndices = 36;
    
    GLfloat cubeVerts[] =
    {
        -0.25f, -0.25f, -0.25f,
        -0.25f, -0.25f,  0.25f,
        0.25f, -0.25f,  0.25f,
        0.25f, -0.25f, -0.25f,
        -0.25f,  0.25f, -0.25f,
        -0.25f,  0.25f,  0.25f,
        0.25f,  0.25f,  0.25f,
        0.25f,  0.25f, -0.25f,
        -0.25f, -0.25f, -0.25f,
        -0.25f,  0.25f, -0.25f,
        0.25f,  0.25f, -0.25f,
        0.25f, -0.25f, -0.25f,
        -0.25f, -0.25f, 0.25f,
        -0.25f,  0.25f, 0.25f,
        0.25f,  0.25f, 0.25f,
        0.25f, -0.25f, 0.25f,
        -0.25f, -0.25f, -0.25f,
        -0.25f, -0.25f,  0.25f,
        -0.25f,  0.25f,  0.25f,
        -0.25f,  0.25f, -0.25f,
        0.25f, -0.25f, -0.25f,
        0.25f, -0.25f,  0.25f,
        0.25f,  0.25f,  0.25f,
        0.25f,  0.25f, -0.25f,
    };
    
    GLfloat cubeNormals[] =
    {
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
    };
    
    GLfloat cubeTex[] =
    {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    // Allocate memory for buffers
    if ( vertices != NULL )
    {
        *vertices = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *vertices, cubeVerts, sizeof ( cubeVerts ) );
        
        for ( i = 0; i < numVertices * 3; i++ )
        {
            ( *vertices ) [i] *= scale;
        }
    }
    
    if ( normals != NULL )
    {
        *normals = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *normals, cubeNormals, sizeof ( cubeNormals ) );
    }
    
    if ( texCoords != NULL )
    {
        *texCoords = malloc ( sizeof ( GLfloat ) * 2 * numVertices );
        memcpy ( *texCoords, cubeTex, sizeof ( cubeTex ) ) ;
    }
    
    
    // Generate the indices
    if ( indices != NULL )
    {
        GLuint cubeIndices[] =
        {
            0, 2, 1,
            0, 3, 2,
            4, 5, 6,
            4, 6, 7,
            8, 9, 10,
            8, 10, 11,
            12, 15, 14,
            12, 14, 13,
            16, 17, 18,
            16, 18, 19,
            20, 23, 22,
            20, 22, 21
        };
        
        *indices = malloc ( sizeof ( GLuint ) * numIndices );
        memcpy ( *indices, cubeIndices, sizeof ( cubeIndices ) );
    }
    
    if (numVerts != NULL)
        *numVerts = numVertices;
    return numIndices;
}





-(void)generateTexStuff:(GLfloat **)textureCoords{
    int numVertices = 24;
    
    if ( textureCoords != NULL )
    {
        *textureCoords = malloc ( sizeof ( GLfloat ) * 2 * numVertices );
        memcpy ( *textureCoords, cubeTex, sizeof ( cubeTex ) ) ;
    }
}

//cleanup buffer
- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_floor2VertexBuffer);
    glDeleteVertexArraysOES(1, &_floor2VertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(80.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    //------view matrices
    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -0.0f);
    viewMatrix = GLKMatrix4Rotate(viewMatrix, M_PI/10, 1.0f, 0.0f, 0.0f);
    viewMatrix = GLKMatrix4Rotate(viewMatrix, _totalRotationHori+_touchHoriRotation, 0.0f, 1.0f, 0.0f);
    //NSLog(@"%f", (_totalRotationHori+_touchHoriRotation));
    
    viewMatrix = GLKMatrix4Translate(viewMatrix, _playerXpos, -3.25f, -_playerYpos-10);
    //------end of view matrices
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f/2, -4.0f);
    GLKMatrix4 baseModelViewRotationMatrix = GLKMatrix4Rotate(baseModelViewMatrix, 45, 0.0f, 0.0f, 1.0f);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    GLKMatrix4 floorModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // Compute the model view matrix for the object rendered with ES2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewRotationMatrix, modelViewMatrix);
    
    //my floor matrices
    floorModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    floorModelViewMatrix = GLKMatrix4Rotate(floorModelViewMatrix, -_rotation, 1.0f, 1.0f, 1.0f);
    floorModelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, floorModelViewMatrix);
    floorModelViewMatrix = GLKMatrix4Multiply(viewMatrix, floorModelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _floorNormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(floorModelViewMatrix), NULL);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    _floorModelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, floorModelViewMatrix);
    
    
    //------------cube matrix
    GLKMatrix4 cubecurrentFloorModelViewMatrix =GLKMatrix4MakeTranslation(0, 5.0f, 0.0f);
    
    //cubecurrentFloorModelViewMatrix = GLKMatrix4Rotate(cubecurrentFloorModelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    cubecurrentFloorModelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, cubecurrentFloorModelViewMatrix);
    cubecurrentFloorModelViewMatrix = GLKMatrix4Multiply(viewMatrix, cubecurrentFloorModelViewMatrix);
    cubecurrentFloorModelViewMatrix = GLKMatrix4Scale(cubecurrentFloorModelViewMatrix, 10, 10, 10);
    
    GLKMatrix4 currentModelViewProjMatrix = GLKMatrix4Multiply(projectionMatrix, cubecurrentFloorModelViewMatrix);
    cubeNormMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(cubecurrentFloorModelViewMatrix), NULL);
    cubeMatrix = currentModelViewProjMatrix;
    //-----------------------
    
    //------------enemy matrix
    GLKMatrix4 enemyModelViewMatrix =GLKMatrix4MakeTranslation(enemyxPos-7, 0.0f, enemyzPos-7);
    
    GLfloat enemyDirectionRotation=0;
    GLfloat enemyMoveAmount = 0;
    GLuint currentxTile = enemyxPos/15;
    int currentzTile = floorf(enemyzPos/15);
    NSLog(@"currentz:%d",currentzTile);
    //NSLog(@"position %d,%d", currentxTile, currentzTile);
    //NSLog(@"south wal:%d,North:%d", [mazeConnector hasWallAt:NORTH_WALL row:-1*(currentzTile-1) coloumn:currentxTile],[mazeConnector hasWallAt:SOUTH_WALL row:-1*(currentzTile-1) coloumn:currentxTile]);
    
    GLuint hitboxDist = 2;
    
    /*
        Move enemy and check for wall collisions
        if wall collision turn in random direction
     */
    switch (enemyDirection) {
        case NORTH_DIRECTION:
            enemyDirectionRotation=M_PI;
            enemyMoveAmount=-enemySpeed*self.timeSinceLastUpdate;
            if(([mazeConnector hasWallAt:SOUTH_WALL row:-1*(currentzTile) coloumn:currentxTile]&&enemyzPos+enemyMoveAmount<(currentzTile)*15)||enemyzPos+enemyMoveAmount>mazeSize*15)
                enemyDirection = arc4random_uniform(4);
            else
                enemyzPos+=enemyMoveAmount;
            break;
        case SOUTH_DIRECTION:
            enemyDirectionRotation=0;
            enemyMoveAmount=enemySpeed*self.timeSinceLastUpdate;
            if(([mazeConnector hasWallAt:NORTH_WALL row:-1*(currentzTile) coloumn:currentxTile]&&enemyzPos+enemyMoveAmount>=currentzTile*15+15-hitboxDist)||enemyzPos+enemyMoveAmount>=15)
                enemyDirection = arc4random_uniform(4);
            else
                enemyzPos+=enemyMoveAmount;
            break;
        case WEST_DIRECTION:
            enemyDirectionRotation=M_PI*1.5;
            enemyMoveAmount=-enemySpeed*self.timeSinceLastUpdate;
            if([mazeConnector hasWallAt:EAST_WALL row:-1*currentzTile coloumn:currentxTile]&&enemyxPos+enemyMoveAmount<currentxTile*15+hitboxDist)
                enemyDirection = arc4random_uniform(4);
            else
                enemyxPos+=enemyMoveAmount;
            break;
        case EAST_DIRECTION:
            enemyDirectionRotation=M_PI/2;
            enemyMoveAmount=enemySpeed*self.timeSinceLastUpdate;
            if([mazeConnector hasWallAt:WEST_WALL row:-1*currentzTile coloumn:currentxTile]&&enemyxPos+enemyMoveAmount>currentxTile*15+15-hitboxDist)
                enemyDirection = arc4random_uniform(4);
            else
                enemyxPos+=enemyMoveAmount;
            break;
            
        default:
            enemyDirectionRotation=0;
            break;
    }
    enemyModelViewMatrix = GLKMatrix4Rotate(enemyModelViewMatrix, enemyDirectionRotation, 0.0f, 1.0f, 0.0f);
    enemyModelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, enemyModelViewMatrix);
    enemyModelViewMatrix = GLKMatrix4Multiply(viewMatrix, enemyModelViewMatrix);
    enemyModelViewMatrix = GLKMatrix4Scale(enemyModelViewMatrix, 5, 5, 5);
    
    GLKMatrix4 currentEnemyModelViewProjMatrix = GLKMatrix4Multiply(projectionMatrix, enemyModelViewMatrix);
    enemyNormMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(enemyModelViewMatrix), NULL);
    enemyMatrix = currentEnemyModelViewProjMatrix;
    //-----------------------
    
    
    //setup floor matrices
    for(int i=0; i<mazeSize; i++){
        for(int j=0; j<mazeSize; j++){
            //-----Floors-----
            GLKMatrix4 currentFloorModelViewMatrix =GLKMatrix4MakeTranslation((j)*15, -0.5f, -i*15);
        
            currentFloorModelViewMatrix = GLKMatrix4Rotate(currentFloorModelViewMatrix, 0, 1.0f, 1.0f, 1.0f);
            currentFloorModelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, currentFloorModelViewMatrix);
            currentFloorModelViewMatrix = GLKMatrix4Multiply(viewMatrix, currentFloorModelViewMatrix);
            currentFloorModelViewMatrix = GLKMatrix4Scale(currentFloorModelViewMatrix, 10, 10, 10);
        
            GLKMatrix4 currentModelViewProjMatrix = GLKMatrix4Multiply(projectionMatrix, currentFloorModelViewMatrix);
            floorNormMatrices[i*mazeSize+j] = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(currentFloorModelViewMatrix), NULL);
            floorMatrices[i*mazeSize+j] = currentModelViewProjMatrix;
            
        }
    }
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(_program);
   
    
    glBindTexture(GL_TEXTURE_2D, crateTexture);
    
//    // Select VAO and shaders
//    glBindVertexArrayOES(_cube2VertexArray);
//    glUseProgram(_program);
//    
//    // Set up uniforms
//    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, cubeMatrix.m);
//    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, cubeNormMatrix.m);
//    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, cubeMatrix.m);
//    
//    // Select VBO and draw
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _cubeIndexBuffer);
//    glDrawElements(GL_TRIANGLES, cubeNumIndices, GL_UNSIGNED_INT, 0);
    
    //-----------------------DRAW ENEMY
    // Select VAO and shaders
    glBindVertexArrayOES(_enemyVertexArray);
    glUseProgram(_program);
    
    // Set up uniforms
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, enemyMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, enemyNormMatrix.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, enemyMatrix.m);
    
    // Select VBO and draw
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _enemyIndexBuffer);
    glDrawElements(GL_TRIANGLES, enemyNumIndices, GL_UNSIGNED_INT, 0);
    //------------------------
    
    
    for(int i=0; i<mazeSize; i++){
        for(int j=0; j<mazeSize; j++){
            //set texture for the floor
            glBindTexture(GL_TEXTURE_2D, crateTexture);
            
            glBindVertexArrayOES(_floorVertexArray);
            
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, floorNormMatrices[i*mazeSize+j].m);
            
            //glDrawArrays(GL_TRIANGLES, 0, 36);
            
            // Select VAO and shaders
            glBindVertexArrayOES(_floor2VertexArray);
            glUseProgram(_program);
            
            // Set up uniforms
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, floorNormMatrices[i*mazeSize+j].m);
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
            
            // Select VBO and draw
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _floorIndexBuffer);
            glDrawElements(GL_TRIANGLES, floorNumIndices, GL_UNSIGNED_INT, 0);
            
            
            
            for(int wallside=0; wallside<4; wallside++){
                if([mazeConnector hasWallAt:wallside row:i coloumn:j]){
                    switch(wallside){
                        case EAST_WALL:
                            [self chooseTexture:EAST_WALL row:i col:j];
                            
                            // Select VAO and shaders
                            glBindVertexArrayOES(_wallWest2VertexArray);
                            glUseProgram(_program);
                            
                            // Set up uniforms
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
                            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, floorNormMatrices[i*mazeSize+j].m);
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
                            
                            // Select VBO and draw
                            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wallWestIndexBuffer);
                            glDrawElements(GL_TRIANGLES, wallWestNumIndices, GL_UNSIGNED_INT, 0);
                            break;
                        case WEST_WALL:
                            [self chooseTexture:WEST_WALL row:i col:j];
                            
                            // Select VAO and shaders
                            glBindVertexArrayOES(_wallEast2VertexArray);
                            glUseProgram(_program);
                            
                            // Set up uniforms
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
                            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, floorNormMatrices[i*mazeSize+j].m);
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
                            
                            // Select VBO and draw
                            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wallEastIndexBuffer);
                            glDrawElements(GL_TRIANGLES, wallEastNumIndices, GL_UNSIGNED_INT, 0);
                            
                            break;
                        case SOUTH_WALL:
                            [self chooseTexture:SOUTH_WALL row:i col:j];
                            
                            // Select VAO and shaders
                            glBindVertexArrayOES(_wallNorth2VertexArray);
                            glUseProgram(_program);
                            
                            // Set up uniforms
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
                            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, floorNormMatrices[i*mazeSize+j].m);
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
                            
                            // Select VBO and draw
                            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wallNorthIndexBuffer);
                            glDrawElements(GL_TRIANGLES, wallNorthNumIndices, GL_UNSIGNED_INT, 0);
                            break;
                        case NORTH_WALL:
                            [self chooseTexture:NORTH_WALL row:i col:j];
                            
                            // Select VAO and shaders
                            glBindVertexArrayOES(_wallSouth2VertexArray);
                            glUseProgram(_program);
                            
                            // Set up uniforms
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
                            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, floorNormMatrices[i*mazeSize+j].m);
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, floorMatrices[i*mazeSize+j].m);
                            
                            // Select VBO and draw
                            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wallSouthIndexBuffer);
                            glDrawElements(GL_TRIANGLES, wallSouthNumIndices, GL_UNSIGNED_INT, 0);
                            
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }
    /* set lighting parameters... */
    glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
    glUniform3fv(uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION], 1, diffuseLightPosition.v);
    glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
    glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
    glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
    glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
    
}

//- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
-(void) chooseTexture:(int)side row:(int)row col:(int)col{

    switch(side){
        case EAST_WALL://west
            if([mazeConnector hasWallAt:SOUTH_WALL row:row coloumn:col]){
                if([mazeConnector hasWallAt:NORTH_WALL row:row coloumn:col]){
                    glBindTexture(GL_TEXTURE_2D, blockedTexture);
                }else{
                    glBindTexture(GL_TEXTURE_2D, leftTexture);
                }
            }else{
                if([mazeConnector hasWallAt:NORTH_WALL row:row coloumn:col]){
                    glBindTexture(GL_TEXTURE_2D, rightTexture);
                }else{
                    glBindTexture(GL_TEXTURE_2D, bothTexture);
                }
            }
            break;
        case WEST_WALL://east
            if([mazeConnector hasWallAt:SOUTH_WALL row:row coloumn:col]){
                if([mazeConnector hasWallAt:NORTH_WALL row:row coloumn:col]){
                    glBindTexture(GL_TEXTURE_2D, blockedTexture);
                }else{
                    glBindTexture(GL_TEXTURE_2D, rightTexture);
                }
            }else{
                if([mazeConnector hasWallAt:NORTH_WALL row:row coloumn:col]){
                    glBindTexture(GL_TEXTURE_2D, leftTexture);
                }else{
                    glBindTexture(GL_TEXTURE_2D, bothTexture);
                }
            }
            break;
        case SOUTH_WALL://north
            if([mazeConnector hasWallAt:EAST_WALL row:row coloumn:col]){
                if([mazeConnector hasWallAt:WEST_WALL row:row coloumn:col]){
                    glBindTexture(GL_TEXTURE_2D, blockedTexture);
                }else{
                    glBindTexture(GL_TEXTURE_2D, rightTexture);
                }
            }else{
                if([mazeConnector hasWallAt:WEST_WALL row:row coloumn:col]){
                    glBindTexture(GL_TEXTURE_2D, leftTexture);
                }else{
                    glBindTexture(GL_TEXTURE_2D, bothTexture);
                }
            }
            break;
        case NORTH_WALL://south
            if([mazeConnector hasWallAt:EAST_WALL row:row coloumn:col]){
                if([mazeConnector hasWallAt:WEST_WALL row:row coloumn:col]){
                    glBindTexture(GL_TEXTURE_2D, blockedTexture);
                }else{
                    glBindTexture(GL_TEXTURE_2D, leftTexture);
                }
            }else{
                if([mazeConnector hasWallAt:WEST_WALL row:row coloumn:col]){
                    glBindTexture(GL_TEXTURE_2D, rightTexture);
                }else{
                    glBindTexture(GL_TEXTURE_2D, bothTexture);
                }
            }
            break;
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    _programBlocked= glCreateProgram();
    _programBoth= glCreateProgram();
    _programLeft= glCreateProgram();
    _programRight= glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    glAttachShader(_programBlocked, vertShader);
    glAttachShader(_programBoth, vertShader);
    glAttachShader(_programLeft, vertShader);
    glAttachShader(_programRight, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    glAttachShader(_programBlocked, fragShader);
    glAttachShader(_programBoth, fragShader);
    glAttachShader(_programLeft, fragShader);
    glAttachShader(_programRight, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "texCoordIn");
    
    glBindAttribLocation(_programBlocked, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_programBlocked, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_programBlocked, GLKVertexAttribTexCoord0, "texCoordIn");
    
    glBindAttribLocation(_programBoth, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_programBoth, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_programBoth, GLKVertexAttribTexCoord0, "texCoordIn");
    
    glBindAttribLocation(_programLeft, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_programLeft, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_programLeft, GLKVertexAttribTexCoord0, "texCoordIn");
    
    glBindAttribLocation(_programRight, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_programRight, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_programRight, GLKVertexAttribTexCoord0, "texCoordIn");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    if (![self linkProgram:_programBlocked]) {
        NSLog(@"Failed to link program: %f", _programBlocked);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_programBlocked) {
            glDeleteProgram(_programBlocked);
            _programBlocked = 0;
        }
        
        return NO;
    }
    if (![self linkProgram:_programBoth]) {
        NSLog(@"Failed to link program: %f", _programBoth);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_programBoth) {
            glDeleteProgram(_programBoth);
            _programBoth = 0;
        }
        
        return NO;
    }
    if (![self linkProgram:_programLeft]) {
        NSLog(@"Failed to link program: %f", _programLeft);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_programLeft) {
            glDeleteProgram(_programLeft);
            _programLeft = 0;
        }
        
        return NO;
    }
    if (![self linkProgram:_programRight]) {
        NSLog(@"Failed to link program: %f", _programRight);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_programRight) {
            glDeleteProgram(_programRight);
            _programRight = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDetachShader(_programBlocked, vertShader);
        glDetachShader(_programBoth, vertShader);
        glDetachShader(_programLeft, vertShader);
        glDetachShader(_programRight, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDetachShader(_programBlocked, fragShader);
        glDetachShader(_programBoth, fragShader);
        glDetachShader(_programLeft, fragShader);
        glDetachShader(_programRight, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}


- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


// Load in and set up texture image (adapted from Ray Wenderlich)
- (GLuint)setupTexture:(NSString *)fileName
{
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _previousRotVert =0;
    
    NSArray *allTouches = [touches allObjects];
    NSUInteger count = [allTouches count];
    
    if(count==2)
    {
        UITouch *touch1, *touch2;
        NSSet *allTouches = [event allTouches];
        touch1 = [[allTouches allObjects] objectAtIndex:0];
        touch2 = [[allTouches allObjects] objectAtIndex:1];
        
        _touchZoomStartPoint1 = [touch1 locationInView:self.view];
        _touchZoomStartPoint2 = [touch2 locationInView:self.view];
    }
    
    if(count==1){
        UITouch *touch = [[event allTouches] anyObject];
        
        _touchStartPoint =[touch locationInView:self.view];
        
        
        if (touch.tapCount == 2) {
            //This will cancel the singleTap action
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
    }
    
    if(!_rotating){
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *allTouches = [touches allObjects];
    NSUInteger count = [allTouches count];
    
    
    
    if(count==1){
        UITouch *touch = [touches anyObject];
        
        _touchEndPoint = [touch locationInView:self.view];
        
        if(!_rotating)
        {
            _touchHoriRotation = (_touchEndPoint.x-_touchStartPoint.x)/100;
            _touchVertRotation = (_touchEndPoint.y-_touchStartPoint.y)/100;
            
            _touchSave.x =(_touchEndPoint.x-_touchStartPoint.x)/100;
            _touchSave.y =(_touchEndPoint.y-_touchStartPoint.y)/100;
        }
        
    }
    
    float currentRotVert = _touchVertRotation-_previousRotVert;
    _previousRotVert = _touchVertRotation;
    
    if(_touchVertRotation*_touchVertRotation>0.1){
        if(currentRotVert>0){
            _playerXpos += sin(_totalRotationHori+_touchHoriRotation)*-1.3;
            _playerYpos += cosf(_totalRotationHori+_touchHoriRotation)*-1.3;
        }else {
            _playerXpos += sin(_totalRotationHori+_touchHoriRotation)*1.3;
            _playerYpos += cosf(_totalRotationHori+_touchHoriRotation)*1.3;
        }
    }
    
    if(count==2&&!_rotating){
        UITouch *touch1, *touch2;
        NSSet *allTouches = [event allTouches];
        touch1 = [[allTouches allObjects] objectAtIndex:0];
        touch2 = [[allTouches allObjects] objectAtIndex:1];
        
        _touchZoomEndPoint1 = [touch1 locationInView:self.view];
        _touchZoomEndPoint2 = [touch2 locationInView:self.view];
        
        //Scale stuff
        CGPoint _touchStartDistVec = {_touchZoomStartPoint1.x-_touchZoomStartPoint2.x,_touchZoomStartPoint1.y-_touchZoomStartPoint2.y};
        CGPoint _touchEndDistVec = {_touchZoomEndPoint1.x-_touchZoomEndPoint2.x,_touchZoomEndPoint1.y-_touchZoomEndPoint2.y};
        
        float _touchStartDist = sqrtf(_touchStartDistVec.x*_touchStartDistVec.x+_touchStartDistVec.y*_touchStartDistVec.y);
        float _touchEndDist = sqrtf(_touchEndDistVec.x*_touchEndDistVec.x+_touchEndDistVec.y*_touchEndDistVec.y);
        
        _scale =(_touchEndDist-_touchStartDist)/100;
        
        //Translation stuff
        CGPoint _point1Vec = {_touchZoomEndPoint1.x-_touchZoomStartPoint1.x, _touchZoomEndPoint1.y-_touchZoomStartPoint1.y};
        CGPoint _point2Vec = {_touchZoomEndPoint2.x-_touchZoomStartPoint2.x, _touchZoomEndPoint2.y-_touchZoomStartPoint2.y};
        
        CGPoint _averageVec = {(_point1Vec.x+_point2Vec.x)/2, (_point1Vec.y+_point2Vec.y)/2};
        _translationx = _averageVec.x/100;
        _translationy = _averageVec.y/-100;
        
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *allTouches = [touches allObjects];
    NSUInteger count = [allTouches count];
    
    UITouch *touch = [touches anyObject];
    
    if(!_rotating&&_touchEndPoint.x!=0.0f&&_touchEndPoint.y!=0.0f)
    {
        if(count==1){
            //NSLog(@"VertFinal: %f,%f", _touchSave.x, _touchSave.y);
            _totalRotationHori += _touchSave.x;
            _totalRotationVert += _touchSave.y;
            [self resetTouches];
        }
    }
    
    _totalScale+=_scale;
    _scale=0.0f;
    
    _totalTranslationx += _translationx;
    _totalTranslationy += _translationy;
    _totalTranslationz += _translationz;
    _translationx = 0.0f;
    _translationy = 0.0f;
    _translationy = 0.0f;
    
    if (touch.tapCount == 1) {
        //place the single tap action to fire after a delay of 0.3
        //[touch locationInView:self.view];
        //this is the single tap action being set on a delay
        //[self performSelector:@selector(onFlip) withObject:nil afterDelay:0.3];
        
    } else if (touch.tapCount == 2) {
        //this is the double tap action
        _playerXpos=0;
        _playerYpos=0;
        _totalRotationHori=0;
        _totalRotationVert=0;
    }
    
    if(!_rotating){
        
    }
    
    _touchSave.x=0.0f;
    _touchSave.y=0.0f;
}

-(void)resetTouches
{
    _touchHoriRotation = 0.0f;
    _touchVertRotation = 0.0f;
    
}



@end
