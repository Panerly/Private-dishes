//
//  GetSize.h
//  Private dishes
//
//  Created by panerly on 10/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetSize : NSObject

+(CGSize)getImageSizeWithURL:(id)imageURL;

+(CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request;

+(CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request;

+(CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request;
@end
