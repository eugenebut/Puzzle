//
//  PZAppDelegate.m
//  Puzzle

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZAppDelegate.h"
#import "PZViewController.h"

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZAppDelegate

//////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    NSString *imageFileName = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.viewController = [[PZViewController alloc] initWithNibName:@"PZViewController_iPhone" bundle:nil];
        imageFileName = @"Tiles_iPhone";
    }
    else
    {
        self.viewController = [[PZViewController alloc] initWithNibName:@"PZViewController_iPad" bundle:nil];
        imageFileName = @"Tiles_iPad";
    }
    // TODO: use ~iphone, ~ipad extenstions for images
    self.viewController.tilesImageFile = [[NSBundle mainBundle] pathForResource:imageFileName ofType:@"png"];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
