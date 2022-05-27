//
//  ColorManager.m
//  ImageFilter
//
//  Created by lax on 2022/5/27.
//

#import "ColorManager.h"

@interface ColorManager ()

@end


@implementation ColorManager

// 颜色转换三：iOS中十六进制的颜色（以#开头）转换为UIColor
+ (NSMutableArray *) colorWith16HexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        
        return [NSMutableArray arrayWithArray:@[@"255",@"255",@"255"]];
    }

    // 判断前缀并剪切掉
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [NSMutableArray arrayWithArray:@[@"255",@"255",@"255"]];

    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;

    //R、G、B
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    [RGBStrValueArr addObject: @(r) ];
    [RGBStrValueArr addObject: @(g) ];
    [RGBStrValueArr addObject: @(b) ];
    
    return RGBStrValueArr;
    
}

static void changeRGB(int *red,int* green,int*blue,int*alpha,const float *f){
//    NSLog(@"转换前%d %d %d %d", *red, *green, *blue, *alpha);
    
    int redV = *red;
    int greenV = *green;
    int blueV = *blue;
    int alphaV = *alpha;
    *red = f[0] * redV + f[1] * greenV + f[2] * blueV + f[3] * alphaV + f[4];
    *green = f[5] * redV + f[6] * greenV + f[7] * blueV + f[8] * alphaV + f[9];
    *blue = f[10] * redV + f[11] * greenV + f[12] * blueV + f[11] * alphaV + f[14];
    *alpha = f[15] * redV + f[16] * greenV + f[17] * blueV + f[18] * alphaV + f[19];
    
    *red < 0 ? (*red = 0) : (0);
    *red > 255 ? (*red = 255) : (0);
    
    *green < 0 ? (*green = 0) : (0);
    *green > 255 ? (*green = 255) : (0);
    
    *blue < 0 ? (*blue = 0) : (0);
    *blue > 255 ? (*blue = 255) : (0);
    
    *alpha < 0 ? (*alpha = 0) : (0);
    *alpha > 255 ? (*alpha = 255) : (0);
    
}

+ (UIImage *)changeImageColor:(UIImage *)image colorStr:(NSString *)colorStr {
    NSArray *arr = [ColorManager colorWith16HexString:colorStr];
    float r = (float)[arr[0] intValue] / 255.0f;
    float g = (float)[arr[1] intValue] / 255.0f;
    float b = (float)[arr[2] intValue] / 255.0f;
    NSLog(@"color = %@, r = %f, g = %f, b = %f", colorStr, r, g, b);
    float f[20] = {r,0,0,0,0,
                    0,g,0,0,0,
                    0,0,b,0,0,
                    0,0,0,1,0
                    };
    
    CGImageRef cgimage = [image CGImage];
    size_t width = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);

    unsigned char *data = calloc(width * height * 4, sizeof(unsigned char));

    size_t bitsPerComponent = 8;
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 space,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
    
    for (size_t i = 0; i < height; i++) {
        for (size_t j = 0; j < width; j++) {
            size_t pixelIndex = i * width * 4 + j * 4;

            int red = (unsigned char)data[pixelIndex];
            int green = (unsigned char)data[pixelIndex + 1];
            int blue = (unsigned char)data[pixelIndex + 2];
            int alpha = (unsigned char)data[pixelIndex + 3];
            
            changeRGB(&red, &green, &blue, &alpha, f);
            data[pixelIndex] = red;
            data[pixelIndex + 1] = green;
            data[pixelIndex + 2] = blue;
            data[pixelIndex + 3] = alpha;
            
        }
    }

    cgimage = CGBitmapContextCreateImage(context);
    UIImage *outImage = [UIImage imageWithCGImage:cgimage];
    CGColorSpaceRelease(space);
    CGContextRelease(context);
    CGImageRelease(cgimage);
    free(data);
    return outImage;
}


@end
