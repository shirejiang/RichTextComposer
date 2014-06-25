//
//  ViewController.m
//  RichTextComposer
//
//  Created by Shire Jiang on 6/25/14.
//  Copyright (c) 2014 shire. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)selectPhoto:(UIBarButtonItem *)sender;
- (IBAction)printHTML:(UIBarButtonItem *)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadWebView];
}

#pragma mark - Helper

- (void)loadWebView {
    [self.webView setDelegate:self];
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *indexFileURL = [bundle URLForResource:@"composer" withExtension:@"html"];

    [self.webView setKeyboardDisplayRequiresUserAction:NO];
    [self.webView loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *inputPlaceholder = NSLocalizedString(@"Title", @"Title");
    NSString *contentPlaceholder = NSLocalizedString(@"Content", @"Content");
    NSString *script = [NSString stringWithFormat:@"window.initPlaceholder('%@', '%@')", inputPlaceholder, contentPlaceholder];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (IBAction)selectPhoto:(UIBarButtonItem *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)printHTML:(UIBarButtonItem *)sender {
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('title-input').value"];
    NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').innerHTML"];
    NSString *script = [self.webView stringByEvaluatingJavaScriptFromString:@"window.alertHtml()"];
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    NSLog(@"Title: %@", title);
    NSLog(@"Inner HTML: %@", html);
}

- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

#pragma mark - ImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Obtain the path to save to
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDate *now = [NSDate date];
    NSString *imageName = [NSString stringWithFormat:@"photo%@.jpg", [self stringFromDate:now]];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        [imageData writeToFile:imagePath atomically:YES];
    }

    NSString *script = [NSString stringWithFormat:@"window.insertImage('%@', '%@')", imageName, imagePath];
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
