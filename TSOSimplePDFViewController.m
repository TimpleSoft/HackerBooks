//
//  TSOSimplePDFViewController.m
//  HackerBooks
//
//  Created by Timple Soft on 2/4/15.
//  Copyright (c) 2015 TimpleSoft. All rights reserved.
//

#import "TSOSimplePDFViewController.h"
#import "TSOBook.h"
#import "Settings.h"
#import "TSODownloadController.h"

@interface TSOSimplePDFViewController ()

@end

@implementation TSOSimplePDFViewController


-(id) initWithModel:(TSOBook *) model{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _model = model;
        self.title = model.title;
    }
    
    return self;
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Asegurarse de que no se ocupa toda la pantalla cuando está en un combinador
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.browser.delegate = self;
    
    // arrancamos le inidicator y empezamos a cargar el pdf
    [self syncWithModel];
    
    // Alta en notificaciones
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(notifyThatBookDidChange:)
               name:BOOK_DID_CHANGE_NOTIFICATION
             object:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - UIWebViewDelegate
-(void) webViewDidFinishLoad:(UIWebView *)webView{
    
    // paramos el activity
    [self.activityView stopAnimating];
    
    // Le indicamos al modelo que hemos descargado el pdf
    [self.model downloadedPDFWithData:self.pdfData];
    
}


# pragma mark - Notifications

// BOOK_DID_CHANGE_NOTIFICATION
-(void) notifyThatBookDidChange:(NSNotification *) notification{
    
    // sacamos el libro
    TSOBook *book = [notification.userInfo objectForKey:BOOK_KEY];
    
    // actualizamos el model
    self.model = book;
    
    // sincronizamos modelo y vista
    [self syncWithModel];
    
}


# pragma mark - Utils
-(void) syncWithModel{
    
    [self.activityView setHidden:NO];
    [self.activityView startAnimating];
    //[self.browser loadRequest:[NSURLRequest requestWithURL:self.model.urlToPDF]];
    
    // CODIGO QUE SE EJECUTA EN OTRO HILO
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // lo guardamos en una propiedad por si tenemos que almacenalo despues
        self.pdfData = [self.model pdfData];
        [self.browser loadData:self.pdfData
                      MIMEType:@"application/pdf"
              textEncodingName:@"UTF-8"
                       baseURL:nil];
    });
    
}


@end
