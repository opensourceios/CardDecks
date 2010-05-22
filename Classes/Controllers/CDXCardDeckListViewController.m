//
//
// CDXCardDeckListViewController.m
//
//
// Copyright (c) 2009-2010 Arne Harren <ah@0xc0.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CDXCardDeckListViewController.h"
#import "CDXCardDeckCardViewController.h"
#import "CDXCardDeckCardEditViewController.h"
#import "CDXSettingsViewController.h"
#import "CDXImageFactory.h"


@implementation CDXCardDeckListViewController

- (id)initWithCardDeck:(CDXCardDeck *)deck {
    if ((self = [super initWithNibName:@"CDXCardDeckListView" bundle:nil])) {
        ivar_assign_and_retain(cardDeck, deck);
    }
    return self;
}

- (void)dealloc {
    ivar_release_and_clear(cardDeckTableView);
    ivar_release_and_clear(cardDeck);
    ivar_release_and_clear(viewToolbar);
    ivar_release_and_clear(tableCellTextFont);
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationItem *navigationItem = self.navigationItem;
    navigationItem.title = cardDeck.name;
    navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
                                         initWithTitle:@"Cards"
                                         style:UIBarButtonItemStylePlain
                                         target:nil
                                         action:nil]
                                        autorelease];
    self.toolbarItems = viewToolbar.items;
    ivar_assign_and_retain(tableCellTextFont, [UIFont boldSystemFontOfSize:18]);
    tableCellImageSize = CGSizeMake(10, 10);
}

- (void)viewDidUnload {
    ivar_release_and_clear(cardDeckTableView);
    ivar_release_and_clear(viewToolbar);
    ivar_release_and_clear(tableCellTextFont);
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [cardDeckTableView reloadData];
}

- (void)setUserInteractionEnabled:(BOOL)enabled {
}

- (void)deviceOrientationDidChange:(UIDeviceOrientation)orientation {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cardDeck cardsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
    }
    
    CDXCard *card = [cardDeck cardAtIndex:indexPath.row];
    cell.textLabel.text = card.text;
    cell.textLabel.font = tableCellTextFont;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.imageView.image = [[CDXImageFactory sharedImageFactory] imageForThumbnailCard:card size:tableCellImageSize];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CDXCardDeckCardViewController *vc = [[[CDXCardDeckCardViewController alloc] initWithCardDeck:cardDeck atIndex:indexPath.row] autorelease];
    [[CDXAppWindowManager sharedAppWindowManager] pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    CDXCardDeckCardEditViewController *vc = [[[CDXCardDeckCardEditViewController alloc] initWithCardDeck:cardDeck atIndex:indexPath.row] autorelease];
    [[CDXAppWindowManager sharedAppWindowManager] pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.editing ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [cardDeck removeCardAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    qltrace();
    CDXCard *card = [cardDeck cardAtIndex:fromIndexPath.row];
    [card retain];
    [cardDeck removeCardAtIndex:fromIndexPath.row];
    [cardDeck insertCard:card atIndex:toIndexPath.row];
    [card release];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [cardDeckTableView setEditing:editing animated:animated];
}

- (IBAction)addButtonPressed {
    qltrace();
}

- (IBAction)editButtonPressed {
    qltrace();
    [self setEditing:!self.editing animated:YES];
}

- (IBAction)settingsButtonPressed {
    qltrace();
    CDXCardDeckSettings *settings = [[[CDXCardDeckSettings alloc] initWithCardDeck:cardDeck] autorelease];
    CDXSettingsViewController *vc = [[[CDXSettingsViewController alloc] initWithSettings:settings] autorelease];
    [self presentModalViewController:vc animated:YES];
}

@end

