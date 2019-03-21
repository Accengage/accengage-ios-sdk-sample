//
//  ACCCustomTagProvider.m
//  GoogleTagManagerBridge
//
//  Created by Bastien MATTHAI on 18/03/2019.
//  Copyright © 2019 ACC. All rights reserved.
//

#import "ACCCustomTagProvider.h"
#import "Accengage/Accengage.h"

/* Accengage Actions */
NSString *const KEY_ACTION = @"acc_action";
NSString *const ACTION_TRACK_EVENT = @"track_event";
NSString *const ACTION_TRACK_LEAD = @"track_lead";
NSString *const ACTION_TRACK_ADD_TO_CART = @"track_add_to_cart";
NSString *const ACTION_TRACK_PURCHASE = @"track_purchase";
NSString *const ACTION_SET_UDI = @"set_udi";
NSString *const ACTION_DELETE_UDI = @"delete_udi";
NSString *const ACTION_INCREMENT_UDI = @"increment_udi";
NSString *const ACTION_DECREMENT_UDI = @"decrement_udi";

/* Track Event */
NSString *const KEY_EVENT_ID = @"acc_event_id";

/* Track Lead */
NSString *const KEY_LEAD_LABEL = @"acc_lead_label";
NSString *const KEY_LEAD_VALUE = @"acc_lead_value";

/* Track Add To Cart */
NSString *const KEY_CART_ID = @"acc_cart_id";
NSString *const KEY_ITEM_ID = @"acc_item_id";
NSString *const KEY_ITEM_LABEL = @"acc_item_label";
NSString *const KEY_ITEM_CATEGORY = @"acc_item_category";
NSString *const KEY_ITEM_CURRENCY = @"acc_item_currency";
NSString *const KEY_ITEM_PRICE = @"acc_item_price";
NSString *const KEY_ITEM_QUANTITY = @"acc_item_quantity";
NSString *const KEY_ITEM_BRAND = @"acc_item_brand";

/* Track Purchase */
NSString *const KEY_PURCHASE_ID = @"acc_purchase_id";
NSString *const KEY_PURCHASE_CURRENCY = @"acc_purchase_currency";
NSString *const KEY_PURCHASE_TOTAL_PRICE = @"acc_purchase_total_price";
NSString *const KEY_PURCHASE_ITEMS = @"acc_purchase_items";


@implementation ACCCustomTagProvider

- (NSObject*)executeWithParameters:(NSDictionary*)parameters {
    
    if (!parameters) {
        NSLog(@"No parameters found");
        return nil;
    }
    
    NSString *acccengageAction = parameters[KEY_ACTION];
    if (!acccengageAction) {
        NSLog(@"No Accengage action found in parameters");
        return nil;
    }
    
    if ([acccengageAction isEqualToString:ACTION_TRACK_EVENT]) {
        
        [self parseTrackEventMessage:parameters];
        
    } else if([acccengageAction isEqualToString:ACTION_TRACK_LEAD]) {
        
        [self parseTrackLeadMessage:parameters];
        
    } else if ([acccengageAction isEqualToString:ACTION_TRACK_ADD_TO_CART]) {
        
        [self parseTrackCartMessage:parameters];
        
    } else if([acccengageAction isEqualToString:ACTION_TRACK_PURCHASE]) {
        
        [self parseTrackPurchaseMessage:parameters];
        
    } else if([acccengageAction isEqualToString:@"set_udi"]) {
        
        [self parseTrackSetUdi:parameters];
        
    } else if([acccengageAction isEqualToString:@"increment_udi"]) {
        
        [self parseTrackIncrementUdi:parameters];
        
    } else if([acccengageAction isEqualToString:@"decrement_udi"]) {
        
        [self parseTrackDecrementUdi:parameters];
        
    } else if([acccengageAction isEqualToString:@"delete_udi"]) {
        
        [self parseTrackDeleteUdi:parameters];
        
    }
    return nil;
    
}



///--------------------------------------
#pragma mark - Tracking -
///--------------------------------------

#pragma mark Track Event

- (void)parseTrackEventMessage:(NSDictionary *)parameters {
    
    NSNumber *type = parameters[KEY_EVENT_ID];
    if (!type) {
        NSLog(@"No %@ found in parameters. Can't send %@ action", KEY_EVENT_ID, ACTION_TRACK_EVENT);
        return;
    }
    
    //    NSNumber *type = [parameters[KEY_EVENT_ID] isKindOfClass:[NSNumber class]];
    //    NSDictionary *value = [message[ACCWTEventValueKey] acc_asClass:[NSDictionary class]];
    //    if (!type || !value) {
    //        NSLog(@"The type and the Value are required %@ ", msg);
    //        return;
    //    }
    
    ACCCustomEventParams *customEventParams = [[ACCCustomEventParams alloc] init];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key isEqualToString:KEY_EVENT_ID]) {
            if ([obj isKindOfClass:[NSString class]]) {
                [customEventParams setString:obj forKey:key];
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                [customEventParams setNumber:obj forKey:key];
            } else if ([obj isKindOfClass:[NSDate class]]) {
                [customEventParams setDate:obj forKey:key];
            }
        }
    }];
    
    [Accengage trackEvent:[type integerValue] withCustomParameters:customEventParams];
}

#pragma mark Track Lead

- (void)parseTrackLeadMessage:(NSDictionary *)parameters {
    
    NSString *label = parameters[KEY_LEAD_LABEL];
    NSString *value = parameters[KEY_LEAD_VALUE];
    
    if (!label || !value) {
        NSLog(@"The Label and the Value are required %@ ", parameters);
        return;
    }
    
    [Accengage trackLead:label value:value];
}

#pragma mark Track Cart

- (void)parseTrackCartMessage:(NSDictionary *)parameters {
    
    NSString *cartId = parameters[KEY_CART_ID];
    NSString *currency = parameters[KEY_ITEM_CURRENCY];
    NSString *itemId = parameters[KEY_ITEM_ID];
    NSString *itemLabel = parameters[KEY_ITEM_LABEL];
    NSString *itemCategory = parameters[KEY_ITEM_CATEGORY];
    NSNumber *itemPrice = parameters[KEY_ITEM_PRICE];
    NSNumber *itemQuantity = parameters[KEY_ITEM_QUANTITY];
    NSString *brand = parameters[KEY_ITEM_BRAND];
    
    if (!cartId || !currency || !itemId || !itemLabel || !itemCategory  || !itemPrice || !itemQuantity) {
        NSLog(@"The acc_cart_id, itemID, currency, item id, price, and quantity are required %@ ", parameters);
        return;
    }
    
    ACCCartItem *item = [ACCCartItem itemWithId:itemId name:itemLabel brand:brand category:itemCategory price:itemPrice.doubleValue quantity:itemQuantity.integerValue];
    
    [Accengage trackCart:cartId currency:currency item:item];
    
}

#pragma mark Track Purchase

- (void)parseTrackPurchaseMessage:(NSDictionary *)parameters {
    
    NSString *purchaseId = parameters[KEY_PURCHASE_ID];
    NSNumber *currency = parameters[KEY_PURCHASE_CURRENCY];
    NSNumber *price = parameters[KEY_PURCHASE_TOTAL_PRICE];
    NSArray *items = parameters[KEY_PURCHASE_ITEMS];
    
    
    if (!purchaseId || !currency) {
        NSLog(@"The purchaseId and currency are required %@ ", parameters);
        return;
    }
    
    //    NSMutableArray<ACCCartItem *> *cartItems = @[].mutableCopy;
    
    //    for (id item in items) {
    //        ACCCartItem *cartItem = [self parseCartItem:item];
    //
    //        if (cartItem) {
    //            [cartItems addObject:cartItem];
    //        }
    //    }
    
    [Accengage trackPurchase:purchaseId currency:currency items:items amount:price];
}


///--------------------------------------
#pragma mark - User Profile : UDI -
///--------------------------------------

- (void)parseTrackSetUdi:(NSDictionary *)parameters {
    
    ACCDeviceInformationSet * deviceInformationSet = [[ACCDeviceInformationSet alloc] init];
    
    for (NSString *key in parameters) {
        id value = parameters[key];
        if (![key isEqualToString:KEY_ACTION]) {
            if ([value isKindOfClass:[NSString class]]) {
                [deviceInformationSet setString:value forKey:key];
            } else if ([value isKindOfClass:[NSNumber class]]) {
                [deviceInformationSet setNumber:value forKey:key];
            } else if ([value isKindOfClass:[NSDate class]]) {
                [deviceInformationSet setDate:value forKey:key];
            }
        }
    }
    
    [[Accengage profile] updateDeviceInformation:deviceInformationSet withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"UDI error %@", error.localizedDescription);
        }
    }];
}

- (void)parseTrackDeleteUdi:(NSDictionary *)parameters {
    
    ACCDeviceInformationSet * deviceInformationSet = [[ACCDeviceInformationSet alloc] init];
    for (NSString *key in parameters) {
        if (![key isEqualToString:KEY_ACTION]) {
            [deviceInformationSet deleteValueForKey:key];
        }
    }
    [[Accengage profile] updateDeviceInformation:deviceInformationSet withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"UDI error %@", error.localizedDescription);
        }
    }];
    
}

- (void)parseTrackIncrementUdi:(NSDictionary *)parameters {
    
    ACCDeviceInformationSet * deviceInformationSet = [[ACCDeviceInformationSet alloc] init];
    for (NSString *key in parameters) {
        if (![key isEqualToString:KEY_ACTION]) {
            if (![parameters[key] isKindOfClass:[NSNumber class]]) {
                NSLog(@"The value of %@ should be of type NSNumber", key);
            }
            [deviceInformationSet incrementValueBy:parameters[key] forKey:key];
        }
    }
    [[Accengage profile] updateDeviceInformation:deviceInformationSet withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"UDI error %@", error.localizedDescription);
        }
    }];
    
}

- (void)parseTrackDecrementUdi:(NSDictionary *)parameters {
    
    ACCDeviceInformationSet * deviceInformationSet = [[ACCDeviceInformationSet alloc] init];
    for (NSString *key in parameters) {
        if (![key isEqualToString:KEY_ACTION]) {
            if (![parameters[key] isKindOfClass:[NSNumber class]]) {
                NSLog(@"The value of %@ should be of type NSNumber", key);
            }
            [deviceInformationSet decrementValueBy:parameters[key] forKey:key];
        }
    }
    [[Accengage profile] updateDeviceInformation:deviceInformationSet withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"UDI error %@", error.localizedDescription);
        }
    }];
    
}

@end
