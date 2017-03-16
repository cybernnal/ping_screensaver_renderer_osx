//
//  pingView.m
//  ping
//
//  Created by tom billard on 16/03/2017.
//  Copyright © 2017 tom billard. All rights reserved.
//

#import "ping2View.h"

@implementation pingView

static NSString * const MyModuleName = @"com.tom.ping";

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self)
    {
        ScreenSaverDefaults *defaults;
        
        defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
        
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:@"NO", @"DrawFilledShapes", @"NO", @"DrawOutlinedShapes", @"YES", @"DrawBoth", nil]];
        
        [self setAnimationTimeInterval:1/1000.0];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
}

- (void)draw_black
{
    NSBezierPath *path;
    NSRect bg;
    
    NSColor *color;
    NSRect e = [[NSScreen mainScreen] frame];
    int H = (int)e.size.height;
    int W = (int)e.size.width;
   
    bg.origin.x = 0;
    bg.origin.y = 0;
    bg.size.width = W;
    bg.size.height = H;
    
    path =[NSBezierPath bezierPathWithRect:bg];
    color = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
    [color set];
    [path fill];
}

- (void)draw_square:(float) x_max y_max:(float) y_max origin_x:(int) x origin_y:(int) y r:(float) r g:(float)g b:(float) b
{
    NSBezierPath *path;
    NSRect bg;
    float red, green, blue;
    NSColor *color;
   
    bg.origin.x = x;
    bg.origin.y = y;
    bg.size.width = y_max;
    bg.size.height = x_max;
    
    red = r;
    green = g;
    blue = b;
    
    path = [NSBezierPath bezierPathWithOvalInRect:bg];
//    path =[NSBezierPath bezierPathWithRect:bg];
    color = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1];
    [color set];
    [path fill];}

- (void)    rend:(t_list*) lst first:(t_list*) first max:(float) max
{
    NSRect e = [[NSScreen mainScreen] frame];
    int H = (int)e.size.height - 10;
    int W = (int)e.size.width;
    float off =  (W - 50) / MAXX;
    int i = 0;
    lst = first;
    while (lst){
        if (lst->t == 0)
            [self draw_square:off y_max:off origin_x:(int)(((i * (off))) + 10) origin_y:(int) L_CF(lst->t, 0, max, 10, H - off * 2) r:255 g:0 b:0];
        else
            [self draw_square:off y_max:off origin_x:(int)(((i * (off))) + 10) origin_y:(int) L_CF(lst->t, 0, max, 10, H - off * 2) r:L_CF(lst->t, 0, max, 0, 1) g:L_CF(lst->t, 0, max, 1, 0) b:L_CF(lst->t, 0, max, 0.7, 1)];
        
        lst = lst->next;
        i++;
    }
    
}

- (void)animateOneFrame
{
    int error = 300;
    static t_list  *lst;
    static t_list  *first;
    NSSize size;
    ScreenSaverDefaults *defaults;
    int i = 0;
    char buf[BUFSIZE];
    FILE *fp;
    int max = 0;
    char *cmd = "ping -i 0.1 -c 1 -t 1 8.8.8.8";
    float ms;
    NSAttributedString * currentText;
    
    [self draw_black];
    if ((fp = popen(cmd, "r")) == NULL) {
        max = process_list(&lst, &first, error);
    }
    else
    {
        while (i < 2)
        {
            if (fgets(buf, BUFSIZE, fp) != NULL)
            {
                if (i != 0)
                {
                    ms = get_timee(buf);
                    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:15], NSFontAttributeName,[NSColor blueColor], NSForegroundColorAttributeName, nil];
                    if (ms == 0.0)
                        currentText=[[NSAttributedString alloc] initWithString:@"time out" attributes: attributes];
                    else
                        currentText=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ms", [NSNumber numberWithFloat:ms].stringValue] attributes: attributes];
                    [currentText drawAtPoint:NSMakePoint(0, 0)];
                    max = process_list(&lst, &first, ms);
                    break ;
                }
                i++;
            }
            else
            {
                max = process_list(&lst, &first, error);
                break ;
            }
        }
        pclose(fp);
    }
    [self rend:lst first:first max:max];
    size = [self bounds].size;
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    return Nil;
}

- (IBAction)cancelClick:(id)sender
{
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)okClick:(id)sender
{
    ScreenSaverDefaults *defaults;
    
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    
    // Update defaults
    [defaults setBool:[drawFilledShapesOption state] forKey:@"DrawFilledShapes"];
    [defaults setBool:[drawOutlinedShapesOption state] forKey:@"DrawOutlinedShapes"];
    [defaults setBool:[drawBothOption state] forKey:@"DrawBoth"];
    
    // Save settings to disk
    [defaults synchronize];
    
    // Close the sheet
    [[NSApplication sharedApplication] endSheet:configSheet];
}


@end


void	*ft_memalloc(size_t size)
{
    unsigned char *ptr;
    
    ptr = (unsigned char*)malloc(sizeof(unsigned char) * (size));
    if (ptr == 0)
    {
        printf("Malloc error\n");
        return (0);
    }
    bzero(ptr, size);
    return (ptr);
}


float get_timee(char*buf)
{
   char *tmp = strstr(buf, "time");
    if (tmp)
        return ((float)(atof(tmp + 5)));
    return (0.0);
}


 t_list *get_new(void)
{
    t_list *lst;
    t_list *first;
    int i = 0;
    lst = (t_list*)ft_memalloc(sizeof(t_list));
    first = lst;
    while (i < MAXX - 1)
    {
        lst->next = (t_list*)ft_memalloc(sizeof(t_list));
        bzero(lst->next, sizeof(t_list));
        lst = lst->next;
        i++;
    }
    return (first);
}

float get_max(t_list **l)
{
    float m = 0;
    t_list  *lst = *l;
    
    while (lst->next)
    {
        if (m < lst->t)
            m = lst->t;
        lst = lst->next;
    }
    return (m);
}


float process_list(t_list **lst, t_list **first, float t)
{
    static int nb = 0;
    static float max = 0;
    
    if (nb == 0)
    {
        *lst = get_new();
        *first = *lst;
    }
    else if (nb < MAXX)
    {
        *lst = (*lst)->next;
    }
    else
    {
        (*lst)->next = *first;
        *first = (*first)->next;
        *lst = (*lst)->next;
        (*lst)->next = NULL;
        if ((*lst)->t == max)
            max = get_max(first);
    }
    (*lst)->t = t;
    if (t > max)
        max = t;
    nb++;
    return (max);
}
