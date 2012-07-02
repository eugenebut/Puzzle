//
//  PZAppDelegate.m
//  Puzzle

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZAppDelegate.h"
#import "PZViewController.h"

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZAppDelegate

//////////////////////////////////////////////////////////////////////////////////////////
@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    NSString *imageFileName = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.viewController = [[PZViewController alloc] initWithNibName:@"PZViewController_iPhone" bundle:nil];
        imageFileName = @"puzzle_iPhone";
    }
    else
    {
        self.viewController = [[PZViewController alloc] initWithNibName:@"PZViewController_iPad" bundle:nil];
        imageFileName = @"puzzle_iPad";
    }
    self.viewController.puzzleImageFile = [[NSBundle mainBundle] pathForResource:imageFileName ofType:@"png"];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
