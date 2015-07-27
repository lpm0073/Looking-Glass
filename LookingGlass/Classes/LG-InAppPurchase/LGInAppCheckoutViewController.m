//
//  LGInAppCheckoutViewController.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGInAppCheckoutViewController.h"
#import "LGAppDataFeed.h"


@interface LGInAppCheckoutViewController()

@property (nonatomic, retain) SKPaymentQueue *paymentQueue;
@property (nonatomic, retain) SKProductsRequest *productsRequest;
@property (nonatomic, assign) id<SKPaymentTransactionObserver> transactionObserver;

- (void)doBuyButton;
- (void)transactionComplete:(SKPaymentTransaction *)transaction;
- (void)transactionFail:(SKPaymentTransaction *)transaction;
- (void)transactionRestore:(SKPaymentTransaction *)transaction;
- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString *)productIdentifier;

@end


@implementation LGInAppCheckoutViewController

@synthesize paymentQueue;
@synthesize productsRequest;
@synthesize transactionObserver;

@synthesize buyButton;
@synthesize headerLabel;
@synthesize saleTotalLabel;
@synthesize shoppingCartContents;


#pragma mark - Setters and Getters
- (SKProductsRequest *)productsRequest
{
    if (!productsRequest) {
        //FIX NOTE. ADD FEATURE IDENTIFIER.
        productsRequest = [[[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject: nil]] retain];
        productsRequest.delegate = self;
    }
    return productsRequest;
}

#pragma mark - UI actions

- (void)doBuyButton
{
    NSLog(@"doBuyButton");
    
    if ([SKPaymentQueue canMakePayments]) {
        
    } else {
        // push an alert to user that purchases are disabled.
    }
     
}


#pragma mark - SK framework

//callback for Transaction Observer: self.transactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self transactionComplete:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self transactionFail:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self transactionRestore:transaction];
                break;
            default:
                break;
        } 
    }
}


//callback for self.productsRequest
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    //NSArray *myProduct = response.products;
    // populate UI
    
    
}

#pragma mark - Custom Trx Completers
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"recordTransaction: %@", [transaction description]);
    
    //assuming that we'll put the original transaction identifier in the Plist?
    NSLog(@"original transaction: %@", transaction.originalTransaction.transactionIdentifier);
    
}

- (void)provideContent:(NSString *)productIdentifier
{
    NSLog(@"provideContent: %@", productIdentifier);
    
    //For example: ...
    //[LGAppDataFeed unlockDataFeedType:LGDataFeedTypeFaceBook];
    //
    
}

- (void)transactionComplete:(SKPaymentTransaction *)transaction
{
    NSLog(@"completed: %@", [transaction description]);
    
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)transactionFail:(SKPaymentTransaction *)transaction
{
    NSLog(@"failed: %@", [transaction description]);
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)transactionRestore:(SKPaymentTransaction *)transaction
{
    NSLog(@"restored: %@", [transaction description]);
    
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)transactionVerify:(SKPaymentTransaction *)transaction
{
    
    
    /*
     
     1. Retrieve the receipt data from the transaction’s transactionReceipt property and encode it using base64 encoding.
     
     2. Create a JSON object with a single key named receipt-data and the string you created in step 1. Your JSON code should look like this:
     
     {
     "receipt-data" : "(actual receipt bytes here)"
     }
     
     3. Post the JSON object to the App Store using an HTTP POST request. The URL for the store is https://buy.itunes.apple.com/verifyReceipt.
     
     for testing use: NSURL *sandboxStoreURL = [[NSURL alloc] initWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
     
     4. The response received from the App Store is a JSON object with two keys, status and receipt. It should look something like this:
     
     {
     "status" : 0,
     "receipt" : { ... }
     }
     
     */
}


#pragma mark - Object lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [paymentQueue release];
    [productsRequest release];
    
    [buyButton release];
    [headerLabel release];
    [saleTotalLabel release];
    [shoppingCartContents release];

    [super dealloc];
    
}

- (void)loadView
{
    [super loadView];
    
    self.shoppingCartContents = [LGAppDataFeed getCartMutableArray];
    
    self.title = NSLocalizedString(@"LGInAppCheckoutViewController_Title", @"Checkout");
    [self.headerLabel setText:NSLocalizedString(@"LGInAppCheckoutViewController_Header", @"Thanks for using Looking Glass!")];
    
    self.saleTotalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"saleTotalLabel", @"Your Total: 1$%"), [LGAppDataFeed getCartCostTotalAsLocalizedString]];
    self.saleTotalLabel.textAlignment = UITextAlignmentRight;
    self.saleTotalLabel.font = [UIFont systemFontOfSize:15];
    
    if ([LGAppDataFeed getCartQtyTotal] > 0) {
        NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];
        self.buyButton        = [[UIBarButtonItem alloc]  initWithTitle:NSLocalizedString(@"Buy", @"Buy") 
                                                                  style:UIBarButtonItemStyleBordered 
                                                                 target:self 
                                                                 action:@selector(doBuyButton)
                                 ];
        
        [toolbarButtons addObject:self.buyButton];
        
        [self setToolbarItems:toolbarButtons];
        [toolbarButtons release];
        
        
        /* iTunes store hooks.
        [self.productsRequest start];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self.transactionObserver];
        
        //do this for each product in the shopping cart.
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"feature identifier"];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
         */
         
        
    }

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    paymentQueue = nil;
    productsRequest = nil;
    transactionObserver = nil;
    
    buyButton = nil;
    headerLabel = nil;
    saleTotalLabel = nil;
    shoppingCartContents = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.shoppingCartContents.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerView = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)] autorelease];
    
    headerView.backgroundColor = [UIColor brownColor];
    headerView.text = NSLocalizedString(@"headerViewText", @"Selected Products");
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *footerView = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)] autorelease];

    footerView.backgroundColor = [UIColor brownColor];
    footerView.text = nil;
    
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    NSInteger dataFeedType = [[self.shoppingCartContents objectAtIndex:[indexPath indexAtPosition:1]] integerValue];
    
    NSString *productName = [LGAppDataFeed nameForDataFeedType:dataFeedType];
    NSString *price = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:dataFeedType];
    
    cell.imageView.image  = [LGAppDataFeed imageForDataFeedTypeFormatted:dataFeedType];
    cell.imageView.backgroundColor = cell.backgroundColor;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ --------------------- %@", productName, price];
    cell.textLabel.textAlignment = UITextAlignmentRight;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == 0 || indexPath.row%2 == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.1];
        cell.imageView.backgroundColor = cell.backgroundColor;
    } 
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}




@end
